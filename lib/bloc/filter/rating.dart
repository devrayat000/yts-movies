part of 'index.dart';

class RatingEvent {
  final double value;
  const RatingEvent([this.value = 0]);
}

class RatingBloc extends HydratedBloc<RatingEvent, double> {
  RatingBloc() : super(0.0);

  @override
  Stream<double> mapEventToState(RatingEvent event) async* {
    print(event.value);
    yield event.value;
  }

  void changeHandler(double newValue) {
    this.add(RatingEvent(newValue));
  }

  void reset() {
    this.add(RatingEvent());
    this.clear();
  }

  @override
  double? fromJson(Map<String, dynamic> json) => json['value'] as double?;

  @override
  Map<String, dynamic>? toJson(double state) => {'value': state};
}
