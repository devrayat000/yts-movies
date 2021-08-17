import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ytsmovies/bloc/theme_bloc.dart';
// import 'package:ytsmovies/theme/index.dart';

import '../../utils/tweens.dart';
import '../../theme/index.dart';

class ThemeToggleButton extends StatefulWidget {
  const ThemeToggleButton({Key? key}) : super(key: key);

  @override
  _ThemeToggleButtonState createState() => _ThemeToggleButtonState();
}

class _ThemeToggleButtonState extends State<ThemeToggleButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _sizeAnimation, _toggleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 250),
    );

    _sizeAnimation = _controller.drive(MyTween.wiggleShrink);
    _toggleAnimation = _controller.drive(MyTween.zeroOne);
  }

  @override
  void didChangeDependencies() {
    // if (context.read<AppTheme>().current == ThemeMode.dark)
    //   _controller.forward();
    if (context.read<ThemeBloc>().state == DarkTheme.dark)
      _controller.forward();

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        if (_controller.status == AnimationStatus.dismissed) {
          _controller.forward();
        } else if (_controller.status == AnimationStatus.completed) {
          _controller.reverse();
        }
        context.read<ThemeBloc>().toggle();
      },
      enableFeedback: false,
      icon: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Transform.scale(
          scale: _sizeAnimation.value,
          child: Icon(
            _toggleAnimation.value > 0.5
                ? Icons.light_mode_rounded
                : Icons.dark_mode,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
