import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ytsmovies/providers/view_provider.dart';

// import '../../database/movies_db.dart';
import '../buttons/favourite_button.dart';
import '../../pages/movie.dart';
import '../image.dart';
import '../../models/movie.dart';
// import '../../providers/movie_provider.dart';

class MovieCard extends StatefulWidget {
  final Movie _movie;
  final bool _isStatic;
  final bool _isGrid;

  const MovieCard({Key? key, required Movie movie})
      : _movie = movie,
        _isStatic = false,
        _isGrid = false,
        super(key: key);

  const MovieCard.list({Key? key, required Movie movie})
      : _movie = movie,
        _isStatic = true,
        _isGrid = false,
        super(key: key);
  const MovieCard.grid({Key? key, required Movie movie})
      : _movie = movie,
        _isStatic = true,
        _isGrid = true,
        super(key: key);

  @override
  _MovieCardState createState() => _MovieCardState();
}

class _MovieCardState extends State<MovieCard> {
  late bool _isGrid;

  @override
  void initState() {
    if (!widget._isStatic) {
      _isGrid = context.read<GridListView>().isTrue;
      context.read<GridListView>().addListener(() {
        setState(() {
          _isGrid = context.read<GridListView>().isTrue;
        });
      });
    } else {
      _isGrid = widget._isGrid;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // height: isGrid ? 250 : 190,
      child: Card(
        color: Theme.of(context).canvasColor,
        elevation: 5,
        child: InkWell(
          splashFactory: NoSplash.splashFactory,
          child: _isGrid ? _grid : _list,
          onTap: () async {
            await Navigator.of(context).pushNamed(
              MoviePage.routeName,
              arguments: MovieArg(widget._movie),
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
                      direction: context
                              .select<GridListView, bool>((view) => view.isTrue)
                          ? Axis.vertical
                          : Axis.horizontal,
                      children: [
                        Expanded(
                          flex: 3,
                          child: _quality_chip,
                        ),
                        Align(
                          child: FavouriteButton(movie: widget._movie),
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
                        child: FavouriteButton(movie: widget._movie),
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

  Widget get _year_rating => Expanded(
        child: Flex(
          direction: _isGrid ? Axis.vertical : Axis.horizontal,
          mainAxisAlignment:
              _isGrid ? MainAxisAlignment.end : MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget._movie.year,
              style: Theme.of(context).textTheme.headline6,
            ),
            Chip(
              label: Text("${widget._movie.rating} / 10"),
              avatar: const Icon(
                Icons.star,
                color: Colors.green,
              ),
              labelStyle: const TextStyle(fontSize: 12.0),
            ),
          ],
        ),
      );

  Widget get _quality_chip => Wrap(
        spacing: 4.0,
        children: widget._movie.quality
            .map((quality) => Chip(
                  label: Text(quality),
                  labelStyle: const TextStyle(fontSize: 12.0),
                ))
            .toList(),
      );

  Widget get _image => MovieImage(
        src: widget._movie.coverImg.medium,
        padding: 4.0,
        label: widget._movie.title,
        id: widget._movie.id,
      );

  Widget get _title {
    final theme = _isGrid
        ? Theme.of(context).textTheme.headline6
        : Theme.of(context).textTheme.headline5;
    return Text.rich(
      TextSpan(
        text: widget._movie.language != 'en'
            ? '[${widget._movie.language.toUpperCase()}] '
            : '',
        style: theme?.copyWith(
          color: Colors.blueGrey[400],
        ),
        children: [
          TextSpan(
            text: widget._movie.title,
            style: theme,
          )
        ],
      ),
      textAlign: _isGrid ? TextAlign.center : TextAlign.start,
    );
  }
}
