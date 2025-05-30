part of 'index.dart';

class MovieImage extends StatefulWidget {
  final String src;
  final List<String>? srcSet;
  final String? id;
  final Widget? child;

  late final Key _key;
  MovieImage({
    super.key,
    required this.src,
    this.srcSet,
    this.child,
    this.id,
  }) : _key = ValueKey(id);

  @override
  State<MovieImage> createState() => _MovieImageState();
}

class _MovieImageState extends State<MovieImage> {
  late var _source = "";
  var _srcSetIndex = 0;

  @override
  void initState() {
    super.initState();
    _source = widget.src;
    log('Hero Tag: movie-$_source');
  }

  @override
  Widget build(BuildContext context) {
    return Hero(
      key: widget._key,
      tag: 'movie-$_source',
      transitionOnUserGestures: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.0),
          image: DecorationImage(
            image: CachedNetworkImageProvider(
              _source,
              cacheKey: _source,
              errorListener: (error) {
                // Handle image loading error
                log(
                  'Failed to load image: ${widget.src}',
                  name: 'MovieImage',
                  error: error,
                  stackTrace: StackTrace.current,
                );
                if (error is HttpException &&
                    widget.srcSet != null &&
                    widget.srcSet!.isNotEmpty &&
                    _srcSetIndex < widget.srcSet!.length) {
                  log("Falling back");
                  // Fallback to first image in srcSet if available
                  setState(() {
                    _source = widget.srcSet![_srcSetIndex];
                    _srcSetIndex++;
                  });
                }
              },
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: AspectRatio(
          aspectRatio: 0.67,
          child: widget.child,
        ),
      ),
    );
  }
}
