part of app_widgets;

class MovieList<T extends ApiBloc> extends StatelessWidget {
  final WidgetBuilder? noItemBuilder;
  final PagingController<int, Movie> controller;

  const MovieList({
    Key? key,
    required this.controller,
    this.noItemBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PagedSliverList<int, Movie>(
      pagingController: controller,
      shrinkWrapFirstPageIndicators: true,
      builderDelegate: PagedChildBuilderDelegate(
        itemBuilder: (context, item, index) {
          return MovieCard.list(
            key: ValueKey('movie-${item.id}'),
            movie: item,
          );
        },
        firstPageProgressIndicatorBuilder: (_) => const MovieListShimmer(),
        newPageProgressIndicatorBuilder: (_) => MyGlobals.kCircularLoading,
        firstPageErrorIndicatorBuilder: _firstPageErrorIndicator,
        newPageErrorIndicatorBuilder: _newPageErrorIndicator,
        noItemsFoundIndicatorBuilder: noItemBuilder ?? _noItemsFoundIndicator,
        noMoreItemsIndicatorBuilder: _noMoreItemsIndicator,
        animateTransitions: true,
      ),
      itemExtent: MediaQuery.of(context).size.width * 4 / 9,
      // gridDelegate: _gridDelegrate(1, 9 / 4),
    );
  }

  Widget _newPageErrorIndicator(BuildContext context) {
    final error = CustomException.getCustomError(controller.error);

    return Column(
      children: [
        Text(error),
        TextButton(
          onPressed: controller.retryLastFailedRequest,
          child: const Text('Retry'),
        ),
      ],
    );
  }

  Widget _firstPageErrorIndicator(BuildContext context) {
    final error = CustomException.getCustomError(controller.error);

    return Column(
      children: [
        Text(error),
        TextButton(
          onPressed: controller.refresh,
          child: const Text('Retry'),
        ),
      ],
    );
  }

  Widget _noItemsFoundIndicator(BuildContext context) => Container(
        alignment: Alignment.topCenter,
        child: Text(
          'No movie found',
          style: Theme.of(context).textTheme.headline5,
        ),
      );

  Widget _noMoreItemsIndicator(BuildContext context) => Center(
        child: Text(
          'That\'s the last of it.',
          style: Theme.of(context).textTheme.headline5,
        ),
      );
}
