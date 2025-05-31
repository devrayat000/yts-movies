part of '../index.dart';

class HomeAppbar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppbar({super.key})
      : preferredSize = const Size.fromHeight(kToolbarHeight);

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
      title: Image.asset(
        'images/logo-YTS.png',
        height: 32,
      ),
      centerTitle: false, // Align logo to the left
      elevation: 0,
      flexibleSpace: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    Colors.blueGrey[900]!.withAlpha((0.95 * 255).toInt()),
                    Colors.blueGrey[800]!.withAlpha((0.95 * 255).toInt()),
                  ]
                : [
                    Colors.white.withAlpha((0.95 * 255).toInt()),
                    Colors.grey[50]!.withAlpha((0.95 * 255).toInt()),
                  ],
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withAlpha((0.2 * 255).toInt())
                  : Colors.grey.withAlpha((0.1 * 255).toInt()),
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
