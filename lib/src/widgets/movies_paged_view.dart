part of app_widgets;

class MoviesPagedView extends StatefulWidget {
  final ApiHandler<MovieListResponse> handler;
  final PagingController<int, Movie>? pagingController;
  final ScrollController? scrollController;
  final WidgetBuilder? noItemBuilder;
  final String? label;

  const MoviesPagedView({
    super.key,
    required this.handler,
    this.pagingController,
    this.scrollController,
    this.noItemBuilder,
    this.label,
  });

  @override
  State<MoviesPagedView> createState() => _MoviesPagedViewState();
}

class _MoviesPagedViewState extends State<MoviesPagedView> {
  late final PagingController<int, Movie> _pagingController;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    log("Initializing MoviesPagedView with label: ${widget.label ?? 'No label'}");
    _scrollController =
        widget.scrollController ?? ScrollController(debugLabel: 'scroll-popup');
    _pagingController = widget.pagingController ??
        PagingController<int, Movie>(firstPageKey: 1);
    _pagingController.addPageRequestListener(_fetchPage);
  }

  @override
  void didUpdateWidget(covariant MoviesPagedView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.handler != widget.handler) {
      _pagingController.refresh();
    }
  }

  @override
  void dispose() {
    try {
      _pagingController.dispose();
      if (widget.scrollController == null) {
        _scrollController.dispose();
      }
    } catch (e) {
      log(
        "Disposal error: $e",
        name: "MoviesPagedView",
        error: e,
        stackTrace: StackTrace.current,
      );
    } finally {
      super.dispose();
    }
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
    return CupertinoScrollbar(
      controller: _scrollController,
      child: RefreshIndicator(
        onRefresh: () => SynchronousFuture(_pagingController.refresh()),
        child: PagedGridView<int, Movie>(
          padding: const EdgeInsets.all(8.0),
          key: PageStorageKey(widget.label),
          pagingController: _pagingController,
          scrollController: _scrollController,
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio:
                0.67, // Slightly taller for better movie poster display
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          showNewPageProgressIndicatorAsGridChild: false,
          showNoMoreItemsIndicatorAsGridChild: false,
          builderDelegate: PagedChildBuilderDelegate(
            itemBuilder: (context, item, index) {
              return MovieCard.grid(
                key: ValueKey('movie-${item.id}'),
                movie: item,
              );
            },
            firstPageProgressIndicatorBuilder: (_) => const MovieListShimmer(),
            newPageProgressIndicatorBuilder: (_) => Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: const MovieListShimmer(count: 2),
            ),
            firstPageErrorIndicatorBuilder: _firstPageErrorIndicator,
            newPageErrorIndicatorBuilder: _newPageErrorIndicator,
            noItemsFoundIndicatorBuilder:
                widget.noItemBuilder ?? _noItemsFoundIndicator,
            noMoreItemsIndicatorBuilder: _noMoreItemsIndicator,
            animateTransitions: true,
          ),
        ),
      ),
    );
  }

  Widget _newPageErrorIndicator(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: CompactErrorWidget(
        error: _pagingController.error ?? 'Unknown error occurred',
        onRetry: () => _pagingController.retryLastFailedRequest(),
        customMessage: 'Failed to load more movies',
      ),
    );
  }

  Widget _firstPageErrorIndicator(BuildContext context) {
    return ErrorDisplayWidget(
      error: _pagingController.error ?? 'Unknown error occurred',
      onRetry: () => _pagingController.refresh(),
      customMessage: 'Failed to load movies',
    );
  }

  Widget _noItemsFoundIndicator(BuildContext context) => EmptyStateWidget(
        title: 'No Movies Found',
        subtitle: "Your favourite movies aren't here yet.",
        icon: Icons.movie_outlined,
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
