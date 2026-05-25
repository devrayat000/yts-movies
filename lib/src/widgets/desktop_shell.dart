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
    final sidebarColor = isDark
        ? const Color(0xFF1E293B)
        : const Color(0xFFF3F4F6);

    return Scaffold(
      body: Row(
        children: [
          // Desktop Navigation Sidebar
          Container(
            width: 250,
            color: sidebarColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header section with Title and Logo
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                  child: Row(
                    children: [
                      Image.asset(
                        'images/logo-YTS.png',
                        height: 24,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.play_circle_fill,
                          color: Colors.green,
                          size: 24,
                        ),
                      ),
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
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                const SizedBox(height: 12),

                // Navigation Items
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      final isSelected = index == selectedIndex;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () => _goto(index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            curve: Curves.easeOutCubic,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: isSelected
                                  ? theme.colorScheme.primaryContainer
                                  : Colors.transparent,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isSelected ? item.activeIcon : item.icon,
                                  size: 20,
                                  color: isSelected
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.onSurface.withOpacity(0.7),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  item.label,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isSelected
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Footer Actions (About, Theme Toggle)
                const Divider(height: 1, indent: 16, endIndent: 16),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      // About Button
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
                                color: theme.colorScheme.onSurface.withOpacity(0.7),
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
                      // Theme Toggle Row
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
                                  color: theme.colorScheme.onSurface.withOpacity(0.7),
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
          // Vertical boundary line
          VerticalDivider(
            width: 1,
            thickness: 1,
            color: theme.dividerColor.withOpacity(0.15),
          ),
          // Content pane
          Expanded(
            child: widget.child,
          ),
        ],
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
