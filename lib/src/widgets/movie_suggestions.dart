part of app_widgets;

class Suggestions extends StatefulWidget {
  final String id;
  const Suggestions({Key? key, required this.id}) : super(key: key);

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
      loadingBuilder: (_) => _loader,
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
    return GridView.builder(
      itemBuilder: (context, index) => MovieCard.grid(
        movie: response.data.movies![index],
      ),
      itemCount: response!.data.movies!.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.67,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
    );
  }

  Widget get _loader => Center(
        child: CircularProgressIndicator(),
      );
}
