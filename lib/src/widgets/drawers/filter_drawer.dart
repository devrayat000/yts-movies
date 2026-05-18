part of '../index.dart';

class FilterBottomSheet extends StatefulWidget {
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
      enableDrag: true,
      isDismissible: true,
      routeSettings: RouteSettings(
        name: 'FilterBottomSheet',
      ),
      builder: (context) => FilterBottomSheet(onApplyFilter: onApplyFilter),
    );
  }

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filter = context.read<Filter>();
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    colorScheme.surface,
                    colorScheme.surface.withAlpha((0.95 * 255).toInt()),
                  ],
                ),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha((0.15 * 255).toInt()),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.85,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Modern drag handle
                    Container(
                      margin: const EdgeInsets.only(top: 20, bottom: 12),
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: colorScheme.onSurface
                            .withAlpha((0.3 * 255).toInt()),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    // Enhanced title section with gradient background
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 8, 16, 20),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  colorScheme.primary,
                                  colorScheme.primary
                                      .withAlpha((0.8 * 255).toInt()),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: colorScheme.primary
                                      .withAlpha((0.3 * 255).toInt()),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.tune_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Filter Movies',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 22,
                                        color: colorScheme.onSurface,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Customize your movie search',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: colorScheme.onSurface
                                            .withAlpha((0.6 * 255).toInt()),
                                        fontSize: 14,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: Icon(
                              Icons.close_rounded,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            splashRadius: 20,
                          ),
                        ],
                      ),
                    ), // Filters content with modern styling
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Column(
                          children: [
                            _CompactFilterItem(
                              title: 'Rating',
                              subtitle: 'Minimum IMDB rating',
                              icon: Icons.star_rounded,
                              iconColor: Colors.amber,
                              action: _provider<RatingCubit, double>(
                                bloc: filter.rating,
                                builder: (_, rating, __) => _modernRatingSlider(
                                    context, rating, filter),
                              ),
                            ),
                            _CompactFilterItem(
                              title: 'Quality',
                              subtitle: 'Video resolution',
                              icon: Icons.high_quality_rounded,
                              iconColor: Colors.green,
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
                            _CompactFilterItem(
                              title: 'Genre',
                              subtitle: 'Movie category',
                              icon: Icons.category_rounded,
                              iconColor: Colors.purple,
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
                            _CompactFilterItem(
                              title: 'Sort By',
                              subtitle: 'Order results by',
                              icon: Icons.sort_rounded,
                              iconColor: Colors.blue,
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
                            _CompactFilterItem(
                              title: 'Sort Order',
                              subtitle: 'Ascending or descending',
                              icon: Icons.swap_vert_rounded,
                              iconColor: Colors.orange,
                              action: _provider<OrderCubit, bool>(
                                bloc: filter.order,
                                builder: (_, order, __) =>
                                    _modernSwitch(context, order, filter),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Modern action buttons
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 24.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 2,
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
                                    flex: 3,
                                    child: _modernActionButton(
                                      context,
                                      onPressed: () {
                                        widget.onApplyFilter();
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
                            ), // Safe area padding
                            SizedBox(
                                height:
                                    MediaQuery.of(context).padding.bottom + 16),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _modernRatingSlider(
      BuildContext context, double rating, Filter filter) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 6,
              thumbShape: const RoundSliderThumbShape(
                enabledThumbRadius: 10,
              ),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
              activeTrackColor: colorScheme.primary,
              inactiveTrackColor:
                  colorScheme.outline.withAlpha((0.2 * 255).toInt()),
              thumbColor: colorScheme.primary,
              overlayColor: colorScheme.primary.withAlpha((0.15 * 255).toInt()),
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
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: colorScheme.primary.withAlpha((0.1 * 255).toInt()),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            rating == 0 ? 'Any' : '${rating.round()}+',
            style: TextStyle(
              color: colorScheme.primary,
              fontWeight: FontWeight.w600,
              fontSize: 12,
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
    final colorScheme = Theme.of(context).colorScheme;
    return _provider<T, String?>(
      bloc: bloc,
      builder: (_, data, __) => SizedBox(
        height: 40,
        child: DropdownButtonFormField<String>(
          value: data,
          items: items,
          onChanged: bloc.changeHandler,
          hint: Text(
            hint,
            style: TextStyle(
              color: colorScheme.onSurface.withAlpha((0.6 * 255).toInt()),
              fontSize: 13,
            ),
          ),
          decoration: const InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
          ),
          dropdownColor: colorScheme.surface,
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 13,
          ),
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: colorScheme.onSurface.withAlpha((0.6 * 255).toInt()),
            size: 18,
          ),
          borderRadius: BorderRadius.circular(16),
          elevation: 4,
          isDense: true,
          menuMaxHeight: 200,
        ),
      ),
    );
  }

  Widget _modernSwitch(BuildContext context, bool value, Filter filter) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          value ? 'Desc' : 'Asc',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withAlpha((0.7 * 255).toInt()),
                fontSize: 12,
              ),
        ),
        Transform.scale(
          scale: 0.8,
          child: Switch.adaptive(
            value: value,
            onChanged: filter.order.changeHandler,
            activeColor: colorScheme.primary,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ],
    );
  }

  Widget _modernActionButton(
    BuildContext context, {
    required VoidCallback onPressed,
    required String label,
    required IconData icon,
    bool isPrimary = true,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: isPrimary
            ? LinearGradient(
                colors: [
                  colorScheme.primary,
                  colorScheme.primary.withAlpha((0.8 * 255).toInt()),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isPrimary
            ? null
            : colorScheme.surfaceContainerHighest
                .withAlpha((0.5 * 255).toInt()),
        border: !isPrimary
            ? Border.all(
                color: colorScheme.outline.withAlpha((0.2 * 255).toInt()),
              )
            : null,
        boxShadow: isPrimary
            ? [
                BoxShadow(
                  color: colorScheme.primary.withAlpha((0.3 * 255).toInt()),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                  spreadRadius: 0,
                ),
              ]
            : null,
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: isPrimary ? Colors.white : colorScheme.onSurfaceVariant,
          size: 20,
        ),
        label: Text(
          label,
          style: TextStyle(
            color: isPrimary ? Colors.white : colorScheme.onSurfaceVariant,
            fontWeight: isPrimary ? FontWeight.w600 : FontWeight.w500,
            fontSize: 16,
            letterSpacing: 0.5,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
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

  Widget _CompactFilterItem({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Widget action,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 6.0),
      child: Row(
        children: [
          // Icon and title section
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: iconColor.withAlpha((0.1 * 255).toInt()),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                              fontSize: 13,
                            ),
                      ),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurface
                                  .withAlpha((0.6 * 255).toInt()),
                              fontSize: 11,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Action section
          Expanded(
            flex: 3,
            child: action,
          ),
        ],
      ),
    );
  }
}
