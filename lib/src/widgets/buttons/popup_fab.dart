part of 'index.dart';

class PopupFloatingActionButton extends StatefulWidget {
  final FutureOr<void> Function()? onScrollToTop;
  final ScrollController scrollController;
  const PopupFloatingActionButton({
    super.key,
    required this.scrollController,
    this.onScrollToTop,
  });

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
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _fabScaleController,
      child: AnimatedBuilder(
        animation: _animationController,
        child: Icon(
          Icons.keyboard_arrow_up_rounded,
          color: Colors.white,
          size: 28,
        ),
        builder: (context, child) {
          final val = _animationController.value;
          final angle = val * 2 * pi;
          return val == 0
              ? const SizedBox.shrink()
              : Transform.translate(
                  offset: Offset(0, sin(angle) * 3.0),
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
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.secondary,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16.0),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary
                            .withAlpha((0.4 * 255).toInt()),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(16.0),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16.0),
                      onTap: () async {
                        try {
                          await widget.scrollController.animateTo(
                            0,
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOutCubic,
                          );
                        } catch (e, s) {
                          log(e.toString(), error: e, stackTrace: s);
                        }
                      },
                      child: Container(
                        width: 56,
                        height: 56,
                        alignment: Alignment.center,
                        child: child!,
                      ),
                    ),
                  ),
                ),
              );
      },
    );
  }

  void _popupFabScrollListener() {
    final controller = widget.scrollController;
    final dir = widget.scrollController.position.userScrollDirection;

    if (controller.offset >= 600) {
      if (dir == ScrollDirection.reverse) {
        if (_fabScaleController.status == AnimationStatus.completed) {
          _fabScaleController.reverse();
          _animationController.stop();
        }
      }
      if (dir == ScrollDirection.forward) {
        if (_fabScaleController.status == AnimationStatus.dismissed) {
          _fabScaleController.forward();
          _animationController.repeat();
        }
      }
    } else {
      if (_fabScaleController.status == AnimationStatus.completed) {
        _fabScaleController.reverse();
        _animationController.stop();
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
