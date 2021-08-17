part of './index.dart';

class DropdownEvent {
  final String? value;
  DropdownEvent([this.value]);
}

abstract class DropdownBloc extends HydratedBloc<DropdownEvent, String?> {
  DropdownBloc(String? _default) : super(_default);

  @override
  Stream<String?> mapEventToState(DropdownEvent event) async* {
    print(event.value);
    yield event.value;
  }

  void changeHandler(String? newValue) {
    this.add(DropdownEvent(newValue));
  }

  void reset() {
    this.add(DropdownEvent());
    this.clear();
  }

  @override
  String? fromJson(Map<String, dynamic> json) => json['value'] as String?;

  @override
  Map<String, dynamic>? toJson(String? state) => {'value': state};
}

class QualityBloc extends DropdownBloc {
  static final quality =
      Quality.values.map((e) => e.val).toList(growable: false);

  QualityBloc() : super(null);
}

class GenreBloc extends DropdownBloc {
  GenreBloc() : super(list.genres[0].value);
}

class SortBloc extends DropdownBloc {
  SortBloc() : super(list.sorts[0].value);
}
