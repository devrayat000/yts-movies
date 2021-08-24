part of app_widgets;

class MamuMovieListpage<T extends ApiCubit> extends StatefulWidget {
  final List<Widget> actions;
  final T handler;
  final PreferredSizeWidget? appBar;
  final String label;
  final Widget? endDrawer;
  final WidgetBuilder? noItemBuilder;

  const MamuMovieListpage({
    Key? key,
    required this.actions,
    required this.handler,
    this.appBar,
    this.label = '',
    this.endDrawer,
    this.noItemBuilder,
  }) : super(key: key);

  @override
  _MamuMovieListpageState<T> createState() => _MamuMovieListpageState<T>();

  static _MamuMovieListpageState<T>? of<T extends ApiCubit>(
      BuildContext context) {
    return context.findAncestorStateOfType<_MamuMovieListpageState<T>>();
  }
}

class _MamuMovieListpageState<T extends ApiCubit>
    extends State<MamuMovieListpage<T>>
    with PageStorageCache<MamuMovieListpage<T>> {
  late PagingController<int, Movie> _pagingController;
  late ScrollController _scrollController;

  // late final ValueKey<String> _listKey;
  // late final ValueKey<String> _pageKey;

  @override
  void initState() {
    // _listKey = ValueKey('${widget.label}-movies');
    // _pageKey = ValueKey('${widget.label}-movie-page');

    _scrollController = ScrollController(debugLabel: 'scroll-popup');

    _pagingController = PagingController(firstPageKey: 1);
    // final pageKey = getCache<int>(key: _pageKey);
    // final movies = getCache<List<Movie>>(key: _listKey);

    // if (movies != null) {
    //   _pagingController.appendPage(movies, pageKey);
    // }

    _pagingController.addPageRequestListener(widget.handler.getMovies);

    _pagingController.addStatusListener(_pageStatusListener);
    super.initState();
  }

  @override
  void didUpdateWidget(covariant MamuMovieListpage<T> oldWidget) {
    if (oldWidget.handler != widget.handler) {
      _pagingController.removePageRequestListener(oldWidget.handler.getMovies);
      _pagingController.addPageRequestListener(widget.handler.getMovies);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    // setCache<List<Movie>>(key: _listKey, data: _pagingController.itemList);
    // setCache<int>(key: _pageKey, data: _pagingController.nextPageKey ?? 1);

    _pagingController.dispose();
    _scrollController.dispose();

    super.dispose();
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
            child: BlocListener<ApiCubit, PageState>(
              bloc: widget.handler,
              listener: (context, pageState) {
                _newPageListener(pageState);
              },
              child: CustomScrollView(
                controller: _scrollController,
                key: PageStorageKey(widget.label),
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                slivers: [
                  if (widget.actions.length != 0)
                    SliverActionBar(
                      actions: widget.actions,
                      floating: true,
                      snap: true,
                    ),
                  MovieList(
                    controller: _pagingController,
                    noItemBuilder: widget.noItemBuilder,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: PopupFloatingActionButton(
        scrollController: _scrollController,
      ),
    );
  }

  // Event listeners
  void _newPageListener(PageState pagingState) {
    if (pagingState is PageStateSuccess) {
      if (pagingState.isLast) {
        _pagingController.appendLastPage(pagingState.list);
      } else {
        _pagingController.appendPage(pagingState.list, pagingState.nextPage);
      }
    } else if (pagingState is PageStateError) {
      _pagingController.error = pagingState.error;
    }
  }

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
}
