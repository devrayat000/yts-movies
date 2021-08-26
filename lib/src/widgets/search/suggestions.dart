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

  Widget build(BuildContext context) {
    return MyFutureBuilder<List<Movie>>(
      future: future,
      idleBuilder: (context) {
        if (history == null || history!.length == 0) {
          return _text(context, 'Search for movies..🤗');
        }
        return ListView.separated(
          itemCount: history!.length,
          separatorBuilder: (context, i) => Divider(),
          itemBuilder: (context, i) {
            final item = history![i];

            return ListTile(
              leading: Icon(Icons.history),
              title: Text(item),
              trailing: Icon(Icons.find_in_page),
              onTap: () => onShowHistory.call(i),
            );
          },
        );
      },
      errorBuilder: (context, error) {
        if (error is CustomException) {
          return _text(context, error.message);
        }
        return _text(context, error.toString());
      },
      successBuilder: (context, data) {
        print(data);
        print('success');
        if (data == null || data.length == 0) {
          if (data is List<String>) {
            _text(context, 'Search for movies..🤗');
          }
          return _text(context, 'Nothing found 😥!');
        }
        print('success list');
        return ListView.separated(
          itemCount: data.length,
          separatorBuilder: (context, i) => Divider(),
          itemBuilder: (context, i) {
            final item = data[i];

            return ListTile(
              leading: SizedBox(
                height: 90,
                width: 60,
                child: MovieImage(src: item.smallCoverImage),
              ),
              title: Text(item.title),
              subtitle: Text(all_native_names[item.language] ?? 'English'),
              trailing: Text(_runtimeFormat(item)),
              onTap: () async {
                try {
                  RootRouteScope.of(context).pushDetails(item);
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
          style: Theme.of(context).textTheme.headline4,
          textAlign: TextAlign.justify,
        ),
      );

  String _runtimeFormat(Movie _movie) {
    final _duration = Duration(minutes: _movie.runtime);
    final hour = _duration.inHours;
    final mins = _duration.inMinutes.remainder(60);
    return '$hour h $mins min';
  }
}
