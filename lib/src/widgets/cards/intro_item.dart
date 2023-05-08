part of app_widgets.card;

class IntroItem extends StatelessWidget {
  final void Function()? onAction;
  final Widget Function(BuildContext, Movie, int) itemBuilder;
  final Widget title;
  final TextStyle? titleTextStyle;
  final Future<MovieListResponse> future;

  const IntroItem({
    Key? key,
    required this.onAction,
    required this.itemBuilder,
    required this.title,
    required this.future,
    this.titleTextStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onAction,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DefaultTextStyle(
                  style: const TextStyle(fontSize: 24).merge(titleTextStyle),
                  child: title,
                ),
                const Icon(Icons.arrow_forward_ios),
              ],
            ),
          ),
        ),
        SizedBox(
          height: 200,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: MyFutureBuilder<MovieListResponse>(
              future: future,
              errorBuilder: (context, error) {
                if (error is CustomException) {
                  return Center(
                    child: Text(error.message),
                  );
                }
                return Center(
                  child: Text(error.toString()),
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
    );
  }
}

class ItemBuilder extends StatelessWidget {
  final void Function()? onAction;
  final List<Movie> items;
  final Widget Function(BuildContext, Movie, int) builder;
  const ItemBuilder({
    Key? key,
    required this.onAction,
    required this.items,
    required this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoScrollbar(
      child: CustomScrollView(
        key: key,
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.only(bottom: 8.0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  return builder(context, items[i], i);
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
