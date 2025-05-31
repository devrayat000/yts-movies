part of 'index.dart';

class ThemeToggleButton extends StatefulWidget {
  const ThemeToggleButton({super.key});

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
      duration: const Duration(milliseconds: 250),
    );
  }

  @override
  void didChangeDependencies() {
    if (Theme.of(context).brightness == Brightness.dark) _controller.forward();

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: isDark
              ? [
                  const Color(0xFF374151).withAlpha((0.8 * 255).toInt()),
                  const Color(0xFF1F2937).withAlpha((0.8 * 255).toInt()),
                ]
              : [
                  Colors.white.withAlpha((0.9 * 255).toInt()),
                  Colors.grey[100]!.withAlpha((0.9 * 255).toInt()),
                ],
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withAlpha((0.2 * 255).toInt())
                : Colors.grey.withAlpha((0.1 * 255).toInt()),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () {
            if (_controller.status == AnimationStatus.dismissed) {
              _controller.forward();
            } else if (_controller.status == AnimationStatus.completed) {
              _controller.reverse();
            }
            context.read<ThemeCubit>().toggle();
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final range = cos(_controller.value * pi).abs();
                final scale = (range * 0.3) + 0.85;
                final rotation = _controller.value * pi;

                return Transform.scale(
                  scale: scale,
                  child: Transform.rotate(
                    angle: rotation,
                    child: Icon(
                      _controller.value > 0.5
                          ? Icons.light_mode_rounded
                          : Icons.dark_mode_rounded,
                      color: _controller.value > 0.5
                          ? Colors.amber[600]
                          : (isDark ? Colors.indigo[300] : Colors.indigo[600]),
                      size: 20,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
