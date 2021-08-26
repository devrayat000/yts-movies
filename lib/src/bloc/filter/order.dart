part of app_bloc.filter;

class OrderEvent {
  final bool value;
  OrderEvent([this.value = false]);
}

class OrderCubit extends HydratedCubit<bool> {
  OrderCubit() : super(false);

  void changeHandler([bool? newValue]) => emit(newValue ?? !this.state);

  void reset() {
    emit(false);
    clear();
  }

  @override
  bool? fromJson(Map<String, dynamic> json) => json['value'] as bool?;

  @override
  Map<String, dynamic>? toJson(bool state) => {'value': state};
}
