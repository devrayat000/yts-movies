part of app_widgets.card;

class ShimmerShape extends StatelessWidget {
  late final _ShimmerShapes _shape;

  final double? height;
  final int? count;

  ShimmerShape.image({Key? key})
      : _shape = _ShimmerShapes.IMAGE,
        height = null,
        count = null,
        super(key: key);

  ShimmerShape.title({Key? key, required this.height})
      : _shape = _ShimmerShapes.TITLE,
        count = null,
        super(key: key);

  ShimmerShape.desc({Key? key, required this.height, required this.count})
      : _shape = _ShimmerShapes.DESC,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (_shape) {
      case _ShimmerShapes.IMAGE:
        return _image(context);
      case _ShimmerShapes.TITLE:
        return _title(context);
      case _ShimmerShapes.DESC:
        return Column(children: _desc(context));
      default:
        return _image(context);
    }
  }

  Widget _image(BuildContext context) => LimitedBox(
        maxHeight: 170,
        child: AspectRatio(
          aspectRatio: 2 / 3,
          child: ColoredBox(color: Theme.of(context).colorScheme.onSurface),
        ),
      );

  Widget _title(BuildContext context) => Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              width: double.infinity,
              height: height,
              decoration: _decoration(context),
            ),
            SizedBox(height: height),
            FractionallySizedBox(
              widthFactor: 0.7,
              child: Container(
                height: height,
                decoration: _decoration(context),
              ),
            ),
          ],
        ),
      );

  List<Widget> _desc(BuildContext context) => [
        ...List.generate(
          count ?? 0,
          (i) => Container(
            height: height,
            margin: EdgeInsets.symmetric(vertical: 4.0),
            decoration: _decoration(context),
          ),
        ),
        FractionallySizedBox(
          widthFactor: 0.6,
          child: Container(
            height: height,
            margin: EdgeInsets.symmetric(vertical: 4.0),
            decoration: _decoration(context),
          ),
        ),
      ];

  Decoration _decoration(BuildContext context) => BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface,
        borderRadius: BorderRadius.circular(4 + (height ?? 0)),
      );
}

enum _ShimmerShapes { IMAGE, TITLE, DESC }
