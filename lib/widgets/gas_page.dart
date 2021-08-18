import 'dart:async' show Future, StreamSubscription;

import 'package:flutter/cupertino.dart' show CupertinoScrollbar;
import 'package:flutter/foundation.dart' show Key, ValueKey;
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../utils/constants.dart' show MyGlobals;
import '../mock/movie.dart';
import '../providers/mamus_provider.dart' show Mamus, PageState;
import 'package:ytsmovies/widgets/cards/movie_card.dart';
import './cards/actionbar.dart' show SliverActionBar;
import './cards/shimmer_movie_card.dart' show MovieListShimmer;
import './buttons/popup_fab.dart';
import '../utils/mixins.dart' show PageStorageCache;
import '../utils/exceptions.dart' show NotFoundException;

class MamuMovieListpage<T extends Mamus> extends StatefulWidget {
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

  static MamuMovieListpageState<T>? of<T extends Mamus>(BuildContext context) {
    return context.findAncestorStateOfType<MamuMovieListpageState<T>>();
  }
}

class MamuMovieListpageState<T extends Mamus>
    extends State<MamuMovieListpage<T>>
    with
        PageStorageCache<MamuMovieListpage<T>>,
        SingleTickerProviderStateMixin<MamuMovieListpage<T>> {
  late PagingController<int, Movie> _pagingController;
  late ScrollController _scrollController;
  late AnimationController _fabScaleController;
  late Animation<double> _fabScaleAnimation;
  late StreamSubscription _subscription;
  late String _label;

  late final ValueKey<String> _listKey;
  late final ValueKey<String> _pageKey;

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _fabKey = GlobalKey<PopupFloatingActionButtonState>();

  static final _scaleTween = Tween<double>(begin: 0, end: 1);

  @override
  void initState() {
    _label = widget.label;
    _listKey = ValueKey('$_label-movies');
    _pageKey = ValueKey('$_label-movie-page');

    _scrollController = ScrollController();

    _pagingController = PagingController(firstPageKey: 1);
    final pageKey = getCache<int>(key: _pageKey);
    final movies = getCache<List<Movie>>(key: _listKey);

    if (movies != null) {
      _pagingController.appendPage(movies, pageKey);
    }
    _fabScaleController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );
    _fabScaleAnimation = _scaleTween.animate(CurvedAnimation(
      parent: _fabScaleController,
      curve: Curves.easeInOut,
    ));

    _pagingController.addPageRequestListener(widget.handler.pageRequesthandler);

    _subscription = widget.handler.state.listen(_newPageListener)
      ..onError((e) {
        if (e is NotFoundException) {
          _pagingController.error = e.message;
        } else {
          _pagingController.error = e;
        }
      });

    _pagingController.addStatusListener(_pageStatusListener);

    _scrollController.addListener(_popupFabScrollListener);
    super.initState();
  }

  @override
  void dispose() {
    setCache<List<Movie>>(key: _listKey, data: _pagingController.itemList);
    setCache<int>(key: _pageKey, data: _pagingController.nextPageKey ?? 1);

    _pagingController.dispose();
    _fabScaleController.dispose();
    _scrollController.dispose();
    _subscription.cancel();
    widget.handler.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant MamuMovieListpage<T> oldWidget) {
    if (oldWidget.handler != widget.handler) {
      if (oldWidget.handler.state != widget.handler.state) {
        _subscription.cancel();
        _subscription = widget.handler.state.listen(_newPageListener)
          ..onError((e) {
            if (e is NotFoundException) {
              _pagingController.error = e.message;
            } else {
              _pagingController.error = e;
            }
          });
      }
      _pagingController
          .removePageRequestListener(widget.handler.pageRequesthandler);
      _pagingController
          .addPageRequestListener(widget.handler.pageRequesthandler);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return PageStorage(
      bucket: MyGlobals.bucket,
      child: Scaffold(
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
              child: CustomScrollView(
                controller: _scrollController,
                key: PageStorageKey(_label),
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
        floatingActionButton: ScaleTransition(
          scale: _fabScaleAnimation,
          child: PopupFloatingActionButton(
            key: _fabKey,
          ),
        ),
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
    if (pagingState.isLast) {
      _pagingController.appendLastPage(pagingState.list);
    } else {
      _pagingController.appendPage(pagingState.list, pagingState.nextPage);
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
