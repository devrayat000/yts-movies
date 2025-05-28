part of app_widgets.button;

class FavouriteButton extends StatefulWidget {
  final bool? isFavourite;
  final Movie _movie;
  const FavouriteButton({
    super.key,
    required Movie movie,
    this.isFavourite = false,
  }) : _movie = movie;

  @override
  FavouriteButtonState createState() => FavouriteButtonState();
}

class FavouriteButtonState extends State<FavouriteButton>
    with SingleTickerProviderStateMixin<FavouriteButton> {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void didChangeDependencies() {
    _favHandler();
    super.didChangeDependencies();
  }

  void _favHandler() async {
    final isLiked =
        await FavouritesService.instance.isFavourite(widget._movie.id);
    if (isLiked) {
      _controller.forward();
    }
  }

  void _addToFavourite() async {
    final isLiked = await FavouritesService.instance
        .toggleAddOrRemoveFavourite(widget._movie);
    try {
      if (!isLiked) {
        _controller.reverse();
      } else {
        _controller.forward();
      }
    } catch (e, s) {
      log(e.toString(), error: e, stackTrace: s);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [
            Colors.pink.withOpacity(0.1),
            Colors.pinkAccent.withOpacity(0.1),
          ],
        ),
        border: Border.all(
          color: Colors.pink.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: _addToFavourite,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final scale = sin(_controller.value * pi) * 0.3 + 1;
                return Transform.scale(
                  scale: scale,
                  child: Icon(
                    _controller.value <= 0.5
                        ? Icons.favorite_border_rounded
                        : Icons.favorite_rounded,
                    color: _controller.value <= 0.5
                        ? (isDark ? Colors.pink[300] : Colors.pink[600])
                        : Colors.pink[500],
                    size: 20,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  void didUpdateWidget(covariant FavouriteButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget._movie != widget._movie) {
      _favHandler();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
