import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

class MovieImage extends StatelessWidget {
  final String src;
  final double padding;
  final Color? color;
  final String? label;
  final String? id;
  final double? height;

  const MovieImage({
    Key? key,
    required this.src,
    this.padding = 0.0,
    this.color,
    this.label,
    this.id,
    this.height,
  }) : super(key: key);

  static final _colorTween = ColorTween(begin: Colors.red, end: Colors.green);

  @override
  Widget build(BuildContext context) {
    return Image.network(
      this.src,
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
          tag: 'movie-$id',
          child: _container(
            child: child,
            padding: EdgeInsets.all(padding),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4.0),
              // color: color,
            ),
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
        return AspectRatio(
          aspectRatio: 2 / 3,
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
    Decoration? decoration,
    Color? color,
    EdgeInsetsGeometry? padding,
  }) {
    return Container(
      child: AspectRatio(
        aspectRatio: 2 / 3,
        child: child,
      ),
      padding: padding,
      decoration: decoration,
      color: color,
    );
  }
}
