part of 'index.dart';

class ShowMoreButton extends StatelessWidget {
  final void Function()? onPressed;
  final double radius;
  const ShowMoreButton({
    super.key,
    required this.onPressed,
    this.radius = 30,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      alignment: Alignment.center,
      child: Container(
        width: radius * 2,
        height: radius * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.deepPurple.withAlpha((0.8 * 255).toInt()),
              Colors.indigo.withAlpha((0.8 * 255).toInt()),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.deepPurple.withAlpha((0.3 * 255).toInt()),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: onPressed,
            customBorder: const CircleBorder(),
            child: const Center(
              child: Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
