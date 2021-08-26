part of app_bloc.filter;

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
