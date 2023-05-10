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
    Key? key,
    required this.src,
    this.padding = EdgeInsets.zero,
    this.margin = EdgeInsets.zero,
    this.alignment = Alignment.center,
    Decoration? decoration,
    this.label,
    this.id,
    this.height,
  })  : _key = ValueKey(id),
        super(key: key) {
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
    // return Image.network(
    //   this.src,
    //   key: _key,
    //   cacheHeight: 300,
    //   cacheWidth: 200,
    //   fit: BoxFit.cover,
    //   semanticLabel: label,
    //   height: height,
    //   frameBuilder: (
    //     ctx,
    //     child,
    //     frame,
    //     wasSynchronouslyLoaded,
    //   ) {
    //     return Hero(
    //       key: _key,
    //       tag: 'movie-$id',
    //       transitionOnUserGestures: true,
    //       child: _container(
    //         child: child,
    //       ),
    //     );
    //   },
    //   errorBuilder: (c, error, _) {
    //     debugPrint('An error occurred loading "$src"');
    //     debugPrint(error);
    //     return const Center(
    //       child: Icon(
    //         Icons.image,
    //         size: 48,
    //       ),
    //     );
    //   },
    //   loadingBuilder: (
    //     context,
    //     child,
    //     loadingProgress,
    //   ) {
    //     if (loadingProgress == null) {
    //       return child;
    //     }
    //     final progress = loadingProgress.cumulativeBytesLoaded /
    //         loadingProgress.expectedTotalBytes!;

    //     return _container(
    //       child: Center(
    //         child: CircularProgressIndicator(
    //           value:
    //               loadingProgress.expectedTotalBytes != null ? progress : null,
    //           color: _colorTween(progress),
    //         ),
    //       ),
    //     );
    //   },
    // );
  }

  Widget _container({
    required Widget child,
  }) {
    return Container(
      child: AspectRatio(
        aspectRatio: 2 / 3,
        child: child,
      ),
      padding: padding,
      margin: margin,
      alignment: alignment,
      decoration: _decoration,
    );
  }
}
