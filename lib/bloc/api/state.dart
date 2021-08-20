import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:ytsmovies/mock/movie.dart';

@immutable
abstract class PageState with EquatableMixin {}

class PageStateInitial extends PageState {
  @override
  List<Object?> get props => [];
}

class PageStateSuccess extends PageState {
  final List<Movie> list;
  final int nextPage;
  final bool isLast;

  PageStateSuccess({
    required this.list,
    required this.nextPage,
    this.isLast = false,
  });

  // PageStateSuccess.empty()
  //     : list = const [],
  //       nextPage = 0,
  //       isLast = false;

  @override
  List<Object?> get props => [list, nextPage, isLast];
}

class PageStateError extends PageState {
  final Object error;
  final StackTrace? stackTrace;

  PageStateError(this.error, [this.stackTrace]);

  @override
  List<Object?> get props => [error, stackTrace];
}
