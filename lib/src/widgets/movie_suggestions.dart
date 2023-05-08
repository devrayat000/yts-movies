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
      errorBuilder: (context, error) {
        String message;
        if (error is CustomException) {
          message = error.message;
        } else {
          message = error.toString();
        }
        return SliverToBoxAdapter(
          child: Center(
            child: Text(
              message,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        );
      },
    );
  }

  Widget _builder(BuildContext context, MovieSuggestionResponse? response) {
    return SliverGrid(
      delegate: SliverChildBuilderDelegate(
        (_, i) => MovieCard.grid(
          movie: response.data.movies![i],
        ),
        childCount: response!.data.movies!.length,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 17 / 20,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
    );
  }

  Widget get _loader => const SliverToBoxAdapter(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );

  // Future<List<Movie>> get _suggestionsFuture =>
  //     context.read<MovieRepository>().movieSuggestions(widget.id);
}
