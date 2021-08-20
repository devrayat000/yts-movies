part of 'index.dart';

// class SearchApiBloc extends ApiBloc {
//   bool _searchInitiated = false;
//   Map<String, dynamic>? _params;

//   void search(Map<String, dynamic> params) {
//     _params = params;
//     _searchInitiated = true;
//   }

//   @override
//   Stream<PageState> mapEventToState(int page) async* {
//     if (!_searchInitiated) {
//       yield PageStateSuccess(list: [], nextPage: 0);
//     } else {
//       yield* super.mapEventToState(page);
//     }
//   }

//   @override
//   Resolver get resolver => ([int? page]) {
//         return Api.listMovieByrawParams(page, _params);
//       };
// }
