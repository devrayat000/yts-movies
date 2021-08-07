import 'package:flutter/cupertino.dart' show CupertinoSwitch;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ytsmovies/utils/lists.dart' as list;

import '../../providers/filter_provider.dart';

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
            _FilterItem(
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
            _FilterItem(
              title: const Text('Genre'),
              action: _dropdown<GenreFilter>(
                notifier: _selector(context, (filter) => filter.genre),
                items: list.genres
                    .map((e) => DropdownMenuItem<String>(
                          child: Text(e.label),
                          value: e.value,
                        ))
                    .toList(),
              ),
            ),
            _FilterItem(
              title: const Text('Sort'),
              action: _dropdown<SortFilter>(
                notifier: _selector(context, (filter) => filter.sort),
                items: list.sorts
                    .map((e) => DropdownMenuItem<String>(
                          child: Text(e.label),
                          value: e.value,
                        ))
                    .toList(),
              ),
            ),
            _FilterItem(
              title: const Text('Descending'),
              action: _provider<OrderFilter>(
                notifier:
                    _selector<OrderFilter>(context, (filter) => filter.order),
                builder: (_, order, __) => CupertinoSwitch(
                  value: order.value,
                  onChanged: order.changeHandler,
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
        label: Text(label, style: TextStyle(color: Colors.white)),
        style: ElevatedButton.styleFrom(
          primary: color,
          animationDuration: Duration(milliseconds: 300),
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
        isDense: true,
        // itemHeight: 60,
        menuMaxHeight: 360,
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



//   keytool -genkey -v -keystore c:\Users\rayat\upload-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload

