import 'package:flutter/foundation.dart' show ChangeNotifier;

import '../models/label_value.dart';

class Filter extends ChangeNotifier {
  final OrderFilter order = OrderFilter();
  final SortFilter sort = SortFilter();
  final GenreFilter genre = GenreFilter();
  final QualityFilter quality = QualityFilter();
  final RatingFilter rating = RatingFilter();

  void reset() {
    order.reset();
    sort.reset();
    genre.reset();
    quality.reset();
    rating.reset();
  }

  Map<String, dynamic> get values {
    final params = {
      'order_by': order._isDesc ? 'desc' : null,
      'sort': sort.selected,
      'genre': genre.selected,
      'quality': quality.selected,
      'rating': rating.value.round().toString(),
    };
    return params..removeWhere((_, value) => value == null || value == '0');
  }

  set initialValues(covariant Filter instance) {
    if (instance != this) {
      order.initialValue = instance.order.value;
      sort.initialValue = instance.sort.selected;
      genre.initialValue = instance.genre.selected;
      quality.initialValue = instance.quality.selected;
      rating.initialValue = instance.rating.value.toInt();
    }
  }
}

class OrderFilter extends ChangeNotifier {
  bool _isDesc = false;

  void changeHandler(bool newValue) {
    _isDesc = newValue;
    notifyListeners();
  }

  void reset() {
    _isDesc = false;
    notifyListeners();
  }

  bool get value => _isDesc;
  set initialValue(bool value) => _isDesc = value;
}

class SortFilter extends DropDownNotifier {
  static const items = const [
    LabelValue('Latest', null),
    LabelValue('Alphabetical', 'title'),
    LabelValue('Year', 'year'),
    LabelValue('Rating', 'rating'),
    LabelValue('Peers', 'peers'),
    LabelValue('Seeds', 'seeds'),
    LabelValue('Downloads', 'download_count'),
    LabelValue('Likes', 'like_count'),
  ];

  SortFilter() : super(items[0].value);
}

class GenreFilter extends DropDownNotifier {
  static const items = const [
    LabelValue("All", null),
    LabelValue("Action", "action"),
    LabelValue("Adventure", "adventure"),
    LabelValue("Animation", "animation"),
    LabelValue("Biography", "biography"),
    LabelValue("Comedy", "comedy"),
    LabelValue("Crime", "crime"),
    LabelValue("Documentary", "documentary"),
    LabelValue("Drama", "drama"),
    LabelValue("Family", "family"),
    LabelValue("Fantasy", "fantasy"),
    LabelValue("Film-Noir", "film-noir"),
    LabelValue("Game-Show", "game-show"),
    LabelValue("History", "history"),
    LabelValue("Horror", "horror"),
    LabelValue("Music", "music"),
    LabelValue("Musical", "musical"),
    LabelValue("Mystery", "mystery"),
    LabelValue("News", "news"),
    LabelValue("Reality-TV", "reality-tv"),
    LabelValue("Romance", "romance"),
    LabelValue("Sci-Fi", "sci-fi"),
    LabelValue("Sport", "sport"),
    LabelValue("Talk-Show", "talk-show"),
    LabelValue("Thriller", "thriller"),
    LabelValue("War", "war"),
    LabelValue("Western", "western"),
  ];

  GenreFilter() : super(items[0].value);
}

class QualityFilter extends DropDownNotifier {
  static const quality = const ['720p', '1080p', '2160p', '3D'];

  QualityFilter() : super(null);

  String? get selected => _selected;
}

class RatingFilter extends ChangeNotifier {
  int _default = 0;
  late int _value;

  RatingFilter() {
    _value = _default;
  }

  void changeHandler(double newValue) {
    _value = newValue.round();
    notifyListeners();
  }

  void reset() {
    _value = _default;
    notifyListeners();
  }

  double get value => _value.toDouble();
  set initialValue(int value) => _value = value;
}

abstract class DropDownNotifier extends ChangeNotifier {
  String? _default;
  String? _selected;

  DropDownNotifier(String? defaultValue) {
    _default = defaultValue;
    _selected = defaultValue;
  }

  void changeHandler(String? newValue) {
    _selected = newValue;
    notifyListeners();
  }

  void reset() {
    _selected = _default;
    notifyListeners();
  }

  String? get selected => _selected;
  set initialValue(String? value) => _selected = value;
}
