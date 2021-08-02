import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/mamus_provider.dart';
import '../../models/movie.dart';

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

  static final _iconTween = Tween<double>(
    begin: 0,
    end: 1,
  );

  static final _iconJumpTween = TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween(begin: 1, end: 2),
      weight: 50,
    ),
    TweenSequenceItem(
      tween: Tween(begin: 2, end: 1),
      weight: 50,
    ),
  ]);

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _iconAnimation = _controller.drive(_iconTween);
    _sizeAnimation = _controller.drive(_iconJumpTween);

    _favHandler();

    super.initState();
  }

  void _favHandler() {
    final fav = context.read<FavouriteMamus>();
    if (fav.isLiked(widget._movie.id)) {
      _controller.forward();
    }
  }

  void _addToFavourite() async {
    final favmovie = context.read<FavouriteMamus>();
    try {
      if (favmovie.isLiked(widget._movie.id)) {
        _controller.reverse();
        await favmovie.unlike(widget._movie.id);
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
            _iconAnimation.value == 0
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
