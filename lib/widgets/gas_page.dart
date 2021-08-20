import 'dart:async';

import 'package:flutter/cupertino.dart' show CupertinoScrollbar;
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:ytsmovies/bloc/api/index.dart';

import '../utils/constants.dart';
import '../mock/movie.dart';
import 'package:ytsmovies/widgets/cards/movie_card.dart';
import './cards/actionbar.dart';
import './cards/shimmer_movie_card.dart';
import './buttons/popup_fab.dart';
import '../utils/mixins.dart';

class MamuMovieListpage<T extends ApiBloc> extends StatefulWidget {
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
  MamuMovieListpageState<T> createState() => MamuMovieListpageState<T>();

  static MamuMovieListpageState<T>? of<T extends ApiBloc>(
      BuildContext context) {
    return context.findAncestorStateOfType<MamuMovieListpageState<T>>();
  }
}

class MamuMovieListpageState<T extends ApiBloc>
    extends State<MamuMovieListpage<T>>
    with
        PageStorageCache<MamuMovieListpage<T>>,
        SingleTickerProviderStateMixin<MamuMovieListpage<T>> {
  late PagingController<int, Movie> _pagingController;
  late ScrollController _scrollController;
  late AnimationController _fabScaleController;

  late final ValueKey<String> _listKey;
  late final ValueKey<String> _pageKey;

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _fabKey = GlobalKey<PopupFloatingActionButtonState>();

  @override
  void initState() {
    _listKey = ValueKey('${widget.label}-movies');
    _pageKey = ValueKey('${widget.label}-movie-page');

    _scrollController = ScrollController();

    _pagingController = PagingController(firstPageKey: 1);
    // final pageKey = getCache<int>(key: _pageKey);
    // final movies = getCache<List<Movie>>(key: _listKey);

    // if (movies != null) {
    //   _pagingController.appendPage(movies, pageKey);
    // }
    _fabScaleController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );

    _pagingController.addPageRequestListener(widget.handler.add);

    _pagingController.addStatusListener(_pageStatusListener);

    _scrollController.addListener(_popupFabScrollListener);
    super.initState();
  }

  @override
  void dispose() {
    // setCache<List<Movie>>(key: _listKey, data: _pagingController.itemList);
    // setCache<int>(key: _pageKey, data: _pagingController.nextPageKey ?? 1);

    _pagingController.dispose();
    _fabScaleController.dispose();
    _scrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: widget.appBar,
      endDrawer: widget.endDrawer,
      body: Container(
        height: double.infinity,
        margin: const EdgeInsets.all(8.0),
        child: CupertinoScrollbar(
          controller: _scrollController,
          child: RefreshIndicator(
            onRefresh: () => Future.sync(_pagingController.refresh),
            child: BlocListener<ApiBloc, PageState>(
              bloc: widget.handler,
              listener: (context, pageState) {
                _newPageListener(pageState);
              },
              child: CustomScrollView(
                controller: _scrollController,
                key: PageStorageKey(widget.label),
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics()),
                slivers: [
                  if (widget.actions.length != 0)
                    SliverActionBar(
                      actions: widget.actions,
                      floating: true,
                      snap: true,
                    ),
                  _pageGrid,
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: ScaleTransition(
        scale: CurvedAnimation(
          parent: _fabScaleController,
          curve: Curves.easeInOut,
        ),
        child: PopupFloatingActionButton(key: _fabKey),
      ),
    );
  }

  SliverGridDelegate _gridDelegrate(int crossAxis, double aspectRatio) =>
      SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxis,
        childAspectRatio: aspectRatio,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      );

  Widget get _pageGrid => PagedSliverGrid<int, Movie>(
        shrinkWrapFirstPageIndicators: true,
        pagingController: _pagingController,
        builderDelegate: PagedChildBuilderDelegate(
          itemBuilder: (context, item, index) {
            return MovieCard(
              key: ValueKey('movie-${item.id}'),
              movie: item,
            );
          },
          firstPageErrorIndicatorBuilder: _firstPageErrorIndicator,
          newPageErrorIndicatorBuilder: _newPageErrorIndicator,
          firstPageProgressIndicatorBuilder: (_) => _shimmer,
          newPageProgressIndicatorBuilder: (_) => MyGlobals.kCircularLoading,
          noItemsFoundIndicatorBuilder:
              widget.noItemBuilder ?? _noItemsFoundIndicator,
          noMoreItemsIndicatorBuilder: _noMoreItemsIndicator,
          animateTransitions: true,
        ),
        gridDelegate: _gridDelegrate(1, 9 / 4),
      );

  Widget _newPageErrorIndicator(BuildContext context) => Column(
        children: [
          Text(_pagingController.error.toString()),
          TextButton(
            onPressed: _pagingController.retryLastFailedRequest,
            child: const Text('Retry'),
          ),
        ],
      );

  Widget _firstPageErrorIndicator(BuildContext context) => Column(
        children: [
          Text(_pagingController.error.toString()),
          TextButton(
            onPressed: _pagingController.refresh,
            child: const Text('Retry'),
          ),
        ],
      );

  Widget _noItemsFoundIndicator(BuildContext context) => Center(
        child: Text('No movie found'),
      );
  Widget _noMoreItemsIndicator(BuildContext context) => Center(
        child: Text(
          'That\'s the last of it.',
          style: Theme.of(context).textTheme.headline5,
        ),
      );

  void refresh() => _pagingController.refresh();

  void scrollToTop() {
    // var _offset = _scrollController.offset;
    _scrollController.animateTo(
      0,
      duration: Duration(milliseconds: 400),
      curve: Curves.linear,
    );
  }

  ScrollController get scrollController => _scrollController;
  ScaffoldState? get scaffoldState => _scaffoldKey.currentState;

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

  void _popupFabScrollListener() {
    final _dir = _scrollController.position.userScrollDirection;
    if (_scrollController.offset >= 600) {
      if (_dir == ScrollDirection.reverse) {
        if (_fabScaleController.status == AnimationStatus.completed) {
          _fabScaleController.reverse();
          _fabKey.currentState?.stop();
        }
      }
      if (_dir == ScrollDirection.forward) {
        if (_fabScaleController.status == AnimationStatus.dismissed) {
          _fabScaleController.forward();
          _fabKey.currentState?.start();
        }
      }
    } else {
      if (_fabScaleController.status == AnimationStatus.completed) {
        _fabScaleController.reverse();
        _fabKey.currentState?.stop();
      }
    }
  }

  static const _shimmer = const MovieListShimmer();
}
