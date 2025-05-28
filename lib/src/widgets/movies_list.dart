import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:ytsmovies/src/models/index.dart';
import 'package:ytsmovies/src/utils/index.dart';
import 'package:ytsmovies/src/widgets/index.dart';

typedef ApiHandler<T> = Future<T> Function(int page);

class MoviesList extends StatefulWidget {
  final List<Widget> actions;
  final ApiHandler<MovieListResponse> handler;
  final PreferredSizeWidget? appBar;
  final String label;
  final Widget? endDrawer;
  final WidgetBuilder? noItemBuilder;

  const MoviesList({
    super.key,
    required this.actions,
    required this.handler,
    this.appBar,
    this.label = '',
    this.endDrawer,
    this.noItemBuilder,
  });

  @override
  MoviesListState createState() => MoviesListState();
}

class MoviesListState extends State<MoviesList> {
  late PagingController<int, Movie> _pagingController;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController(debugLabel: 'scroll-popup');
    _pagingController = PagingController<int, Movie>(firstPageKey: 1);
    _pagingController.addPageRequestListener(_fetchPage);
  }

  @override
  void didUpdateWidget(covariant MoviesList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.handler != widget.handler) {
      _pagingController.refresh();
    }
  }

  @override
  void dispose() {
    _pagingController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _fetchPage(int pageKey) async {
    try {
      final response = await widget.handler(pageKey);
      final isLastPage = response.data.isLastPage;
      final movies = response.data.movies ?? [];

      if (isLastPage) {
        _pagingController.appendLastPage(movies);
      } else {
        _pagingController.appendPage(movies, pageKey + 1);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.appBar,
      endDrawer: widget.endDrawer,
      body: Container(
        height: double.infinity,
        margin: const EdgeInsets.all(8.0),
        child: CupertinoScrollbar(
          controller: _scrollController,
          child: RefreshIndicator(
            onRefresh: () => SynchronousFuture(null),
            child: CustomScrollView(
              controller: _scrollController,
              key: PageStorageKey(widget.label),
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              slivers: [
                if (widget.actions.isNotEmpty)
                  SliverActionBar(
                    actions: widget.actions,
                    floating: true,
                    snap: true,
                  ),
                PagedSliverList<int, Movie>(
                  pagingController: _pagingController,
                  builderDelegate: PagedChildBuilderDelegate(
                    itemBuilder: (context, item, index) {
                      return MovieCard.list(
                        key: ValueKey('movie-${item.id}'),
                        movie: item,
                      );
                    },
                    firstPageProgressIndicatorBuilder: (_) =>
                        MyGlobals.kCircularLoading,
                    newPageProgressIndicatorBuilder: (_) =>
                        MyGlobals.kCircularLoading,
                    firstPageErrorIndicatorBuilder: _firstPageErrorIndicator,
                    newPageErrorIndicatorBuilder: _newPageErrorIndicator,
                    noItemsFoundIndicatorBuilder:
                        widget.noItemBuilder ?? _noItemsFoundIndicator,
                    noMoreItemsIndicatorBuilder: _noMoreItemsIndicator,
                    animateTransitions: true,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: PopupFloatingActionButton(
        scrollController: _scrollController,
      ),
    );
  }

  Widget _newPageErrorIndicator(BuildContext context) {
    final error = _pagingController.error != null
        ? CustomException.getCustomError(_pagingController.error!)
        : 'Unknown error';

    return Column(
      children: [
        Text(error),
        TextButton(
          onPressed: () => _pagingController.retryLastFailedRequest(),
          child: const Text('Retry'),
        ),
      ],
    );
  }

  Widget _firstPageErrorIndicator(BuildContext context) {
    final error = _pagingController.error != null
        ? CustomException.getCustomError(_pagingController.error!)
        : 'Unknown error';

    return Column(
      children: [
        Text(error),
        TextButton(
          onPressed: () => _pagingController.refresh(),
          child: const Text('Retry'),
        ),
      ],
    );
  }

  Widget _noItemsFoundIndicator(BuildContext context) => Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'No movie found',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color:
                        Theme.of(context).colorScheme.onSurface.withAlpha(120),
                  ),
            ),
            const SizedBox(height: 8.0),
            Text(
              "Your favourite movies aren't here yet.",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color:
                        Theme.of(context).colorScheme.onSurface.withAlpha(200),
                  ),
            ),
          ],
        ),
      );

  Widget _noMoreItemsIndicator(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 28.0),
        child: Center(
          child: Text(
            'That\'s the last of it.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      );
}
