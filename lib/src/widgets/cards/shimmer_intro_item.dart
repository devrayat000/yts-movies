part of app_widgets.card;

/// Shimmer loading widget specifically for IntroItem horizontal lists
class ShimmerIntroItem extends StatelessWidget {
  /// Number of shimmer items to show
  final int itemCount;

  /// Height of the shimmer container
  final double height;

  const ShimmerIntroItem({
    super.key,
    this.itemCount = 4,
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Shimmer(
      linearGradient: _getShimmerGradient(theme, isDark),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        padding: const EdgeInsets.only(bottom: 10.0, left: 12.0, right: 12.0),
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.only(
              right: index == itemCount - 1 ? 0.0 : 6.0,
            ),
            child: ShimmerLoading(
              isLoading: true,
              child: _buildShimmerMovieItem(context, theme),
            ),
          );
        },
      ),
    );
  }

  Widget _buildShimmerMovieItem(BuildContext context, ThemeData theme) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: AspectRatio(
        aspectRatio: 0.67,
      ),
    );
  }

  LinearGradient _getShimmerGradient(ThemeData theme, bool isDark) {
    if (isDark) {
      return LinearGradient(
        colors: [
          Colors.grey[800]!,
          Colors.grey[700]!,
          Colors.grey[800]!,
        ],
        stops: const [0.1, 0.3, 0.4],
        begin: const Alignment(-1.0, -0.3),
        end: const Alignment(1.0, 0.3),
        tileMode: TileMode.clamp,
      );
    } else {
      return LinearGradient(
        colors: [
          const Color(0xFFEBEBF4),
          const Color(0xFFF4F4F4),
          const Color(0xFFEBEBF4),
        ],
        stops: const [0.1, 0.3, 0.4],
        begin: const Alignment(-1.0, -0.3),
        end: const Alignment(1.0, 0.3),
        tileMode: TileMode.clamp,
      );
    }
  }
}
