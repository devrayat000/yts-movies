part of app_widgets.card;

class MovieListShimmer extends StatelessWidget {
  const MovieListShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer(
      linearGradient: context.read<ThemeCubit>().theme.shimmerGradient(isDark),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1,
          childAspectRatio: 9 / 4,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 6,
        shrinkWrap: true,
        itemBuilder: (context, i) {
          return const ShimmerMovieCard();
        },
      ),
    );
  }
}

class ShimmerMovieCard extends StatelessWidget {
  const ShimmerMovieCard({Key? key}) : super(key: key);

  const ShimmerMovieCard.list({Key? key}) : super(key: key);
  const ShimmerMovieCard.grid({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      isLoading: true,
      child: Container(
        child: Card(
          color: Theme.of(context).colorScheme.surface,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: _list,
          ),
        ),
      ),
    );
  }

  Widget get _list => Flex(
        direction: Axis.horizontal,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerShape.image(),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerShape.title(height: 16),
                Expanded(
                  child: ShimmerShape.desc(
                    height: 8,
                    count: 4,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
}
