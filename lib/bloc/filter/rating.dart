part of 'index.dart';

class RatingEvent {
  final double value;
  const RatingEvent([this.value = 0]);
}

class RatingCubit extends HydratedCubit<double> {
  RatingCubit() : super(0.0);

  void changeHandler(double newValue) => emit(newValue);

  void reset() {
    emit(0.0);
    clear();
  }

  @override
  double? fromJson(Map<String, dynamic> json) => json['value'] as double?;

  @override
  Map<String, dynamic>? toJson(double state) => {'value': state};
}

class RatingBloc extends HydratedBloc<RatingEvent, double> {
  RatingBloc() : super(0.0);

  @override
  Stream<double> mapEventToState(RatingEvent event) async* {
    print(event);
    yield event.value;
  }

  void changeHandler(double newValue) {
    add(RatingEvent(newValue));
  }

  void reset() {
    add(RatingEvent());
    clear();
  }

  @override
  double? fromJson(Map<String, dynamic> json) => json['value'] as double?;

  @override
  Map<String, dynamic>? toJson(double state) => {'value': state};
}
