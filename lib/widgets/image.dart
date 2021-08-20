import 'package:flutter/material.dart';

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
    this.alignment,
    Decoration? decoration,
    this.label,
    this.id,
    this.height,
  })  : _key = ValueKey(id),
        super(key: key) {
    _decoration = decoration ??
        BoxDecoration(
          borderRadius: BorderRadius.circular(4.0),
          // color: color,
        );
  }

  static final _colorTween = ColorTween(begin: Colors.red, end: Colors.green);

  @override
  Widget build(BuildContext context) {
    return Image.network(
      this.src,
      key: _key,
      cacheHeight: 300,
      cacheWidth: 200,
      fit: BoxFit.cover,
      semanticLabel: label,
      height: height,
      frameBuilder: (
        ctx,
        child,
        frame,
        wasSynchronouslyLoaded,
      ) {
        return Hero(
          key: _key,
          tag: 'movie-$id',
          transitionOnUserGestures: true,
          child: _container(
            child: child,
          ),
        );
      },
      errorBuilder: (c, error, _) {
        print('An error occurred loading "$src"');
        print(error);
        return const Center(
          child: Icon(
            Icons.image,
            size: 48,
          ),
        );
      },
      loadingBuilder: (
        context,
        child,
        loadingProgress,
      ) {
        if (loadingProgress == null) {
          return child;
        }
        final progress = loadingProgress.cumulativeBytesLoaded /
            loadingProgress.expectedTotalBytes!;

        return _container(
          child: Center(
            child: CircularProgressIndicator(
              value:
                  loadingProgress.expectedTotalBytes != null ? progress : null,
              color: _colorTween.transform(progress),
            ),
          ),
        );
      },
    );
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
