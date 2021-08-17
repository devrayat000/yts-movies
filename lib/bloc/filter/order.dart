part of 'index.dart';

class OrderEvent {
  final bool value;
  OrderEvent([this.value = false]);
}

class OrderBloc extends HydratedBloc<OrderEvent, bool> {
  OrderBloc() : super(false);

  @override
  Stream<bool> mapEventToState(OrderEvent event) async* {
    print(event.value);
    yield event.value;
  }

  void changeHandler([bool? newValue]) {
    this.add(OrderEvent(newValue ?? !this.state));
  }

  void reset() {
    this.add(OrderEvent());
    this.clear();
  }

  @override
  bool? fromJson(Map<String, dynamic> json) => json['value'] as bool?;

  @override
  Map<String, dynamic>? toJson(bool state) => {'value': state};
}
