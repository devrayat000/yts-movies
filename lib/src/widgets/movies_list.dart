import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
    Key? key,
    required this.actions,
    required this.handler,
    this.appBar,
    this.label = '',
    this.endDrawer,
    this.noItemBuilder,
  }) : super(key: key);

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
    _pagingController = PagingController(firstPageKey: 1);
    _pagingController.addPageRequestListener(_fetchPage);
    _pagingController.addStatusListener(_pageStatusListener);
  }

  @override
  void didUpdateWidget(covariant MoviesList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.handler != widget.handler) {
      _pagingController.removePageRequestListener(oldWidget.handler);
      _pagingController.addPageRequestListener(widget.handler);
    }
  }

  @override
  void dispose() {
    _pagingController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Event listeners
  void _pageStatusListener(PagingStatus status) {
    if (status == PagingStatus.subsequentPageError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Something went wrong while fetching movies.',
          ),
          action: SnackBarAction(
            label: 'Retry',
            onPressed: _pagingController.retryLastFailedRequest,
          ),
        ),
      );
    }
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final response = await widget.handler(pageKey);
      final isLastPage = response.data.isLastPage;
      if (isLastPage) {
        _pagingController.appendLastPage(response.data.movies ?? []);
      } else {
        final nextPageKey = (response.data.pageNumber) + 1;
        _pagingController.appendPage(response.data.movies ?? [], nextPageKey);
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
            onRefresh: () => Future.sync(_pagingController.refresh),
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
                  shrinkWrapFirstPageIndicators: true,
                  builderDelegate: PagedChildBuilderDelegate(
                    itemBuilder: (context, item, index) {
                      return MovieCard.list(
                        key: ValueKey('movie-${item.id}'),
                        movie: item,
                      );
                    },
                    firstPageProgressIndicatorBuilder: (_) =>
                        const MovieListShimmer(),
                    newPageProgressIndicatorBuilder: (_) =>
                        MyGlobals.kCircularLoading,
                    firstPageErrorIndicatorBuilder: _firstPageErrorIndicator,
                    newPageErrorIndicatorBuilder: _newPageErrorIndicator,
                    noItemsFoundIndicatorBuilder:
                        widget.noItemBuilder ?? _noItemsFoundIndicator,
                    noMoreItemsIndicatorBuilder: _noMoreItemsIndicator,
                    animateTransitions: true,
                  ),
                  itemExtent: MediaQuery.of(context).size.width * 4 / 9,
                  // gridDelegate: _gridDelegrate(1, 9 / 4),
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
    final error = CustomException.getCustomError(_pagingController.error);

    return Column(
      children: [
        Text(error),
        TextButton(
          onPressed: _pagingController.retryLastFailedRequest,
          child: const Text('Retry'),
        ),
      ],
    );
  }

  Widget _firstPageErrorIndicator(BuildContext context) {
    final error = CustomException.getCustomError(_pagingController.error);

    return Column(
      children: [
        Text(error),
        TextButton(
          onPressed: _pagingController.refresh,
          child: const Text('Retry'),
        ),
      ],
    );
  }

  Widget _noItemsFoundIndicator(BuildContext context) => Container(
        alignment: Alignment.topCenter,
        child: Text(
          'No movie found',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      );

  Widget _noMoreItemsIndicator(BuildContext context) => Center(
        child: Text(
          'That\'s the last of it.',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      );
}
