part of app_widgets;

class HomeAppbar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppbar({Key? key})
      : preferredSize = const Size.fromHeight(kToolbarHeight),
        super(key: key);

  @override
  final Size preferredSize;

  @override
  PreferredSizeWidget build(BuildContext context) {
    return AppBar(
      title: Image.asset(
        'images/logo-YTS.png',
      ),
      elevation: 5,
      actions: [
        const ThemeToggleButton(),
        IconButton(
          onPressed: () async {
            try {
              await context.pushNamed("favourites");
            } catch (e, s) {
              log(e.toString(), error: e, stackTrace: s);
            }
          },
          icon: const Icon(
            Icons.favorite_outline_rounded,
            color: Colors.pink,
          ),
          tooltip: 'Favourites',
        ),
      ],
    );
  }
}
