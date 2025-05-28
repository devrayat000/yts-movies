part of app_widgets;

class _FilterItem extends StatelessWidget {
  final Widget title;
  final Widget action;
  const _FilterItem({
    required this.title,
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(flex: 2, child: title),
          const SizedBox(width: 16),
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

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filter Movies',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          const Divider(),

          // Filters content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                children: [
                  _FilterItem(
                    title: const Text('Rating'),
                    action: _provider<RatingCubit, double>(
                      bloc: filter.rating,
                      builder: (_, rating, __) => Column(
                        children: [
                          Text('${rating.round()}+'),
                          CupertinoSlider(
                            value: rating,
                            onChanged: filter.rating.changeHandler,
                            divisions: 9,
                            max: 9,
                          ),
                        ],
                      ),
                    ),
                  ),
                  _FilterItem(
                    title: const Text('Quality'),
                    action: _dropdown<QualityCubit>(
                      bloc: filter.quality,
                      hint: const Text('Any Quality'),
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
                    action: _dropdown<GenreCubit>(
                      bloc: filter.genre,
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
                    action: _dropdown<SortCubit>(
                      bloc: filter.sort,
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
                    action: _provider<OrderCubit, bool>(
                      bloc: filter.order,
                      builder: (_, order, __) => CupertinoSwitch(
                        value: order,
                        onChanged: filter.order.changeHandler,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Action buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: _actionButton(
                            context,
                            onPressed: () {
                              filter.reset();
                            },
                            label: 'Reset',
                            icon: Icons.refresh,
                            color: Colors.grey[600],
                            isPrimary: false,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _actionButton(
                            context,
                            onPressed: () {
                              onApplyFilter();
                              Navigator.of(context).pop();
                            },
                            label: 'Apply Filters',
                            icon: Icons.filter_list,
                            color: Theme.of(context).primaryColor,
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

  Widget _actionButton(
    BuildContext context, {
    required void Function()? onPressed,
    required String label,
    IconData? icon,
    Color? color,
    bool isPrimary = true,
  }) =>
      ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: isPrimary ? Colors.white : Colors.grey[700],
        ),
        label: Text(
          label,
          style: TextStyle(
            color: isPrimary ? Colors.white : Colors.grey[700],
            fontWeight: isPrimary ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          elevation: isPrimary ? 2 : 0,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: isPrimary
                ? BorderSide.none
                : BorderSide(color: Colors.grey[400]!),
          ),
        ),
      );

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

  Widget _dropdown<T extends DropdownCubit>({
    required T bloc,
    Widget? hint,
    required List<DropdownMenuItem<String>> items,
  }) {
    return _provider<T, String?>(
      bloc: bloc,
      child: hint,
      builder: (_, data, hintChild) => DropdownButtonFormField<String>(
        isDense: true,
        menuMaxHeight: 360,
        value: data,
        items: items,
        onChanged: bloc.changeHandler,
        hint: hintChild,
        elevation: 4,
        decoration: const InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(4)),
          ),
          isDense: true,
        ),
      ),
    );
  }
}
