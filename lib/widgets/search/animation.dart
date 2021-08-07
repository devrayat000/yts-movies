// import 'package:async/async.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import 'package:ytsmovies/utils/tweens.dart';
import 'package:ytsmovies/widgets/drawers/filter_drawer.dart';
import 'package:ytsmovies/widgets/search/results.dart';
import '../../models/movie.dart';

class SearchResultPage extends StatefulWidget {
  final PagingController<int, Movie> controller;
  final void Function() onFiltered;
  // final Widget filterDrawer;
  const SearchResultPage({
    Key? key,
    required this.controller,
    required this.onFiltered,
  }) : super(key: key);

  @override
  _SearchResultPageState createState() => _SearchResultPageState();
}

class _SearchResultPageState extends State<SearchResultPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late ScrollController _scrollController;

  late Animation<double> _sizeAnimation;
  late Animation<double> _drawerSizeAnimation;
  late Animation<double> _moveAnimation;
  late Animation<double> _fadeAnimation;
  late OverlayEntry _backdrop;

  static final double _maxSlide = -120;

  double get _openDragStartEdge => MediaQuery.of(context).size.width - 80;
  double get _closeDragStartEdge =>
      MediaQuery.of(context).size.width * 0.8 - _maxSlide;

  bool _canBeDragged = false;

  final link = LayerLink();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 250),
    );
    _scrollController = ScrollController();

    _sizeAnimation = _controller.drive(_screenSizeTween);
    _drawerSizeAnimation = _controller.drive(_drawerSizeTween);
    _moveAnimation = _controller.drive(_screenMoveTween);
    _fadeAnimation = _controller.drive(MyTween.zeroOne);

    _backdrop = OverlayEntry(builder: (context) {
      return Positioned(
        top: 0,
        left: 0,
        right: 0,
        bottom: 0,
        child: FadeTransition(
          opacity: _controller,
          child: Backdrop(
            onCloseOverlay: _close,
            link: link,
          ),
        ),
      );
    });

    _controller.addListener(() {
      _backdrop.markNeedsBuild();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    _scrollController.dispose();
    _backdrop.dispose();
  }

  void _toggle() async {
    if (_controller.isDismissed) {
      _controller.forward();
      Overlay.of(context)?.insert(_backdrop);
    } else {
      await _controller.reverse();
      _backdrop.remove();
    }
  }

  void _close() async {
    await _controller.reverse();
    _backdrop.remove();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            if (_controller.isCompleted) {
              _close();
            }
          },
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _drawerSizeAnimation,
              alignment: Alignment.centerRight,
              child: FilterDrawer(
                onApplyFilter: () {
                  if (_controller.isCompleted) {
                    _controller.reverse();
                  }
                  widget.onFiltered.call();
                },
              ),
            ),
          ),
        ),
        GestureDetector(
          onHorizontalDragStart: _onDragStart,
          onHorizontalDragUpdate: _onDragUpdate,
          onHorizontalDragEnd: _onDragEnd,
          child: AnimatedBuilder(
            animation: _controller,
            child: _searchResultStack,
            builder: (context, child) => Transform(
              transform: Matrix4.identity()
                ..translate(_moveAnimation.value)
                ..scale(_sizeAnimation.value),
              origin: const Offset(0, 0),
              alignment: Alignment.centerLeft,
              child: child,
            ),
          ),
        ),
      ],
    );
  }

  Widget get _searchResultStack => SearchResults(
        controller: widget.controller,
        link: link,
        onToggleFilter: _toggle,
      );

  void _onDragStart(DragStartDetails details) {
    bool isDragOpenFromRight = _controller.isDismissed &&
        details.globalPosition.dx > _openDragStartEdge;
    bool isDragCloseFromRight = _controller.isCompleted &&
        details.globalPosition.dx < _closeDragStartEdge;

    _canBeDragged = isDragOpenFromRight || isDragCloseFromRight;
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (_canBeDragged) {
      double delta = details.primaryDelta! / _maxSlide;
      _controller.value += delta;
    }
  }

  void _onDragEnd(DragEndDetails details) {
    if (_controller.isDismissed || _controller.isCompleted) {
      print('ops!');
      return;
    }
    print(_controller.value);
    print(details.velocity.pixelsPerSecond.dx.abs());
    if (details.velocity.pixelsPerSecond.dx.abs() >= 365.0) {
      double visualVelocity = details.velocity.pixelsPerSecond.dx /
          MediaQuery.of(context).size.width;
      _controller.fling(velocity: visualVelocity);
    } else if (_controller.value < 0.5) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
  }

  static final _screenSizeTween = Tween<double>(begin: 1, end: 0.7);
  static final _drawerSizeTween = Tween<double>(begin: 0.5, end: 1);
  static final _screenMoveTween = Tween<double>(begin: 0, end: _maxSlide);
}

class Backdrop extends StatelessWidget {
  final VoidCallback? onCloseOverlay;
  final LayerLink link;
  const Backdrop({
    Key? key,
    required this.onCloseOverlay,
    required this.link,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        print('ON TAP OVERLAY!');
        onCloseOverlay?.call();
      },
      child: CompositedTransformFollower(
        link: link,
        child: ColoredBox(
          color: Colors.black45,
        ),
      ),
    );
  }
}
