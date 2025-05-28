part of app_widget.search;

class SearchResultPage extends StatelessWidget {
  final PagingController<int, Movie> controller;
  final void Function() onFiltered;
  const SearchResultPage({
    Key? key,
    required this.controller,
    required this.onFiltered,
  }) : super(key: key);

  void _showFilterBottomSheet(BuildContext context) {
    FilterBottomSheet.show(
      context,
      onApplyFilter: onFiltered,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SearchResults(
      controller: controller,
      onToggleFilter: () => _showFilterBottomSheet(context),
    );
  }
}
