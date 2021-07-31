import 'package:flutter/material.dart' show FloatingActionButton, Icons;
import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';

class PopupFloatingActionButton extends StatefulWidget {
  final void Function()? onScrollToTop;
  const PopupFloatingActionButton({Key? key, this.onScrollToTop})
      : super(key: key);

  @override
  PopupFloatingActionButtonState createState() =>
      PopupFloatingActionButtonState();
}

class PopupFloatingActionButtonState extends State<PopupFloatingActionButton>
    with SingleTickerProviderStateMixin<PopupFloatingActionButton> {
  late final AnimationController _animationController;
  late final Animation<Offset> _animation;
  static final _tween = Tween<Offset>(begin: Offset(0, -5), end: Offset(0, 5));

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _animation = _animationController.drive(
      _tween.chain(CurveTween(curve: Curves.easeInOut)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      tooltip: 'Scroll To Top',
      child: TranslateTransition(
        offset: _animation,
        child: const Icon(Icons.arrow_upward),
      ),
      backgroundColor: const Color.fromRGBO(120, 120, 120, 1),
      onPressed: () async {
        try {
          if (widget.onScrollToTop != null) {
            widget.onScrollToTop!();
          }
        } catch (e) {
          print(e);
        }
      },
    );
  }

  // Public methods
  void start() {
    _animationController.repeat(reverse: true);
  }

  void stop() {
    _animationController..stop();
  }

  @override
  void dispose() {
    // widget.controller.dispose();
    _animationController.dispose();
    super.dispose();
  }
}

class TranslateTransition extends AnimatedWidget {
  final Widget? _child;
  const TranslateTransition({
    Key? key,
    required Animation<Offset> offset,
    Widget? child,
  })  : _child = child,
        super(key: key, listenable: offset);

  Animation<Offset> get _progress => listenable as Animation<Offset>;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: _progress.value,
      child: _child,
    );
  }
}
