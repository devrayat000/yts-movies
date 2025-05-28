part of app_widget.search;

class SearchSuggestions extends StatelessWidget {
  final Future<List<Movie>>? future;
  final List<String>? history;
  final void Function(int index) onShowHistory;
  final VoidCallback? onTap;
  const SearchSuggestions({
    Key? key,
    this.onTap,
    required this.future,
    required this.history,
    required this.onShowHistory,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MyFutureBuilder<List<Movie>>(
      future: future,
      showFullPageError: false,
      idleBuilder: (context) {
        if (history == null || history!.isEmpty) {
          return _text(context, 'Search for movies..🤗');
        }
        return ListView.separated(
          itemCount: history!.length,
          separatorBuilder: (context, i) => const Divider(),
          itemBuilder: (context, i) {
            final item = history![i];

            return ListTile(
              leading: const Icon(Icons.history),
              title: Text(item),
              trailing: const Icon(Icons.find_in_page),
              onTap: () => onShowHistory.call(i),
            );
          },
        );
      },
      errorBuilder: (context, error) {
        return CompactErrorWidget(
          error: error,
          customMessage: 'Failed to load search suggestions',
        );
      },
      successBuilder: (context, data) {
        debugPrint(data.toString());
        debugPrint('success');
        if (data == null || data.isEmpty) {
          return EmptyStateWidget(
            title: 'No Results Found',
            subtitle: 'Try searching for a different movie',
            icon: Icons.search_off,
          );
        }
        debugPrint('success list');
        return ListView.separated(
          itemCount: data.length,
          separatorBuilder: (context, i) => const Divider(),
          itemBuilder: (context, i) {
            final item = data[i];

            return ListTile(
              leading: SizedBox(
                height: 90,
                width: 60,
                child: MovieImage(src: item.smallCoverImage),
              ),
              title: Text(item.title),
              subtitle: Text(allNativeNames[item.language] ?? 'English'),
              trailing: Text(_runtimeFormat(item)),
              onTap: () async {
                try {
                  context.pushNamed("details", extra: item);
                } catch (e, s) {
                  log(e.toString(), error: e, stackTrace: s);
                } finally {
                  onTap?.call();
                }
              },
            );
          },
        );
      },
    );
  }

  Widget _text(BuildContext context, String text) => Container(
        alignment: Alignment.topCenter,
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          text,
          style: Theme.of(context).textTheme.headlineMedium,
          textAlign: TextAlign.justify,
        ),
      );

  String _runtimeFormat(Movie movie) {
    final duration = Duration(minutes: movie.runtime);
    final hour = duration.inHours;
    final mins = duration.inMinutes.remainder(60);
    return '$hour h $mins min';
  }
}
