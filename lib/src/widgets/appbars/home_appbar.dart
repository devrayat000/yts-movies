part of app_widgets;

class HomeAppbar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppbar({Key? key})
      : preferredSize = const Size.fromHeight(kToolbarHeight),
        super(key: key);

  @override
  final Size preferredSize;
  @override
  PreferredSizeWidget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppBar(
      title: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Image.asset(
          'images/logo-YTS.png',
          height: 32,
        ),
      ),
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    Colors.blueGrey[900]!.withOpacity(0.95),
                    Colors.blueGrey[800]!.withOpacity(0.95),
                  ]
                : [
                    Colors.white.withOpacity(0.95),
                    Colors.grey[50]!.withOpacity(0.95),
                  ],
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.2)
                  : Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: isDark
                ? Colors.blueGrey[700]?.withOpacity(0.5)
                : Colors.grey[100]?.withOpacity(0.8),
          ),
          child: const ThemeToggleButton(),
        ),
        Container(
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [
                Colors.pink.withOpacity(0.8),
                Colors.pinkAccent.withOpacity(0.8),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.pink.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            onPressed: () async {
              try {
                await context.pushNamed("favourites");
              } catch (e, s) {
                log(e.toString(), error: e, stackTrace: s);
              }
            },
            icon: const Icon(
              Icons.favorite_rounded,
              color: Colors.white,
              size: 20,
            ),
            tooltip: 'Favourites',
          ),
        ),
      ],
    );
  }
}
