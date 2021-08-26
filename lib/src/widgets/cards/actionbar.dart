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
    return SliverAppBar(
      actions: actions,
      floating: floating,
      snap: snap,
      automaticallyImplyLeading: false,
      elevation: 5,
      forceElevated: true,
      backgroundColor: Theme.of(context).cardColor,
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
    return Card(
      elevation: 5,
      child: Container(
        width: double.infinity,
        child: Wrap(
          alignment: WrapAlignment.end,
          spacing: spacing,
          children: actions ?? [],
        ),
      ),
    );
  }
}
