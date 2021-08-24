part of app_widget.button;

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
      child: SizedBox(
        child: Material(
          child: IconButton(
            onPressed: onPressed,
            icon: Icon(Icons.arrow_forward),
            splashRadius: 24,
            iconSize: 32,
            enableFeedback: false,
          ),
          elevation: 4,
          color: Colors.grey,
          type: MaterialType.circle,
        ),
        width: radius * 2,
      ),
      width: 100,
      alignment: Alignment.center,
    );
  }
}
