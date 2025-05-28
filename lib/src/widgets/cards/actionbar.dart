part of app_widgets.card;

class SliverActionBar extends StatelessWidget {
  final bool floating;
  final bool snap;
  final List<Widget>? actions;

  const SliverActionBar({
    Key? key,
    this.floating = false,
    this.snap = false,
    this.actions,
  }) : super(key: key);
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
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.surface,
              theme.colorScheme.surface.withOpacity(0.95),
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
    Key? key,
    this.actions,
    this.spacing = 0.0,
  }) : super(key: key);
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
            theme.colorScheme.surface.withOpacity(0.95),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
          width: 1.0,
        ),
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
