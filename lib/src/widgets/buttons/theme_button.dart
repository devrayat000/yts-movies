part of app_widget.button;

class ThemeToggleButton extends StatefulWidget {
  const ThemeToggleButton({Key? key}) : super(key: key);

  @override
  _ThemeToggleButtonState createState() => _ThemeToggleButtonState();
}

class _ThemeToggleButtonState extends State<ThemeToggleButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 250),
    );
  }

  @override
  void didChangeDependencies() {
    if (Theme.of(context).brightness == Brightness.dark) _controller.forward();

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
        context.read<ThemeCubit>().toggle();
      },
      enableFeedback: false,
      icon: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final range = cos(_controller.value * pi).abs();
          final scale = (range * 0.7) + 0.3;

          return Transform.scale(
            scale: scale,
            child: Icon(
              _controller.value > 0.5
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode,
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
