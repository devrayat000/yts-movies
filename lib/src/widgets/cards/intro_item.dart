part of app_widgets.card;

class IntroItem extends StatelessWidget {
  final void Function()? onAction;
  final Widget Function(BuildContext, Movie, int) itemBuilder;
  final Widget title;
  final TextStyle? titleTextStyle;
  final Future<MovieListResponse> future;

  const IntroItem({
    super.key,
    required this.onAction,
    required this.itemBuilder,
    required this.title,
    required this.future,
    this.titleTextStyle,
  });
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  Colors.blueGrey[800]!.withOpacity(0.3),
                  Colors.blueGrey[900]!.withOpacity(0.4),
                ]
              : [
                  Colors.white.withOpacity(0.7),
                  Colors.grey[50]!.withOpacity(0.8),
                ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onAction,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.deepPurple.withOpacity(0.1),
                      Colors.indigo.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    DefaultTextStyle(
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: Theme.of(context).textTheme.headlineSmall?.color,
                      ).merge(titleTextStyle),
                      child: title,
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.deepPurple.withOpacity(0.8),
                            Colors.indigo.withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            height: 200,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: MyFutureBuilder<MovieListResponse>(
                future: future,
                loadingBuilder: (context) {
                  return const ShimmerIntroItem();
                },
                errorBuilder: (context, error) {
                  return CompactErrorWidget(
                    error: error!,
                    onRetry: () {
                      // Trigger a rebuild by calling setState in parent widget
                      // This is a limitation since IntroItem is StatelessWidget
                      // In a real implementation, we might need to convert to StatefulWidget
                      // or use a callback mechanism
                    },
                  );
                },
                successBuilder: (context, response) {
                  return ItemBuilder(
                    builder: itemBuilder,
                    onAction: onAction,
                    items: response!.data.movies!,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ItemBuilder extends StatelessWidget {
  final void Function()? onAction;
  final List<Movie> items;
  final Widget Function(BuildContext, Movie, int) builder;
  const ItemBuilder({
    super.key,
    required this.onAction,
    required this.items,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoScrollbar(
      child: CustomScrollView(
        key: key,
        slivers: [
          SliverPadding(
            padding:
                const EdgeInsets.only(bottom: 10.0, left: 12.0, right: 12.0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  return Padding(
                    padding: EdgeInsetsGeometry.only(
                        right: i == items.length - 1 ? 0.0 : 6.0),
                    child: builder(context, items[i], i),
                  );
                },
                childCount: items.length,
              ),
            ),
          ),
          _moreIcon,
        ],
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        physics: const ClampingScrollPhysics(),
      ),
    );
  }

  Widget get _moreIcon => SliverToBoxAdapter(
        child: ShowMoreButton(onPressed: onAction),
      );
}
