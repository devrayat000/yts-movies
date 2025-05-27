part of app_widgets;

class _FilterItem extends StatelessWidget {
  final Widget title;
  final Widget action;
  const _FilterItem({
    Key? key,
    required this.title,
    required this.action,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        runSpacing: 8.0,
        children: [
          title,
          action,
        ],
      ),
    );
  }
}

class FilterDrawer extends StatelessWidget {
  final void Function() onApplyFilter;
  FilterDrawer({Key? key, required this.onApplyFilter}) : super(key: key);

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final _filter = context.read<Filter>();

    return Container(
      padding: const EdgeInsets.only(left: 180.0),
      color: Theme.of(context).canvasColor,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _FilterItem(
              title: const Text('Rating'),
              action: _provider<RatingCubit, double>(
                bloc: _filter.rating,
                builder: (_, rating, __) => Tooltip(
                  message: '${rating.round()}+',
                  child: CupertinoSlider(
                    value: rating,
                    onChanged: _filter.rating.changeHandler,
                    divisions: 9,
                    max: 9,
                  ),
                ),
              ),
            ),
            _FilterItem(
              title: const Text('Quality'),
              action: _dropdown<QualityCubit>(
                bloc: _filter.quality,
                hint: const Text('Select Resolution'),
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
                bloc: _filter.genre,
                items: list.genres
                    .map((e) => DropdownMenuItem<String>(
                          value: e.value,
                          child: Text(e.label),
                        ))
                    .toList(),
              ),
            ),
            _FilterItem(
              title: const Text('Sort'),
              action: _dropdown<SortCubit>(
                bloc: _filter.sort,
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
                bloc: _filter.order,
                builder: (_, order, __) => CupertinoSwitch(
                  value: order,
                  onChanged: _filter.order.changeHandler,
                ),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _actionButton(
                    context,
                    onPressed: () {
                      onApplyFilter();
                    },
                    label: 'Apply',
                    icon: Icons.search,
                    color: Colors.greenAccent[400],
                  ),
                  const SizedBox(width: 12),
                  _actionButton(
                    context,
                    onPressed: _filter.reset,
                    label: 'Reset',
                    icon: Icons.refresh,
                    color: Colors.redAccent[400],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton(
    BuildContext context, {
    required void Function()? onPressed,
    required String label,
    IconData? icon,
    Color? color,
  }) =>
      ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
        label: Text(label, style: const TextStyle(color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          animationDuration: const Duration(milliseconds: 300),
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
        // itemHeight: 60,
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



//   keytool -genkey -v -keystore c:\Users\rayat\upload-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload

