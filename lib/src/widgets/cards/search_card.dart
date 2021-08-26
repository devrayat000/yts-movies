part of app_widgets.card;

class SearchTile extends StatelessWidget {
  const SearchTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      color: Theme.of(context).inputDecorationTheme.fillColor,
      child: TextField(
        style: TextStyle(
          color: Theme.of(context).inputDecorationTheme.hintStyle?.color,
        ),
        // enabled: false,
        keyboardType: TextInputType.url,
        decoration: InputDecoration(
          hintText: 'Search movies',
          enabled: false,
          hintStyle: Theme.of(context).inputDecorationTheme.hintStyle,
          fillColor: Theme.of(context).inputDecorationTheme.fillColor,
          filled: Theme.of(context).inputDecorationTheme.filled,
          contentPadding: Theme.of(context).inputDecorationTheme.contentPadding,
          suffixIcon: Padding(
            child: Icon(
              Icons.search,
              color: Theme.of(context).buttonTheme.colorScheme?.onSurface,
            ),
            padding: const EdgeInsets.only(right: 24),
          ),
        ),
      ),
    );
  }
}
