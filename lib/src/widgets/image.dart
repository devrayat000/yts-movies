part of app_widgets;

class MovieImage extends StatelessWidget {
  final String src;
  final String? label;
  final String? id;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Alignment? alignment;

  late final Decoration? _decoration;

  late final Key _key;

  MovieImage({
    super.key,
    required this.src,
    this.padding = EdgeInsets.zero,
    this.margin = EdgeInsets.zero,
    this.alignment = Alignment.center,
    Decoration? decoration,
    this.label,
    this.id,
    this.height,
  }) : _key = ValueKey(id) {
    _decoration = decoration ??
        BoxDecoration(
          borderRadius: BorderRadius.circular(4.0),
        );
  }

  static Color? _colorTween(double value) =>
      Color.lerp(Colors.red, Colors.green, value);

  @override
  Widget build(BuildContext context) {
    return Hero(
      key: _key,
      tag: 'movie-$id',
      transitionOnUserGestures: true,
      child: _container(
        child: CachedNetworkImage(
          // src,
          imageUrl: src,
          cacheKey: id,
          fit: BoxFit.cover,
          height: height,
          progressIndicatorBuilder: (context, url, downloadProgress) {
            return Center(
              child: CircularProgressIndicator(
                value: downloadProgress.progress,
                color: _colorTween(downloadProgress.progress ?? 0.0),
              ),
            );
          },
          errorWidget: (context, url, error) {
            log(error.toString(), error: error);

            return const Center(
              child: Icon(
                Icons.image,
                size: 60,
              ),
            );
          },
          maxHeightDiskCache: 300,
          maxWidthDiskCache: 200,
          memCacheHeight: 150,
          memCacheWidth: 100,
        ),
      ),
    );
  }

  Widget _container({
    required Widget child,
  }) {
    return Container(
      width: 136,
      padding: padding,
      margin: margin,
      alignment: alignment,
      decoration: _decoration,
      child: AspectRatio(
        aspectRatio: 0.67,
        child: ClipRRect(
          borderRadius: BorderRadiusGeometry.circular(12.0),
          child: child,
        ),
      ),
    );
  }
}
