part of app_widgets.button;

class ShowMoreButton extends StatelessWidget {
  final void Function()? onPressed;
  final double radius;
  const ShowMoreButton({
    Key? key,
    required this.onPressed,
    this.radius = 30,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      alignment: Alignment.center,
      child: SizedBox(
        width: radius * 2,
        child: Material(
          elevation: 4,
          color: Colors.grey,
          type: MaterialType.circle,
          child: IconButton(
            onPressed: onPressed,
            icon: const Icon(Icons.arrow_forward),
            splashRadius: 24,
            iconSize: 32,
            enableFeedback: false,
          ),
        ),
      ),
    );
  }
}
