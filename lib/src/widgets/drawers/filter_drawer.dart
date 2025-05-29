part of app_widgets;

class _FilterItem extends StatelessWidget {
  final Widget title;
  final Widget action;
  final IconData? icon;

  const _FilterItem({
    required this.title,
    required this.action,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 6.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.grey.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                icon,
                color: Theme.of(context).primaryColor,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            flex: 2,
            child: DefaultTextStyle(
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              child: title,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(flex: 3, child: action),
        ],
      ),
    );
  }
}

class FilterBottomSheet extends StatelessWidget {
  final void Function() onApplyFilter;
  const FilterBottomSheet({super.key, required this.onApplyFilter});

  static Future<void> show(
    BuildContext context, {
    required void Function() onApplyFilter,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheet(onApplyFilter: onApplyFilter),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filter = context.read<Filter>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Modern drag handle
          Container(
            margin: const EdgeInsets.only(top: 16, bottom: 8),
            width: 48,
            height: 5,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[600] : Colors.grey[300],
              borderRadius: BorderRadius.circular(3),
            ),
          ), // Enhanced title section
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.tune_rounded,
                    color: Theme.of(context).primaryColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Filter Movies',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                      ),
                      Text(
                        'Customize your movie search',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                              fontSize: 13,
                            ),
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[800] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.close_rounded,
                      color: isDark ? Colors.grey[300] : Colors.grey[700],
                    ),
                    splashRadius: 20,
                  ),
                ),
              ],
            ),
          ),

          // Stylish divider
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  isDark ? Colors.grey[700]! : Colors.grey[300]!,
                  Colors.transparent,
                ],
              ),
            ),
          ), // Filters content with modern styling
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 20, top: 12),
              child: Column(
                children: [
                  _FilterItem(
                    title: const Text('Rating'),
                    icon: Icons.star_rounded,
                    action: _provider<RatingCubit, double>(
                      bloc: filter.rating,
                      builder: (_, rating, __) =>
                          _modernRatingSlider(context, rating, filter),
                    ),
                  ),
                  _FilterItem(
                    title: const Text('Quality'),
                    icon: Icons.high_quality_rounded,
                    action: _modernDropdown<QualityCubit>(
                      context: context,
                      bloc: filter.quality,
                      hint: 'Any Quality',
                      items: QualityCubit.quality
                          .map((e) => DropdownMenuItem<String>(
                                value: e,
                                child: Text(e),
                              ))
                          .toList(),
                    ),
                  ),
                  _FilterItem(
                    title: const Text('Genre'),
                    icon: Icons.category_rounded,
                    action: _modernDropdown<GenreCubit>(
                      context: context,
                      bloc: filter.genre,
                      hint: 'All Genres',
                      items: list.genres
                          .map((e) => DropdownMenuItem<String>(
                                value: e.value,
                                child: Text(e.label),
                              ))
                          .toList(),
                    ),
                  ),
                  _FilterItem(
                    title: const Text('Sort By'),
                    icon: Icons.sort_rounded,
                    action: _modernDropdown<SortCubit>(
                      context: context,
                      bloc: filter.sort,
                      hint: 'Default',
                      items: list.sorts
                          .map((e) => DropdownMenuItem<String>(
                                value: e.value,
                                child: Text(e.label),
                              ))
                          .toList(),
                    ),
                  ),
                  _FilterItem(
                    title: const Text('Descending'),
                    icon: Icons.swap_vert_rounded,
                    action: _provider<OrderCubit, bool>(
                      bloc: filter.order,
                      builder: (_, order, __) =>
                          _modernSwitch(context, order, filter),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Modern action buttons
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: _modernActionButton(
                            context,
                            onPressed: () {
                              filter.reset();
                              HapticFeedback.lightImpact();
                            },
                            label: 'Reset',
                            icon: Icons.refresh_rounded,
                            isPrimary: false,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: _modernActionButton(
                            context,
                            onPressed: () {
                              onApplyFilter();
                              Navigator.of(context).pop();
                              HapticFeedback.mediumImpact();
                            },
                            label: 'Apply Filters',
                            icon: Icons.check_rounded,
                            isPrimary: true,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Safe area padding
                  SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _modernRatingSlider(
      BuildContext context, double rating, Filter filter) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${rating.round()}+ ⭐',
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 6,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
              activeTrackColor: Theme.of(context).primaryColor,
              inactiveTrackColor: isDark ? Colors.grey[700] : Colors.grey[300],
              thumbColor: Theme.of(context).primaryColor,
              overlayColor: Theme.of(context).primaryColor.withOpacity(0.2),
            ),
            child: Slider(
              value: rating,
              onChanged: filter.rating.changeHandler,
              divisions: 9,
              max: 9,
              min: 0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _modernDropdown<T extends DropdownCubit>({
    required BuildContext context,
    required T bloc,
    required String hint,
    required List<DropdownMenuItem<String>> items,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _provider<T, String?>(
      bloc: bloc,
      builder: (_, data, __) => Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[800] : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
        ),
        child: DropdownButtonFormField<String>(
          value: data,
          items: items,
          onChanged: bloc.changeHandler,
          hint: Text(
            hint,
            style: TextStyle(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          decoration: InputDecoration(
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            suffixIcon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          dropdownColor: isDark ? Colors.grey[800] : Colors.white,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 14,
          ),
          icon: const SizedBox.shrink(),
        ),
      ),
    );
  }

  Widget _modernSwitch(BuildContext context, bool value, Filter filter) {
    return Container(
      decoration: BoxDecoration(
        color: value
            ? Theme.of(context).primaryColor.withOpacity(0.1)
            : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Switch.adaptive(
        value: value,
        onChanged: filter.order.changeHandler,
        activeColor: Theme.of(context).primaryColor,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  Widget _modernActionButton(
    BuildContext context, {
    required VoidCallback onPressed,
    required String label,
    required IconData icon,
    bool isPrimary = true,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: isPrimary
            ? LinearGradient(
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color:
            isPrimary ? null : (isDark ? Colors.grey[800] : Colors.grey[100]),
        boxShadow: isPrimary
            ? [
                BoxShadow(
                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: isPrimary
              ? Colors.white
              : (isDark ? Colors.grey[300] : Colors.grey[700]),
          size: 20,
        ),
        label: Text(
          label,
          style: TextStyle(
            color: isPrimary
                ? Colors.white
                : (isDark ? Colors.grey[300] : Colors.grey[700]),
            fontWeight: isPrimary ? FontWeight.w600 : FontWeight.w500,
            fontSize: 16,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  Widget _provider<T extends BlocBase<S>, S>({
    required T bloc,
    required Widget Function(BuildContext, S, Widget?) builder,
    Widget? child,
  }) {
    return BlocBuilder<T, S>(
      bloc: bloc,
      buildWhen: (state, oldState) => state != oldState,
      builder: (context, state) => builder(context, state, child),
    );
  }
}
