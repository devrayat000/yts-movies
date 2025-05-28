part of app_widgets.card;

class MovieCard extends StatelessWidget {
  final Movie _movie;
  final bool _isGrid;

  const MovieCard({
    super.key,
    required Movie movie,
    bool isGrid = false,
  })  : _isGrid = isGrid,
        _movie = movie;

  const MovieCard.list({super.key, required Movie movie})
      : _movie = movie,
        _isGrid = false;
  const MovieCard.grid({super.key, required Movie movie})
      : _movie = movie,
        _isGrid = true;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16.0),
        child: InkWell(
          splashFactory: InkRipple.splashFactory,
          onTap: () => _viewDetails(context),
          borderRadius: BorderRadius.circular(16.0),
          child: _isGrid ? _grid(context) : _list(context),
        ),
      ),
    );
  }

  void _viewDetails(BuildContext context) async {
    try {
      context.pushNamed(
        "details",
        pathParameters: {'id': _movie.id.toString()},
        extra: _movie,
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Widget _list(BuildContext context) => Flex(
        direction: Axis.horizontal,
        children: [
          _image(context),
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
                  Flex(
                    direction: _isGrid ? Axis.vertical : Axis.horizontal,
                    children: [
                      Expanded(
                        flex: 3,
                        child: _quality_chip,
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: FavouriteButton(movie: _movie),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      );
  Widget _grid(BuildContext context) => MoviePoster(
        movie: _movie,
        showFavoriteButton: true,
        margin: EdgeInsets.zero,
        onTap: () => _viewDetails(context),
      );
  // ignore: non_constant_identifier_names
  Widget get _quality_chip => Wrap(
        spacing: 6.0,
        runSpacing: 4.0,
        children: _movie.quality
            .map(
              (quality) => Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.deepPurple.withOpacity(0.8),
                      Colors.indigo.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepPurple.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  quality,
                  style: const TextStyle(
                    fontSize: 11.0,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )
            .toList(),
      );
  Widget _image(BuildContext context) => _isGrid
      ? _gridImage(context)
      : MovieImage(
          src: _movie.mediumCoverImage,
          id: _movie.id.toString(),
        );
  Widget _gridImage(BuildContext context) => MoviePoster(movie: _movie);
}

class _YearRating extends StatelessWidget {
  final bool isGrid;
  final String rating;
  final String year;
  const _YearRating({
    required this.isGrid,
    required this.year,
    required this.rating,
  });
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Flex(
      direction: isGrid ? Axis.vertical : Axis.horizontal,
      mainAxisAlignment:
          isGrid ? MainAxisAlignment.end : MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.blueGrey[700]?.withOpacity(0.7)
                : Colors.grey[200]?.withOpacity(0.7),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            year,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.amber.withOpacity(0.8),
                Colors.orange.withOpacity(0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.amber.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.star_rounded,
                color: Colors.white,
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                rating,
                style: const TextStyle(
                  fontSize: 11.0,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Title extends StatelessWidget {
  final bool isGrid;
  final String title;
  final String language;
  const _Title({
    required this.isGrid,
    required this.title,
    required this.language,
  });
  @override
  Widget build(BuildContext context) {
    final theme = isGrid
        ? Theme.of(context).textTheme.titleLarge
        : Theme.of(context).textTheme.headlineSmall;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Text.rich(
        TextSpan(
          // ignore: unnecessary_null_comparison
          text: language != 'en' && language != '' && language != null
              ? '[${language.toUpperCase()}] '
              : '',
          style: theme?.copyWith(
            color: Colors.deepPurple.withOpacity(0.7),
            fontSize: isGrid ? 11 : 13,
            fontWeight: FontWeight.w500,
          ),
          children: [
            TextSpan(
              text: title,
              style: theme?.copyWith(
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
                height: 1.2,
              ),
            )
          ],
        ),
        textAlign: isGrid ? TextAlign.center : TextAlign.start,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
