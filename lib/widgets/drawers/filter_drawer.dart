import 'package:flutter/cupertino.dart' show CupertinoSwitch;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/filter_provider.dart';

class SearchFilterDrawer extends StatelessWidget {
  final void Function() onApplyFilter;
  const SearchFilterDrawer({Key? key, required this.onApplyFilter})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        children: [
          const DrawerHeader(
            child: Text('Filter'),
          ),
          ListBody(
            children: ListTile.divideTiles(
              context: context,
              tiles: [
                FilterItem(
                  title: const Text('Rating'),
                  action: _provider<RatingFilter>(
                    notifier: _selector(context, (filter) => filter.rating),
                    builder: (_, rating, __) => Slider.adaptive(
                      value: rating.value,
                      label: '${rating.value.round()}+',
                      onChanged: rating.changeHandler,
                      divisions: 9,
                      max: 9,
                    ),
                  ),
                ),
                FilterItem(
                  title: const Text('Quality'),
                  action: _dropdown<QualityFilter>(
                    notifier: _selector(context, (filter) => filter.quality),
                    hint: const Text('Select Resolution'),
                    items: QualityFilter.quality
                        .map((e) => DropdownMenuItem<String>(
                              child: Text(e),
                              value: e,
                            ))
                        .toList(),
                  ),
                ),
                FilterItem(
                  title: const Text('Genre'),
                  action: _dropdown<GenreFilter>(
                    notifier: _selector(context, (filter) => filter.genre),
                    items: GenreFilter.items
                        .map((e) => DropdownMenuItem<String>(
                              child: Text(e.label),
                              value: e.value,
                            ))
                        .toList(),
                  ),
                ),
                FilterItem(
                  title: const Text('Sort'),
                  action: _dropdown<SortFilter>(
                    notifier: _selector(context, (filter) => filter.sort),
                    items: SortFilter.items
                        .map((e) => DropdownMenuItem<String>(
                              child: Text(e.label),
                              value: e.value,
                            ))
                        .toList(),
                  ),
                ),
                FilterItem(
                  title: const Text('Descending'),
                  action: _provider<OrderFilter>(
                    notifier: _selector<OrderFilter>(context, (filter) => filter.order),
                    builder: (_, order, __) => CupertinoSwitch(
                      value: order.value,
                      onChanged: order.changeHandler,
                    ),
                  ),
                ),
              ],
            ).toList(),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
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
                SizedBox(width: 12),
                _actionButton(
                  context,
                  onPressed: context.read<Filter>().reset,
                  label: 'Reset',
                  icon: Icons.refresh,
                  color: Colors.redAccent[400],
                ),
              ],
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
  }) =>
      Expanded(
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, color: Colors.white),
          label: Text(label, style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            primary: color,
            animationDuration: Duration(milliseconds: 300),
          ),
        ),
      );

  T _selector<T>(BuildContext context, T Function(Filter) selector) {
    return context.select<Filter, T>(selector);
  }

  Widget _provider<T extends ChangeNotifier?>({
    required T notifier,
    required Widget Function(BuildContext, T, Widget?) builder,
    Widget? child,
  }) {
    return ChangeNotifierProvider<T>.value(
      value: notifier,
      child: child,
      builder: (context, child) => builder(context, context.watch<T>(), child),
    );
  }

  Widget _dropdown<T extends DropDownNotifier?>({
    required T notifier,
    Widget? hint,
    required List<DropdownMenuItem<String>> items,
  }) {
    return _provider<T>(
      notifier: notifier,
      child: hint,
      builder: (_, data, hintChild) => DropdownButtonFormField<String>(
        value: data?.selected,
        items: items,
        onChanged: data?.changeHandler,
        hint: hintChild,
        elevation: 4,
        decoration: const InputDecoration(
          border: const OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(4)),
          ),
        ),
      ),
    );
  }
}

class FilterItem extends StatelessWidget {
  final Widget title;
  final Widget action;
  const FilterItem({
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
        runSpacing: 16.0,
        children: [
          title,
          action,
        ],
      ),
    );
  }
}



//   keytool -genkey -v -keystore c:\Users\rayat\upload-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload

