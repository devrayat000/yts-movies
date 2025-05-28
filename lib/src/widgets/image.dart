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
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        );
  }
  static LinearGradient _getProgressGradient(double value) {
    return LinearGradient(
      colors: [
        Color.lerp(Colors.red.shade400, Colors.green.shade400, value) ??
            Colors.blue,
        Color.lerp(Colors.red.shade600, Colors.green.shade600, value) ??
            Colors.blueAccent,
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

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
            final progress = downloadProgress.progress ?? 0.0;
            return Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: _getProgressGradient(progress),
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 3,
                      backgroundColor: Colors.white.withValues(alpha: 0.3),
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          errorWidget: (context, url, error) {
            log(error.toString(), error: error);

            return Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.grey.shade300,
                    Colors.grey.shade400,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: const Center(
                child: Icon(
                  Icons.image_not_supported_rounded,
                  size: 48,
                  color: Colors.white,
                ),
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
          borderRadius: BorderRadius.circular(16.0),
          child: Stack(
            children: [
              // Make sure the child fills the entire container
              Positioned.fill(
                child: child,
              ),
              // Subtle overlay for better image contrast
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.1),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
