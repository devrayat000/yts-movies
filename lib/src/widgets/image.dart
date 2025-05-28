part of app_widgets;

class MovieImage extends StatelessWidget {
  final String src;
  final String? id;
  final Widget? child;

  late final Key _key;
  MovieImage({
    super.key,
    required this.src,
    this.child,
    this.id,
  }) : _key = ValueKey(id);

  @override
  Widget build(BuildContext context) {
    return Hero(
      key: _key,
      tag: 'movie-$id',
      transitionOnUserGestures: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.0),
          image: DecorationImage(
            image: CachedNetworkImageProvider(
              src,
              cacheKey: src,
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: AspectRatio(
          aspectRatio: 0.67,
          child: child,
        ),
      ),
    );
  }
}
