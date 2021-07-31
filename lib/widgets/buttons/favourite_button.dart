import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:ytsmovies/database/db.dart';
import 'package:ytsmovies/providers/mamus_provider.dart';
// import 'package:ytsmovies/providers/favourite_movie_provider.dart';

// import '../../database/movies_db.dart';
import '../../models/movie.dart';

class FavouriteButton extends StatelessWidget {
  final bool? isFavourite;
  final Movie _movie;
  const FavouriteButton(
      {Key? key, required Movie movie, this.isFavourite = false})
      : _movie = movie,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () async {
        final favmovie = context.read<FavouriteMamus>();
        // final db = context.read<MoviesDB>();
        try {
          if (favmovie.isLiked(_movie.id)) {
            await favmovie.unlike(_movie.id);
            // await db.delete(_movie.id);
          } else {
            await favmovie.like(_movie);
            // await db.insert(_movie);
          }
        } catch (e) {
          print(e);
        }
      },
      splashRadius: 20.0,
      tooltip: 'Favourite Toggle',
      icon: AnimatedCrossFade(
        firstChild: Icon(
          Icons.favorite_border_outlined,
          color: Colors.pinkAccent[400],
        ),
        secondChild: Icon(
          Icons.favorite,
          color: Colors.pinkAccent[400],
        ),
        crossFadeState: !context.select<FavouriteMamus, bool>(
                (value) => value.isLiked(_movie.id))
            ? CrossFadeState.showFirst
            : CrossFadeState.showSecond,
        duration: const Duration(milliseconds: 400),
      ),
    );
  }
}
