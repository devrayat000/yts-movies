// import 'package:flutter/foundation.dart' show ChangeNotifier;

// import 'package:ytsmovies/utils/enums.dart';
// import 'package:ytsmovies/utils/lists.dart' as list;

// class Filter {
//   final OrderFilter order = OrderFilter();
//   final SortFilter sort = SortFilter();
//   final GenreFilter genre = GenreFilter();
//   final QualityFilter quality = QualityFilter();
//   final RatingFilter rating = RatingFilter();

//   void reset() {
//     order.reset();
//     sort.reset();
//     genre.reset();
//     quality.reset();
//     rating.reset();
//   }

//   Map<String, dynamic> get values {
//     final params = {
//       'order_by': order._isDesc ? 'desc' : null,
//       'sort': sort.selected,
//       'genre': genre.selected,
//       'quality': quality.selected,
//       'rating': rating.value.round().toString(),
//     };
//     return params..removeWhere((_, value) => value == null || value == '0');
//   }

//   // set initialValues(covariant Filter instance) {
//   //   if (instance != this) {
//   //     order.initialValue = instance.order.value;
//   //     sort.initialValue = instance.sort.selected;
//   //     genre.initialValue = instance.genre.selected;
//   //     quality.initialValue = instance.quality.selected;
//   //     rating.initialValue = instance.rating.value.toInt();
//   //   }
//   // }
// }

// class OrderFilter with ChangeNotifier {
//   bool _isDesc = false;

//   void changeHandler(bool newValue) {
//     _isDesc = newValue;
//     notifyListeners();
//   }

//   void reset() {
//     _isDesc = false;
//     notifyListeners();
//   }

//   bool get value => _isDesc;
//   set initialValue(bool value) => _isDesc = value;
// }

// class SortFilter extends DropDownNotifier {
//   SortFilter() : super(list.sorts[0].value);
// }

// class GenreFilter extends DropDownNotifier {
//   GenreFilter() : super(list.genres[0].value);
// }

// class QualityFilter extends DropDownNotifier {
//   static final quality =
//       Quality.values.map((e) => e.val).toList(growable: false);

//   QualityFilter() : super(null);
// }

// class RatingFilter with ChangeNotifier {
//   int _default = 0;
//   late int _value;

//   RatingFilter() {
//     _value = _default;
//   }

//   void changeHandler(double newValue) {
//     _value = newValue.round();
//     notifyListeners();
//   }

//   void reset() {
//     _value = _default;
//     notifyListeners();
//   }

//   double get value => _value.toDouble();
//   set initialValue(int value) => _value = value;
// }

// abstract class DropDownNotifier with ChangeNotifier {
//   String? _default;
//   String? _selected;

//   DropDownNotifier(this._default) : _selected = _default;

//   void changeHandler(String? newValue) {
//     _selected = newValue;
//     notifyListeners();
//   }

//   void reset() {
//     _selected = _default;
//     notifyListeners();
//   }

//   String? get selected => _selected;
//   set initialValue(String? value) => _selected = value;
// }
