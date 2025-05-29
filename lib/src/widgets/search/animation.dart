part of app_widget.search;

class SearchResultPage extends StatelessWidget {
  final PagingController<int, Movie> controller;
  final void Function() onFiltered;
  const SearchResultPage({
    Key? key,
    required this.controller,
    required this.onFiltered,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MoviesPagedView(
      handler: (page) async {
        // This is a placeholder implementation
        // In a real scenario, this should fetch data based on the controller
        throw UnimplementedError(
            'SearchResultPage needs proper implementation');
      },
      noItemBuilder: (context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No results found',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
      ),
    );
  }
}
