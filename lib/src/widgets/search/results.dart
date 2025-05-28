part of app_widget.search;

class SearchResults extends StatelessWidget {
  final PagingController<int, Movie> controller;
  final VoidCallback? onToggleFilter;
  SearchResults({
    Key? key,
    required this.controller,
    required this.onToggleFilter,
  }) : super(key: key);

  final _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      child: CupertinoScrollbar(
        controller: _scrollController,
        child: RefreshIndicator(
          onRefresh: () async => controller.refresh(),
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverActionBar(
                floating: true,
                snap: true,
                actions: [
                  IconButton(
                    onPressed: () {
                      onToggleFilter?.call();
                    },
                    icon: const Icon(Icons.filter_alt_outlined),
                    splashRadius: 20,
                  ),
                ],
              ),
              MovieList(controller: controller),
            ],
          ),
        ),
      ),
    );
  }
}
