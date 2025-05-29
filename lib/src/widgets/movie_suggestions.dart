part of app_widgets;

class Suggestions extends StatefulWidget {
  final String id;
  const Suggestions({super.key, required this.id});

  @override
  SuggestionsState createState() => SuggestionsState();
}

class SuggestionsState extends State<Suggestions> {
  late Future<MovieSuggestionResponse> _future;
  @override
  void initState() {
    super.initState();
    _future = context.read<MoviesClient>().getMovieSuggestions(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return MyFutureBuilder<MovieSuggestionResponse>(
      future: _future,
      successBuilder: _builder,
      loadingBuilder: (_) => const MovieListShimmer(count: 4),
      showFullPageError: false,
      errorBuilder: (context, error) {
        return CompactErrorWidget(
          error: error!,
          onRetry: () {
            setState(() {
              _future =
                  context.read<MoviesClient>().getMovieSuggestions(widget.id);
            });
          },
          customMessage: 'Failed to load suggestions',
        );
      },
    );
  }

  Widget _builder(BuildContext context, MovieSuggestionResponse? response) {
    if (response?.data.movies == null || response!.data.movies!.isEmpty) {
      return const SizedBox(
        height: 100,
        child: Center(
          child: Text('No suggested movies available'),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.only(top: 12.0),
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) => MovieCard.grid(
        movie: response.data.movies![index],
      ),
      itemCount: response.data.movies!.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.67,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
    );
  }
}
