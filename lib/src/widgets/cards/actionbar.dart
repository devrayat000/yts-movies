part of 'index.dart';

class SliverActionBar extends StatelessWidget {
  final bool floating;
  final bool snap;
  final List<Widget>? actions;

  const SliverActionBar({
    super.key,
    this.floating = false,
    this.snap = false,
    this.actions,
  });
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SliverAppBar(
      actions: actions,
      floating: floating,
      snap: snap,
      automaticallyImplyLeading: false,
      elevation: 0,
      scrolledUnderElevation: 8,
      forceElevated: true,
      backgroundColor: theme.colorScheme.surface,
      surfaceTintColor: theme.colorScheme.surfaceTint,
      shadowColor: Colors.black.withAlpha((0.1 * 255).toInt()),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.surface,
              theme.colorScheme.surface.withAlpha((0.95 * 255).toInt()),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16.0),
        ),
      ),
    );
  }
}

class ActionBar extends StatelessWidget {
  final List<Widget>? actions;
  final double spacing;

  const ActionBar({
    super.key,
    this.actions,
    this.spacing = 0.0,
  });
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.surface,
            theme.colorScheme.surface.withAlpha((0.95 * 255).toInt()),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.08 * 255).toInt()),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Wrap(
          alignment: WrapAlignment.end,
          spacing: spacing == 0.0 ? 8.0 : spacing,
          runSpacing: 8.0,
          children: actions ?? [],
        ),
      ),
    );
  }
}
