import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'hive.freezed.dart';
part 'hive.g.dart';

@freezed
class Person with HiveObjectMixin, EquatableMixin, _$Person {
  Person._();

  @HiveType(typeId: 1, adapterName: 'PersonAdapter')
  factory Person({
    @HiveField(0) required String name,
    @HiveField(1) required int age,
    @HiveField(2) required List<String> friends,
  }) = _Person;

  @override
  String toString() {
    return '$name: $age';
  }

  @override
  List<Object?> get props => [name, age, friends];

  @override
  bool? get stringify => true;
}

// flutter pub run build_runner build
