import 'package:flutter/material.dart';
import 'package:flutter_localized_locales/flutter_localized_locales.dart';
import 'package:ytsmovies/models/movie.dart';
import 'package:ytsmovies/pages/index.dart';
import 'package:ytsmovies/utils/constants.dart';
import 'package:ytsmovies/utils/exceptions.dart';
import 'package:ytsmovies/widgets/image.dart';

class SearchSuggestions extends StatelessWidget {
  final List<String>? history;
  final Future<List<Movie>?>? future;
  final void Function(int index) onShowHistory;
  final VoidCallback? onTap;
  const SearchSuggestions({
    Key? key,
    this.onTap,
    required this.history,
    required this.future,
    required this.onShowHistory,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Movie>?>(
      future: future,
      builder: (context, snapshot) {
        print(snapshot.error);
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            print('none');
            print(history);
            if (history == null) {
              return _text(
                context,
                'Search for movies!',
              );
            }
            return ListView.separated(
              itemBuilder: (context, i) {
                return ListTile(
                  key: ValueKey(history![i]),
                  leading: Icon(Icons.history),
                  title: Text(history![i]),
                  trailing: Icon(Icons.find_in_page),
                  onTap: () => onShowHistory(i),
                );
              },
              itemCount: history!.length,
              separatorBuilder: (_, __) => Divider(),
            );
          case ConnectionState.waiting:
          case ConnectionState.active:
            print('active');
            return MyGlobals.kCircularLoading;
          case ConnectionState.done:
            print('done');
            if (snapshot.hasError) {
              final error = snapshot.error;
              if (error is NotFoundException) {
                return _text(context, error.message);
              }
              return _text(context, error.toString());
            } else if (snapshot.hasData) {
              final movies = snapshot.data;
              return ListView.separated(
                itemBuilder: (context, i) {
                  final _movie = movies![i];
                  return ListTile(
                    leading: MovieImage(src: _movie.coverImg.small),
                    title: Text(_movie.title),
                    subtitle: Text(
                        LocaleNames.of(context)?.nameOf(_movie.language) ??
                            'English'),
                    trailing: Text(_runtimeFormat(_movie)),
                    onTap: () async {
                      // Navigator.pushNamed(context, MoviePage.routeName);
                      try {
                        await Navigator.of(context).push(Routes.details(
                          context,
                          argument: MovieArg(_movie),
                        ));
                      } catch (e) {
                        print(e);
                      } finally {
                        onTap?.call();
                      }
                    },
                  );
                },
                separatorBuilder: (context, i) => Divider(),
                itemCount: movies!.length,
              );
            } else {
              return MyGlobals.kCircularLoading;
            }
          default:
            return Text('😁');
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
