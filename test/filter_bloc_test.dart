import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/foundation.dart';
import 'package:test/test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
// import 'package:mockito/mockito.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ytsmovies/src/bloc/filter/index.dart';

class MockRatingCubit extends MockCubit<double> implements RatingCubit {}

void main() async {
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorage.webStorageDirectory
        : await getTemporaryDirectory(),
  );
  ratingTest();
  orderTest();
}

void orderTest() {
  group('OrderCubit', () {
    blocTest<OrderCubit, bool>(
      'Emits [] when initialized',
      build: () => OrderCubit(),
      expect: () => [],
    );
    blocTest<OrderCubit, bool>(
      'Emits [true] when seeded with [false]',
      build: () => OrderCubit(),
      seed: () => false,
      act: (cubit) => cubit.changeHandler(),
      expect: () => [true],
    );
    blocTest<OrderCubit, bool>(
      'Emits nothing when seeded with [true] & explicitly given [true]',
      build: () => OrderCubit(),
      seed: () => true,
      act: (cubit) => cubit.changeHandler(true),
      expect: () => [],
    );
    blocTest<OrderCubit, bool>(
      'Emits [false] when reset',
      build: () => OrderCubit(),
      seed: () => false,
      act: (cubit) => cubit
        ..changeHandler(true)
        ..reset(),
      skip: 1,
      expect: () => [false],
    );
  });
}

void ratingTest() {
  group('whenListen', () {
    test("Let's mock the CounterCubit's stream!", () {
      // Create Mock CounterCubit Instance
      final cubit = MockRatingCubit();

      // Stub the listen with a fake Stream
      whenListen(cubit, Stream.fromIterable(<double>[0, 1, 2, 3]));

      // Expect that the CounterCubit instance emitted the stubbed Stream of
      // states
      expectLater(cubit.stream, emitsInOrder(<double>[0, 1, 2, 3]));
    });
  });
  group('RatingCubit', () {
    blocTest<RatingCubit, double>(
      'Emits [] when nothing is called',
      build: () => RatingCubit(),
      expect: () => const <double>[],
    );
    blocTest<RatingCubit, double>(
      'Emits [4] when called changeHandler with value: 4.0',
      build: () => RatingCubit(),
      act: (cubit) => cubit.changeHandler(4.0),
      expect: () => const <double>[4.0],
    );
    blocTest<RatingCubit, double>(
      'Emits [2] when called changeHandler with value: 4.0, 2.0. skipped 1 emit:4.0',
      build: () => RatingCubit(),
      act: (cubit) => cubit..changeHandler(4.0)..changeHandler(2.0),
      skip: 1,
      expect: () => const <double>[2.0],
    );
    blocTest<RatingCubit, double>(
      'Emits [3, 7] when called changeHandler with value: 3.0, 7.0',
      build: () => RatingCubit(),
      act: (cubit) => cubit..changeHandler(3.0)..changeHandler(7.0),
      expect: () => const <double>[3.0, 7.0],
    );
    blocTest<RatingCubit, double>(
      'Throws AssertionError when called changeHandler with value > 9.0',
      build: () => RatingCubit(),
      act: (cubit) => cubit.changeHandler(10.0),
      errors: () => [isA<AssertionError>()],
    );
    blocTest<RatingCubit, double>(
      'Emits [0.0] when reset',
      build: () => RatingCubit(),
      act: (cubit) => cubit
        ..changeHandler(5.0)
        ..reset(),
      skip: 1,
      expect: () => [0.0],
    );
  });
}
