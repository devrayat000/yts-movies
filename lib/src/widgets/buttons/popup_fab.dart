part of app_widgets.button;

class PopupFloatingActionButton extends StatefulWidget {
  final FutureOr<void> Function()? onScrollToTop;
  final ScrollController scrollController;
  const PopupFloatingActionButton({
    Key? key,
    required this.scrollController,
    this.onScrollToTop,
  }) : super(key: key);

  @override
  PopupFloatingActionButtonState createState() =>
      PopupFloatingActionButtonState();
}

class PopupFloatingActionButtonState extends State<PopupFloatingActionButton>
    with TickerProviderStateMixin<PopupFloatingActionButton> {
  late final AnimationController _animationController;
  late final AnimationController _fabScaleController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _fabScaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    if (widget.scrollController.hasClients) {
      widget.scrollController.addListener(_popupFabScrollListener);
    }
  }

  @override
  void didUpdateWidget(covariant PopupFloatingActionButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scrollController != widget.scrollController) {
      oldWidget.scrollController.removeListener(_popupFabScrollListener);
      widget.scrollController.addListener(_popupFabScrollListener);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _fabScaleController,
      child: AnimatedBuilder(
        animation: _animationController,
        child: const Icon(Icons.arrow_upward),
        builder: (context, child) {
          final val = _animationController.value;
          final angle = val * 2 * pi;
          return val == 0
              ? const SizedBox.shrink()
              : Transform.translate(
                  offset: Offset(0, sin(angle) * 5.0),
                  child: child!,
                );
        },
      ),
      builder: (context, child) {
        final val = _fabScaleController.value;
        return val == 0
            ? const SizedBox.shrink()
            : Transform.scale(
                scale: val,
                child: FloatingActionButton(
                  tooltip: 'Scroll To Top',
                  child: child!,
                  backgroundColor: const Color.fromRGBO(120, 120, 120, 1),
                  onPressed: () async {
                    try {
                      await widget.scrollController.animateTo(
                        0,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOutBack,
                      );
                    } catch (e, s) {
                      log(e.toString(), error: e, stackTrace: s);
                    }
                  },
                ),
              );
      },
    );
  }

  void _popupFabScrollListener() {
    final controller = widget.scrollController;
    final _dir = widget.scrollController.position.userScrollDirection;

    if (controller.offset >= 600) {
      if (_dir == ScrollDirection.reverse) {
        if (_fabScaleController.status == AnimationStatus.completed) {
          _fabScaleController.reverse();
          _animationController..stop();
        }
      }
      if (_dir == ScrollDirection.forward) {
        if (_fabScaleController.status == AnimationStatus.dismissed) {
          _fabScaleController.forward();
          _animationController.repeat();
        }
      }
    } else {
      if (_fabScaleController.status == AnimationStatus.completed) {
        _fabScaleController.reverse();
        _animationController..stop();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _fabScaleController.dispose();
    super.dispose();
  }
}
