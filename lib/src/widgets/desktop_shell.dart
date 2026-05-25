import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:ytsmovies/src/bloc/theme_bloc.dart';

/// Windows-style sidebar shell. Wraps the ShellRoute body inside a
/// fluent_ui NavigationView so desktop users get a sidebar instead of
/// the mobile top app bar. Material pages render unchanged inside the
/// content pane.
class DesktopShell extends StatefulWidget {
  const DesktopShell({super.key, required this.location, required this.child});

  final String location;
  final Widget child;

  @override
  State<DesktopShell> createState() => _DesktopShellState();
}

class _DesktopShellState extends State<DesktopShell> {
  static const _items = <_NavSpec>[
    _NavSpec('home', WindowsIcons.home, 'Home'),
    _NavSpec('latest', WindowsIcons.movies, 'Latest'),
    _NavSpec('4k', WindowsIcons.home_solid, '4K'),
    _NavSpec('rated', WindowsIcons.favorite_star_fill, 'Top Rated'),
    _NavSpec('favourites', WindowsIcons.favorite_star, 'Favourites'),
    _NavSpec('downloads', WindowsIcons.download, 'Downloads'),
    _NavSpec('search', WindowsIcons.cloud_search, 'Search'),
  ];

  int _indexFromLocation(String loc) {
    for (var i = 0; i < _items.length; i++) {
      final spec = _items[i];
      final seg = spec.name == 'home' ? '/home' : '/home/${spec.name}';
      if (loc == seg || loc.startsWith('$seg/')) return i;
    }
    return 0;
  }

  void _goto(int i) {
    context.goNamed(_items[i].name);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = FluentTheme.of(context).brightness == Brightness.dark;
    final selected = _indexFromLocation(widget.location);

    return NavigationView(
      titleBar: TitleBar(
        title: Row(
          children: [
            Image.asset('images/logo-YTS.png', height: 20),
            const SizedBox(width: 8),
            const Text('YTS Movies'),
          ],
        ),
        endHeader: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: WindowsIcon(
                  isDark ? WindowsIcons.brightness : WindowsIcons.quiet_hours,
                ),
                onPressed: () => context.read<ThemeCubit>().toggle(),
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: const WindowsIcon(WindowsIcons.info),
                onPressed: () => context.pushNamed('app-info'),
              ),
            ],
          ),
        ),
      ),
      pane: NavigationPane(
        selected: selected,
        displayMode: PaneDisplayMode.auto,
        items: [
          for (var i = 0; i < _items.length; i++)
            PaneItem(
              icon: WindowsIcon(_items[i].icon),
              title: Text(_items[i].label),
              body: widget.child,
              onTap: () => _goto(i),
            ),
        ],
        footerItems: [
          PaneItemSeparator(),
          PaneItem(
            icon: const WindowsIcon(WindowsIcons.info),
            title: const Text('About'),
            body: widget.child,
            onTap: () => context.pushNamed('app-info'),
          ),
        ],
      ),
    );
  }
}

class _NavSpec {
  final String name;
  final IconData icon;
  final String label;
  const _NavSpec(this.name, this.icon, this.label);
}
