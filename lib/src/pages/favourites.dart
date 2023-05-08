part of app_pages;

class FavouritesPage extends StatelessWidget {
  static const routeName = '/favourites-movies';
  const FavouritesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center();
    // return MamuMovieListpage<FavouriteApiCubit>(
    //   label: 'favourite',
    //   handler: context.read<ApiProvider>().favouriteMovies,
    //   appBar: AppBar(
    //     title: Text(
    //       'Favourite Movies',
    //       style: Theme.of(context).appBarTheme.titleTextStyle,
    //     ),
    //   ),
    //   actions: [],
    // );
  }
}

typedef FavCallback = Future<Map<String, dynamic>> Function(int);
