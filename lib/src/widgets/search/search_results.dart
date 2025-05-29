import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ytsmovies/src/api/movies.dart';
import 'package:ytsmovies/src/widgets/index.dart';

class SearchResults extends StatelessWidget {
  final String query;
  final Map<String, dynamic> params;

  const SearchResults({
    super.key,
    required this.query,
    required this.params,
  });

  @override
  Widget build(BuildContext context) {
    log("Building search results for query: $query");

    final repo = context.read<MoviesClient>();

    return MoviesPagedView(
      handler: (page) async {
        final response = await repo.getMovieList(
          page: page,
          queryTerm: query,
          queries: params,
        );
        return response;
      },
      noItemBuilder: (context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'No results found for "$query"',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search terms or filters',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
