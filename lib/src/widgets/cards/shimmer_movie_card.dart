part of app_widgets.card;

class MovieListShimmer extends StatelessWidget {
  const MovieListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer(
      linearGradient: context.read<ThemeCubit>().theme.shimmerGradient(isDark),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
  const ShimmerMovieCard({super.key});

  const ShimmerMovieCard.list({super.key});
  const ShimmerMovieCard.grid({super.key});
  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      isLoading: true,
      child: Card(
        color: Theme.of(context).colorScheme.surface,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text("Hi"),
        ),
      ),
    );
  }
}
