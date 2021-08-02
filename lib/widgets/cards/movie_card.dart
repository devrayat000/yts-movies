import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

import '../../providers/view_provider.dart';
import '../buttons/favourite_button.dart';
import '../../pages/movie.dart';
import '../image.dart';
import '../../models/movie.dart';

class MovieCard extends StatelessWidget {
  final Movie _movie;
  final bool _isGrid;

  const MovieCard({
    Key? key,
    required Movie movie,
    bool isGrid = false,
  })  : _isGrid = isGrid,
        _movie = movie,
        super(key: key);

  const MovieCard.list({Key? key, required Movie movie})
      : _movie = movie,
        _isGrid = false,
        super(key: key);
  const MovieCard.grid({Key? key, required Movie movie})
      : _movie = movie,
        _isGrid = true,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      // height: isGrid ? 250 : 190,
      child: Card(
        color: Theme.of(context).canvasColor,
        elevation: 5,
        child: InkWell(
          splashFactory: NoSplash.splashFactory,
          child: AnimatedSwitcher(
            duration: Duration(milliseconds: 400),
            child: _isGrid ? _grid : _list,
          ),
          onTap: () async {
            await Navigator.of(context).pushNamed(
              MoviePage.routeName,
              arguments: MovieArg(_movie),
            );
          },
        ),
      ),
    );
  }

  Widget get _list => Flex(
        direction: Axis.horizontal,
        children: [
          _image,
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _title,
                  _year_rating,
                  Expanded(
                    child: Flex(
                      direction: _isGrid ? Axis.vertical : Axis.horizontal,
                      children: [
                        Expanded(
                          flex: 3,
                          child: _quality_chip,
                        ),
                        Align(
                          child: FavouriteButton(movie: _movie),
                          alignment: Alignment.bottomRight,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );

  Widget get _grid => Flex(
        direction: Axis.vertical,
        children: [
          Expanded(
            flex: 3,
            child: Flex(
              direction: Axis.horizontal,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _image),
                Expanded(
                  child: Column(
                    children: [
                      Align(
                        child: FavouriteButton(movie: _movie),
                        alignment: Alignment.topRight,
                      ),
                      _year_rating,
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(flex: 1, child: _title),
          Expanded(flex: 1, child: _quality_chip),
        ],
      );

  // ignore: non_constant_identifier_names
  Widget get _year_rating => Expanded(
        child: Flex(
          direction: _isGrid ? Axis.vertical : Axis.horizontal,
          mainAxisAlignment:
              _isGrid ? MainAxisAlignment.end : MainAxisAlignment.spaceBetween,
          children: [
            Builder(
              builder: (context) => Text(
                _movie.year,
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
            Chip(
              label: Text("${_movie.rating} / 10"),
              avatar: const Icon(
                Icons.star,
                color: Colors.green,
              ),
              labelStyle: const TextStyle(fontSize: 12.0),
            ),
          ],
        ),
      );

  // ignore: non_constant_identifier_names
  Widget get _quality_chip => Wrap(
        spacing: 4.0,
        children: _movie.quality
            .map((quality) => Chip(
                  label: Text(quality),
                  labelStyle: const TextStyle(fontSize: 12.0),
                ))
            .toList(),
      );

  Widget get _image => MovieImage(
        src: _movie.coverImg.medium,
        padding: 4.0,
        label: _movie.title,
        id: _movie.id,
      );

  Widget get _title {
    return Builder(
      builder: (context) {
        final theme = _isGrid
            ? Theme.of(context).textTheme.headline6
            : Theme.of(context).textTheme.headline5;
        return Text.rich(
          TextSpan(
            text: _movie.language != 'en'
                ? '[${_movie.language.toUpperCase()}] '
                : '',
            style: theme?.copyWith(
              color: Colors.blueGrey[400],
            ),
            children: [
              TextSpan(
                text: _movie.title,
                style: theme,
              )
            ],
          ),
          textAlign: _isGrid ? TextAlign.center : TextAlign.start,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        );
      },
    );
  }
}
