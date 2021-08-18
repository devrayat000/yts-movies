import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ytsmovies/utils/tweens.dart';

import '../../providers/mamus_provider.dart';
import '../../mock/movie.dart';

class FavouriteButton extends StatefulWidget {
  final bool? isFavourite;
  final Movie _movie;
  const FavouriteButton({
    Key? key,
    required Movie movie,
    this.isFavourite = false,
  })  : _movie = movie,
        super(key: key);

  @override
  _FavouriteButtonState createState() => _FavouriteButtonState();
}

class _FavouriteButtonState extends State<FavouriteButton>
    with SingleTickerProviderStateMixin<FavouriteButton> {
  late final AnimationController _controller;

  late Animation<double> _sizeAnimation, _iconAnimation;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _iconAnimation = _controller.drive(MyTween.zeroOne);
    _sizeAnimation = _controller.drive(MyTween.wiggleEnlarge);

    super.initState();
  }

  @override
  void didChangeDependencies() {
    _favHandler();
    super.didChangeDependencies();
  }

  void _favHandler() {
    final fav = context.read<FavouriteMamus>();
    if (fav.isLiked(widget._movie.id.toString())) {
      _controller.forward();
    }
  }

  void _addToFavourite() async {
    final favmovie = context.read<FavouriteMamus>();
    try {
      if (favmovie.isLiked(widget._movie.id.toString())) {
        _controller.reverse();
        await favmovie.unlike(widget._movie.id.toString());
      } else {
        _controller.forward();
        await favmovie.like(widget._movie);
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: _addToFavourite,
      splashRadius: 20.0,
      tooltip: 'Favourite Toggle',
      icon: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Transform.scale(
          scale: _sizeAnimation.value,
          child: Icon(
            _iconAnimation.value <= 0.5
                ? Icons.favorite_border_outlined
                : Icons.favorite,
            color: Colors.pinkAccent[400],
          ),
        ),
      ),
    );
  }

  @override
  void didUpdateWidget(covariant FavouriteButton oldWidget) {
    if (oldWidget._movie != widget._movie) {
      _favHandler();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
