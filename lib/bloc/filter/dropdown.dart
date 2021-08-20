part of './index.dart';

class DropdownEvent {
  final String? value;
  DropdownEvent([this.value]);
}

abstract class DropdownCubit extends HydratedCubit<String?> {
  final String? _default;
  DropdownCubit(this._default) : super(_default);

  void changeHandler(String? newValue) => emit(newValue);

  void reset() {
    emit(_default);
    this.clear();
  }

  @override
  String? fromJson(Map<String, dynamic> json) => json['value'] as String?;

  @override
  Map<String, dynamic>? toJson(String? state) => {'value': state};
}

class QualityCubit extends DropdownCubit {
  static final quality = qualities.values.toList(growable: false);

  QualityCubit() : super(null);
}

class GenreCubit extends DropdownCubit {
  GenreCubit() : super(list.genres[0].value);
}

class SortCubit extends DropdownCubit {
  SortCubit() : super(list.sorts[0].value);
}

abstract class DropdownBloc extends HydratedBloc<DropdownEvent, String?> {
  final String? _default;
  DropdownBloc([this._default]) : super(_default);

  @override
  Stream<String?> mapEventToState(DropdownEvent event) async* {
    print(event.value);
    yield event.value;
  }

  void changeHandler(String? newValue) => add(DropdownEvent(newValue));

  void reset() {
    add(DropdownEvent(_default));
    this.clear();
  }

  @override
  String? fromJson(Map<String, dynamic> json) => json['value'] as String?;

  @override
  Map<String, dynamic>? toJson(String? state) => {'value': state};
}

class QualityBloc extends DropdownBloc {
  static final quality = qualities.values.toList(growable: false);

  // QualityBloc() : super();
}

class GenreBloc extends DropdownBloc {
  GenreBloc() : super(list.genres[0].value);
}

class SortBloc extends DropdownBloc {
  SortBloc() : super(list.sorts[0].value);
}
