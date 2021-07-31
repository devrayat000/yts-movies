import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:ytsmovies/widgets/image.dart';

import '../../utils/mixins.dart';
import '../../models/movie.dart';
import '../../pages/movie.dart';

class SearchAppbar extends StatefulWidget implements PreferredSizeWidget {
  final void Function()? onScrollToTop;
  final void Function() onSearch;
  final TextEditingController controller;
  final Future<Map<String, dynamic>> Function(Uri url) onSuggest;

  const SearchAppbar({
    Key? key,
    this.onScrollToTop,
    required this.onSearch,
    required this.controller,
    required this.onSuggest,
  })  : preferredSize = const Size.fromHeight(kToolbarHeight),
        super(key: key);

  @override
  final Size preferredSize;

  @override
  _SearchAppbarState createState() => _SearchAppbarState();
}

class _SearchAppbarState extends State<SearchAppbar>
    with
        SingleTickerProviderStateMixin<SearchAppbar>,
        PageStorageCache<SearchAppbar> {
  late final AnimationController _cancellEditionAnimationController;
  late final SuggestionsBoxController _suggestionsBoxController;
  late final Animation<double> _cancellEditionAnimation;
  late final TextEditingController _searchInputController;

  final _searchFocusNode = FocusNode();
  final _inputValueKey = ValueKey('search-input');
  final _formKey = GlobalKey<FormState>();

  static final _scaleTween = Tween<double>(begin: 0, end: 1);

  @override
  void initState() {
    _cancellEditionAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );
    _suggestionsBoxController = SuggestionsBoxController();

    _cancellEditionAnimation = _scaleTween.animate(CurvedAnimation(
      parent: _cancellEditionAnimationController,
      curve: Curves.easeInOut,
    ));

    final cachedInput = getCache<String>(key: _inputValueKey);

    _searchInputController = widget.controller..text = cachedInput ?? '';
    // _searchInputController = TextEditingController(text: cachedInput);
    _searchInputController.addListener(_inputChangeListener);

    _cancellEditionAnimationController.addStatusListener(_statusListener);

    if (_searchInputController.text.isEmpty) {
      _searchFocusNode.requestFocus();
    } else {
      if (_cancellEditionAnimationController.status ==
          AnimationStatus.dismissed) {
        _cancellEditionAnimationController.forward();
      }
    }

    super.initState();
  }

  @override
  PreferredSizeWidget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: Icon(Icons.arrow_back),
      ),
      automaticallyImplyLeading: false,
      actions: [
        ScaleTransition(
          scale: _cancellEditionAnimation,
          child: IconButton(
            onPressed: () {
              _searchInputController.clear();
              _searchFocusNode.requestFocus();
              // _cancellEditionAnimationController.reverse();
            },
            icon: Icon(Icons.close),
          ),
        ),
      ],
      title: _input,
    );
  }

  Widget get _input {
    return Form(
      key: _formKey,
      child: TypeAheadFormField<MovieSearchAutocomplete>(
        key: PageStorageKey('search-input'),
        keepSuggestionsOnSuggestionSelected: true,
        hideSuggestionsOnKeyboardHide: true,
        // enabled: true,
        suggestionsBoxController: _suggestionsBoxController,
        textFieldConfiguration: TextFieldConfiguration(
          // autofocus: true,
          controller: _searchInputController,
          focusNode: _searchFocusNode,
          textInputAction: TextInputAction.search,
          keyboardType: TextInputType.text,
          onSubmitted: (_) async {
            try {
              widget.onSearch();
              _searchFocusNode.unfocus();
              if (widget.onScrollToTop != null) {
                widget.onScrollToTop!();
              }
            } catch (e) {
              print(e);
            }
          },
          enabled: true,
          decoration: const InputDecoration(
            hintText: 'Search',
            contentPadding: EdgeInsets.all(4.0),
          ),
          style: TextStyle(
            color: Theme.of(context).inputDecorationTheme.hintStyle?.color,
          ),
        ),
        suggestionsCallback: _suggestionsCallback,
        itemBuilder: (context, movie) => ListTile(
          leading: MovieImage(src: movie.avatar),
          title: Text(movie.title),
        ),
        onSuggestionSelected: _onSuggestionSelected,
        noItemsFoundBuilder: (context) => Center(
          child: Text('No match found!'),
        ),
        errorBuilder: (context, error) => Text(
          error.toString(),
          style: TextStyle(color: Theme.of(context).errorColor),
        ),
        loadingBuilder: (_) => Center(
          child: CircularProgressIndicator(),
        ),
        transitionBuilder: (context, suggestionsBox, animationController) {
          return FadeTransition(
            child: SizeTransition(
              child: suggestionsBox,
              sizeFactor: CurvedAnimation(
                  parent: animationController!, curve: Curves.fastOutSlowIn),
            ),
            opacity: CurvedAnimation(
              parent: animationController,
              curve: Curves.fastOutSlowIn,
            ),
          );
        },
      ),
    );
  }

  // Callbacks
  FutureOr<Iterable<MovieSearchAutocomplete>> _suggestionsCallback(
      String pattern) async {
    try {
      final uri = Uri.https('yts.mx', '/api/v2/list_movies.json', {
        'query_term': pattern,
      });
      final data = await widget.onSuggest(uri);
      final movies = data['movies'] as List? ?? [];
      return movies
          .take(5)
          .map((movie) => MovieSearchAutocomplete.fromJSON(movie));
    } catch (e) {
      throw e;
    }
  }

  void _onSuggestionSelected(MovieSearchAutocomplete movie) async {
    try {
      await Navigator.of(context).pushNamed(
        MoviePage.routeName,
        arguments: MovieArg(Movie.fromJSON(movie.raw)),
      );
    } catch (e) {
      print(e);
    }
  }

  // Event listeners
  void _statusListener(AnimationStatus status) {
    if (status == AnimationStatus.completed ||
        status == AnimationStatus.dismissed) {
      _suggestionsBoxController.resize();
    }
  }

  void _inputChangeListener() {
    if (_searchInputController.text.isEmpty ||
        _searchInputController.text == '') {
      if (_cancellEditionAnimationController.status ==
          AnimationStatus.completed) {
        _cancellEditionAnimationController.reverse();
      }
    } else {
      if (_cancellEditionAnimationController.status ==
          AnimationStatus.dismissed) {
        _cancellEditionAnimationController.forward();
      }
    }
  }

  @override
  void dispose() {
    setCache<String>(key: _inputValueKey, data: _searchInputController.text);
    _cancellEditionAnimationController.removeStatusListener(_statusListener);

    _cancellEditionAnimationController.dispose();
    _suggestionsBoxController.close();
    // _searchInputController.dispose();
    super.dispose();
  }
}
