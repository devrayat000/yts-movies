part of app_widgets.card;

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
        color: Theme.of(context).cardColor,
        elevation: 5,
        child: InkWell(
          splashFactory: NoSplash.splashFactory,
          child: _isGrid ? _grid : _list,
          onTap: () => _viewDetails(context),
        ),
      ),
    );
  }

  void _viewDetails(BuildContext context) async {
    try {
      RootRouteScope.of(context).pushDetails(_movie);
    } catch (e) {
      print(e);
    }
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
                  _Title(
                    isGrid: _isGrid,
                    language: _movie.language,
                    title: _movie.title,
                  ),
                  _YearRating(
                    isGrid: _isGrid,
                    rating: _movie.rating.toString(),
                    year: _movie.year.toString(),
                  ),
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
                      _YearRating(
                        isGrid: _isGrid,
                        rating: _movie.rating.toString(),
                        year: _movie.year.toString(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: _Title(
              isGrid: _isGrid,
              language: _movie.language,
              title: _movie.title,
            ),
          ),
          Expanded(flex: 1, child: _quality_chip),
        ],
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
        src: _movie.mediumCoverImage,
        padding: EdgeInsets.all(4.0),
        label: _movie.title,
        id: _movie.id.toString(),
      );
}

class _YearRating extends StatelessWidget {
  final bool isGrid;
  final String rating;
  final String year;
  const _YearRating({
    Key? key,
    required this.isGrid,
    required this.year,
    required this.rating,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Flex(
        direction: isGrid ? Axis.vertical : Axis.horizontal,
        mainAxisAlignment:
            isGrid ? MainAxisAlignment.end : MainAxisAlignment.spaceBetween,
        children: [
          Text(
            year,
            style: Theme.of(context).textTheme.headline6,
          ),
          Chip(
            label: Text("$rating / 10"),
            avatar: const Icon(
              Icons.star,
              color: Colors.green,
            ),
            labelStyle: const TextStyle(fontSize: 12.0),
          ),
        ],
      ),
    );
  }
}

class _Title extends StatelessWidget {
  final bool isGrid;
  final String title;
  final String language;
  const _Title({
    Key? key,
    required this.isGrid,
    required this.title,
    required this.language,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = isGrid
        ? Theme.of(context).textTheme.headline6
        : Theme.of(context).textTheme.headline5;
    return Text.rich(
      TextSpan(
        // ignore: unnecessary_null_comparison
        text: language != 'en' && language != '' && language != null
            ? '[${language.toUpperCase()}] '
            : '',
        style: theme?.copyWith(
          color: Colors.blueGrey[400],
        ),
        children: [
          TextSpan(
            text: title,
            style: theme,
          )
        ],
      ),
      textAlign: isGrid ? TextAlign.center : TextAlign.start,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}
