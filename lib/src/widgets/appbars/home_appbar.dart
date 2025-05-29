part of app_widgets;

class HomeAppbar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppbar({Key? key})
      : preferredSize = const Size.fromHeight(kToolbarHeight),
        super(key: key);

  @override
  final Size preferredSize;
  void _handleSearchTap(BuildContext context) async {
    try {
      await context.pushNamed("search");
    } catch (error) {
      if (context.mounted) {
        // Use ScaffoldMessenger for showing errors in appbar context
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to open search: $error'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  PreferredSizeWidget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppBar(
      title: Row(
        children: [
          Image.asset(
            'images/logo-YTS.png',
            height: 32,
          ),
        ],
      ),
      centerTitle: false, // Align logo to the left
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
        // Search action
        IconButton(
          onPressed: () => _handleSearchTap(context),
          icon: const Icon(Icons.search_outlined),
          tooltip: 'Search',
          iconSize: 24,
        ),
        // Theme toggle action
        IconButton(
          onPressed: () {
            context.read<ThemeCubit>().toggle();
          },
          icon: Icon(
            isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
          ),
          tooltip: 'Toggle theme',
          iconSize: 24,
        ), // Favourites action
        IconButton(
          onPressed: () async {
            try {
              await context.pushNamed("favourites");
            } catch (e, s) {
              log(e.toString(), error: e, stackTrace: s);
            }
          },
          icon: const Icon(
            Icons.favorite_outline,
            color: Colors.pinkAccent,
          ),
          tooltip: 'Favourites',
          iconSize: 24,
        ),
        // App info action
        IconButton(
          onPressed: () async {
            try {
              await context.pushNamed("app-info");
            } catch (e, s) {
              log(e.toString(), error: e, stackTrace: s);
            }
          },
          icon: const Icon(
            Icons.info_outline,
          ),
          tooltip: 'App Info',
          iconSize: 24,
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
