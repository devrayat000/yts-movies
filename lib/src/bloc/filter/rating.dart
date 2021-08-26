part of app_bloc.filter;

class RatingEvent {
  final double value;
  const RatingEvent([this.value = 0]);
}

class RatingCubit extends HydratedCubit<double> {
  RatingCubit() : super(0.0);

  void changeHandler(double newValue) {
    assert(newValue <= 9.0 && newValue >= 0.0, 'Value should between 0 to 9');
    emit(newValue);
  }

  void reset() {
    emit(0.0);
    clear();
  }

  @override
  double? fromJson(Map<String, dynamic> json) => json['value'] as double?;

  @override
  Map<String, dynamic>? toJson(double state) => {'value': state};
}
