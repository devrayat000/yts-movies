import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import '../widgets/index.dart' hide SearchSuggestions;
import '../widgets/search/search_suggestions.dart';
import '../widgets/search/search_results.dart';
import '../models/index.dart';
import '../utils/index.dart';
import '../api/movies.dart';

class SearchPage extends StatefulWidget {
  final String? initialQuery;

  const SearchPage({
    super.key,
    this.initialQuery,
  });

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with TickerProviderStateMixin {
  late final TextEditingController _searchController;
  late final FocusNode _focusNode;
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;

  bool _hasSearched = false;
  bool _showingSuggestions = false;
  String _currentQuery = '';
  String _currentInput = '';
  // API autocomplete state
  List<Movie> _suggestions = [];
  bool _loadingSuggestions = false;
  Timer? _debounceTimer;
  CancelToken? _cancelToken;

  // Search history
  Box<String> get _box => Hive.box<String>(MyBoxs.searchHistoryBox);
  List<String> get _history => _box.values.toSet().toList().reversed.toList();
  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery ?? '');
    _focusNode = FocusNode();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Initialize current input state
    _currentInput = widget.initialQuery ??
        ''; // If we have an initial query, perform search
    if (widget.initialQuery?.isNotEmpty == true) {
      _currentQuery = widget.initialQuery!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _performSearch(_currentQuery);
      });
    } else {
      // Only focus the search field when there's no initial query
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _animationController.dispose();
    _debounceTimer?.cancel();
    _cancelToken?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _currentInput = query;
      _showingSuggestions = query.isNotEmpty;
    });

    // Cancel previous timer and request
    _debounceTimer?.cancel();
    _cancelToken?.cancel();

    if (query.trim().isEmpty) {
      setState(() {
        _suggestions = [];
        _loadingSuggestions = false;
      });
      return;
    }

    // Debounce API calls for autocomplete
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _fetchAutocompleteSuggestions(query.trim());
    });
  }

  Future<void> _fetchAutocompleteSuggestions(String query) async {
    if (query.isEmpty) return;

    // Cancel previous request
    _cancelToken?.cancel();

    setState(() {
      _loadingSuggestions = true;
    });

    try {
      _cancelToken = CancelToken();
      final moviesClient = context.read<MoviesClient>();
      final response = await moviesClient.getMovieList(
        queryTerm: query,
        limit: 5,
        page: 1,
        token: _cancelToken,
      );

      if (mounted && !_cancelToken!.isCancelled) {
        setState(() {
          _suggestions = response.data.movies?.take(5).toList() ?? [];
          _loadingSuggestions = false;
        });
      }
    } catch (e) {
      if (mounted && !(_cancelToken?.isCancelled ?? true)) {
        setState(() {
          _suggestions = [];
          _loadingSuggestions = false;
        });
      }
    }
  }

  void _onSearchSubmitted(String query) {
    if (query.trim().isEmpty) return;

    final trimmedQuery = query.trim();

    // Remove focus from text field and close keyboard
    _focusNode.unfocus();

    // Update URL with query parameter
    context
        .pushReplacementNamed('search', queryParameters: {'q': trimmedQuery});

    _performSearch(trimmedQuery);
  }

  void _performSearch(String query) async {
    if (query.isEmpty) return;

    setState(() {
      _hasSearched = true;
      _currentQuery = query;
      _showingSuggestions = false;
    });

    _animationController.forward();

    try {
      // Save to search history
      await _setHistory(query);
    } catch (e) {
      // Ignore history save errors
    }
  }

  Future<void> _setHistory(String query) async {
    try {
      final newHistory = query.trim();
      if (_history.contains(newHistory)) {
        await Future.wait([
          _box.deleteAt(_history.indexOf(newHistory)),
          _box.add(newHistory),
        ]);
      } else {
        await _box.add(newHistory);
      }
    } catch (e) {
      // Ignore history save errors
    }
  }

  void _onHistoryTap(int index) {
    final query = _history[index];
    _searchController.text = query;
    _onSearchSubmitted(query);
  }

  void _onSuggestionTap(String suggestion) {
    _searchController.text = suggestion;
    // Remove focus from text field and close keyboard
    _focusNode.unfocus();
    _onSearchSubmitted(suggestion);
  }

  void _onMovieTap(Movie movie) {
    context.push('/movie/${movie.id}');
  }

  void _resetSearch() {
    setState(() {
      _currentInput = '';
      _showingSuggestions = false;
      _hasSearched = false;
      _currentQuery = '';
      _suggestions = [];
      _loadingSuggestions = false;
    });
    _animationController.reset();
    _cancelToken?.cancel();
    _debounceTimer?.cancel();
    _focusNode.requestFocus();
  }

  Widget _buildAutocompleteList(BuildContext context) {
    if (_loadingSuggestions) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_suggestions.isEmpty) {
      return const SizedBox.shrink();
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: _suggestions.length,
      itemBuilder: (context, index) {
        final movie = _suggestions[index];
        return ListTile(
          leading: const Icon(Icons.movie, size: 20),
          title: RichText(
            text: TextSpan(
              children: _highlightMatches(movie.title, _currentInput, context),
            ),
          ),
          subtitle: movie.year != null ? Text('${movie.year}') : null,
          dense: true,
          onTap: () => _onSuggestionTap(movie.title),
        );
      },
    );
  }

  List<TextSpan> _highlightMatches(
      String text, String query, BuildContext context) {
    final theme = Theme.of(context);
    final spans = <TextSpan>[];
    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();

    int start = 0;
    int index = lowerText.indexOf(lowerQuery);

    while (index != -1) {
      // Add text before match
      if (index > start) {
        spans.add(TextSpan(
          text: text.substring(start, index),
          style: theme.textTheme.bodyMedium,
        ));
      }

      // Add highlighted match
      spans.add(TextSpan(
        text: text.substring(index, index + query.length),
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
        ),
      ));

      start = index + query.length;
      index = lowerText.indexOf(lowerQuery, start);
    }

    // Add remaining text
    if (start < text.length) {
      spans.add(TextSpan(
        text: text.substring(start),
        style: theme.textTheme.bodyMedium,
      ));
    }

    return spans;
  }

  final _searchInputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(20.0),
    borderSide: BorderSide(
      width: 0.0,
      color: Colors.transparent,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        title: Stack(
          alignment: Alignment.centerRight,
          children: [
            TextField(
              controller: _searchController,
              focusNode: _focusNode,
              onChanged: _onSearchChanged,
              onSubmitted: _onSearchSubmitted,
              decoration: InputDecoration(
                hintText: 'Search movies...',
                border: _searchInputBorder,
                enabledBorder: _searchInputBorder,
                focusedBorder: _searchInputBorder,
                hintStyle: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                ),
                isDense: true, // Makes the field more compact
                filled: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical:
                      6, // Reduced vertical padding for thinner appearance
                ),
              ),
              textInputAction: TextInputAction.search,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 16,
              ),
            ),
            if (_currentInput.isNotEmpty)
              Positioned.directional(
                textDirection: TextDirection.ltr,
                end: 0,
                child: IconButton(
                  onPressed: () {
                    _searchController.clear();
                    _resetSearch();
                  },
                  icon: const Icon(Icons.clear),
                ),
              )
          ],
        ),
      ),
      body: Stack(
        children: [
          // Main content
          Column(
            children: [
              // Search suggestions or results
              Expanded(
                child: _hasSearched
                    ? FadeTransition(
                        opacity: _fadeAnimation,
                        child: SearchResults(
                          query: _currentQuery,
                          params: {}, // Add any filter parameters here
                        ),
                      )
                    : SearchSuggestions(
                        history: _history,
                        onHistoryTap: _onHistoryTap,
                        onMovieTap: _onMovieTap,
                      ),
              ),
            ],
          ),
          // Autocomplete dropdown overlay
          if (_showingSuggestions && _currentInput.isNotEmpty)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Material(
                elevation: 4,
                child: Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    border: Border(
                      bottom: BorderSide(
                        color: colorScheme.outline.withOpacity(0.2),
                      ),
                    ),
                  ),
                  child: _buildAutocompleteList(context),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
