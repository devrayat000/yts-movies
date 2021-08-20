import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

class PopupFloatingActionButton extends StatefulWidget {
  final FutureOr<void> Function()? onScrollToTop;
  const PopupFloatingActionButton({Key? key, this.onScrollToTop})
      : super(key: key);

  @override
  PopupFloatingActionButtonState createState() =>
      PopupFloatingActionButtonState();
}

class PopupFloatingActionButtonState extends State<PopupFloatingActionButton>
    with SingleTickerProviderStateMixin<PopupFloatingActionButton> {
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      tooltip: 'Scroll To Top',
      child: AnimatedBuilder(
        animation: _animationController,
        child: const Icon(Icons.arrow_upward),
        builder: (context, child) {
          final val = _animationController.value;
          final angle = val * 2 * pi;
          return Transform.translate(
            offset: Offset(0, sin(angle) * 5.0),
            child: child!,
          );
        },
      ),
      backgroundColor: const Color.fromRGBO(120, 120, 120, 1),
      onPressed: () async {
        try {
          await widget.onScrollToTop?.call();
        } catch (e) {
          print(e);
        }
      },
    );
  }

  // Public methods
  void start() {
    _animationController.repeat();
  }

  void stop() {
    _animationController..stop();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
