part of app_widget.search;

class SearchSuggestions extends StatelessWidget {
  final Future<List<Object>> future;
  final void Function(int index) onShowHistory;
  final VoidCallback? onTap;
  const SearchSuggestions({
    Key? key,
    this.onTap,
    required this.future,
    required this.onShowHistory,
  }) : super(key: key);

  Widget build(BuildContext context) {
    return MyFutureBuilder<List<Object>>(
      future: future,
      errorBuilder: (context, error) {
        if (error is CustomException) {
          return _text(context, error.message);
        }
        return _text(context, error.toString());
      },
      successBuilder: (context, data) {
        if (data == null || data.length == 0) {
          return _text(context, 'Nothing found 😥!');
        } else if (data is List<Movie> || data is List<String>) {
          return ListView.separated(
            itemCount: data.length,
            separatorBuilder: (context, i) => Divider(),
            itemBuilder: (context, i) {
              final item = data[i];

              if (item is Movie) {
                return ListTile(
                  leading: MovieImage(src: item.smallCoverImage),
                  title: Text(item.title),
                  subtitle: Text(all_native_names[item.language] ?? 'English'),
                  trailing: Text(_runtimeFormat(item)),
                  onTap: () async {
                    try {
                      await Navigator.of(context).push(Routes.details(
                        context,
                        argument: MovieArg(item),
                      ));
                    } catch (e, s) {
                      log(e.toString(), error: e, stackTrace: s);
                    } finally {
                      onTap?.call();
                    }
                  },
                );
              } else {
                return ListTile(
                  leading: Icon(Icons.history),
                  title: Text(item as String),
                  trailing: Icon(Icons.find_in_page),
                  onTap: () => onShowHistory(i),
                );
              }
            },
          );
        } else {
          throw UnimplementedError();
        }
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
