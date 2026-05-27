import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:ytsmovies/src/bloc/theme_bloc.dart';

/// A modern, highly-polished desktop sidebar navigation shell.
/// Replaces fluent_ui's NavigationView with a fully custom Material 3 sidebar.
class DesktopShell extends StatefulWidget {
  const DesktopShell({super.key, required this.location, required this.child});

  final String location;
  final Widget child;

  @override
  State<DesktopShell> createState() => _DesktopShellState();
}

class _DesktopShellState extends State<DesktopShell> {
  static const _items = <_NavSpec>[
    _NavSpec('home', Icons.home_outlined, Icons.home, 'Home'),
    _NavSpec('latest', Icons.movie_outlined, Icons.movie, 'Latest'),
    _NavSpec('4k', Icons.four_k_outlined, Icons.four_k, '4K'),
    _NavSpec('rated', Icons.star_border, Icons.star, 'Top Rated'),
    _NavSpec('favourites', Icons.favorite_border, Icons.favorite, 'Favourites'),
    _NavSpec('downloads', Icons.download_outlined, Icons.download, 'Downloads'),
    _NavSpec('search', Icons.search, Icons.search, 'Search'),
  ];

  // Breakpoint: below this, rail auto-collapses. Tuned for desktop/TV/large tablet.
  static const double _expandBreakpoint = 1000;

  // User override of auto-collapse. null = follow breakpoint.
  bool? _userExpanded;

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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final selectedIndex = _indexFromLocation(widget.location);

    // Sidebar color matches cardColor/surfaceContainer for desktop layout distinction
    final sidebarColor =
        isDark ? const Color(0xFF1E293B) : const Color(0xFFF3F4F6);

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final autoExtended = constraints.maxWidth >= _expandBreakpoint;
          final extended = _userExpanded ?? autoExtended;

          return Row(
            children: [
              ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(
                  scrollbars: false,
                ),
                child: NavigationRail(
                  extended: extended,
                  minExtendedWidth: 250,
                  backgroundColor: sidebarColor,
                  useIndicator: true,
                  indicatorColor: theme.colorScheme.primaryContainer,
                  selectedIndex: selectedIndex,
                  onDestinationSelected: _goto,
                  selectedIconTheme: IconThemeData(
                    color: theme.colorScheme.primary,
                    size: 22,
                  ),
                  unselectedIconTheme: IconThemeData(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    size: 22,
                  ),
                  selectedLabelTextStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                  unselectedLabelTextStyle:
                      theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                  leading: _buildLeading(theme, extended),
                  destinations: [
                    for (final item in _items)
                      NavigationRailDestination(
                        icon: Icon(item.icon),
                        selectedIcon: Icon(item.activeIcon),
                        label: Text(item.label),
                      ),
                  ],
                  trailingAtBottom: true,
                  trailing: _buildTrailing(theme, isDark, extended),
                ),
              ),
              VerticalDivider(
                width: 1,
                thickness: 1,
                color: theme.dividerColor.withValues(alpha: 0.15),
              ),
              Expanded(
                child: widget.child,
              ),
            ],
          );
        },
      ),
    );
  }

  void _toggleExtended(bool current) {
    setState(() => _userExpanded = !current);
  }

  Widget _buildLeading(ThemeData theme, bool extended) {
    final menuButton = IconButton(
      icon: Icon(extended ? Icons.menu_open : Icons.menu),
      tooltip: extended ? 'Collapse' : 'Expand',
      onPressed: () => _toggleExtended(extended),
    );

    final logo = Image.asset(
      'images/logo-YTS.png',
      height: 24,
      errorBuilder: (_, __, ___) => const Icon(
        Icons.play_circle_fill,
        color: Colors.green,
        size: 24,
      ),
    );

    if (!extended) {
      return Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            menuButton,
            const SizedBox(height: 8),
            logo,
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 16, 20, 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          menuButton,
          const SizedBox(width: 4),
          logo,
          const SizedBox(width: 10),
          Text(
            'YTS Movies',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrailing(ThemeData theme, bool isDark, bool extended) {
    if (!extended) {
      return Expanded(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Divider(
                  height: 1,
                  indent: 12,
                  endIndent: 12,
                  color: theme.dividerColor.withValues(alpha: 0.15),
                ),
                const SizedBox(height: 8),
                IconButton(
                  icon: Icon(
                    Icons.info_outline,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  tooltip: 'About App',
                  onPressed: () => context.pushNamed('app-info'),
                ),
                IconButton(
                  icon: Icon(
                    isDark ? Icons.dark_mode : Icons.light_mode,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  tooltip: isDark ? 'Light theme' : 'Dark theme',
                  onPressed: () => context.read<ThemeCubit>().toggle(),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Expanded(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: SizedBox(
          width: 250,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: theme.dividerColor.withValues(alpha: 0.15),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => context.pushNamed('app-info'),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 20,
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.7),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'About App',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                isDark ? Icons.dark_mode : Icons.light_mode,
                                size: 20,
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.7),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Dark Theme',
                                style: theme.textTheme.bodyMedium,
                              ),
                            ],
                          ),
                          Switch(
                            value: isDark,
                            onChanged: (_) =>
                                context.read<ThemeCubit>().toggle(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavSpec {
  final String name;
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavSpec(this.name, this.icon, this.activeIcon, this.label);
}
