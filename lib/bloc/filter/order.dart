part of 'index.dart';

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

class OrderBloc extends HydratedBloc<OrderEvent, bool> {
  OrderBloc() : super(false);

  @override
  Stream<bool> mapEventToState(OrderEvent event) async* {
    print(event);
    yield event.value;
  }

  void changeHandler([bool? newValue]) =>
      add(OrderEvent(newValue ?? !this.state));

  void reset() {
    add(OrderEvent());
    clear();
  }

  @override
  bool? fromJson(Map<String, dynamic> json) => json['value'] as bool?;

  @override
  Map<String, dynamic>? toJson(bool state) => {'value': state};
}
