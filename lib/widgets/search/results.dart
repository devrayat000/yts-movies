import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import 'package:ytsmovies/models/movie.dart';
import 'package:ytsmovies/utils/constants.dart';
import 'package:ytsmovies/widgets/cards/actionbar.dart';
import 'package:ytsmovies/widgets/cards/movie_card.dart';
import 'package:ytsmovies/widgets/cards/shimmer_movie_card.dart';

class SearchResults extends StatelessWidget {
  final PagingController<int, Movie> controller;
  final LayerLink link;
  final VoidCallback? onToggleFilter;
  SearchResults({
    Key? key,
    required this.controller,
    required this.link,
    required this.onToggleFilter,
  }) : super(key: key);

  final _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: link,
      child: Container(
        margin: const EdgeInsets.all(8.0),
        child: CupertinoScrollbar(
          controller: _scrollController,
          child: RefreshIndicator(
            onRefresh: () async => controller.refresh(),
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverActionBar(
                  floating: true,
                  snap: true,
                  actions: [
                    IconButton(
                      onPressed: () {
                        onToggleFilter?.call();
                      },
                      icon: const Icon(Icons.filter_alt_outlined),
                      splashRadius: 20,
                    ),
                  ],
                ),
                _grid,
              ],
            ),
          ),
        ),
      ),
    );
  }

  static const _shimmer = const MovieListShimmer();

  Widget get _grid => Builder(
        builder: (context) => PagedSliverGrid<int, Movie>(
          pagingController: controller,
          shrinkWrapFirstPageIndicators: true,
          builderDelegate: PagedChildBuilderDelegate(
            itemBuilder: (context, movie, i) => MovieCard(movie: movie),
            firstPageProgressIndicatorBuilder: (_) => _shimmer,
            newPageProgressIndicatorBuilder: (_) => MyGlobals.kCircularLoading,
            firstPageErrorIndicatorBuilder: _errorBuilder,
            newPageErrorIndicatorBuilder: _errorBuilder,
            noItemsFoundIndicatorBuilder: (context) => Container(
              alignment: Alignment.topCenter,
              child: Text(
                'No movie found',
                style: Theme.of(context).textTheme.headline5,
              ),
            ),
            noMoreItemsIndicatorBuilder: (context) => Center(
              child: Text(
                'That\'s the last of it...',
                style: Theme.of(context).textTheme.headline5,
              ),
            ),
          ),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1,
            childAspectRatio: 9 / 4,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
          ),
        ),
      );

  Widget _errorBuilder(BuildContext context) => Column(
        children: [
          Text(
            controller.error.toString(),
            style: Theme.of(context).textTheme.headline5,
          ),
          TextButton(
            onPressed: controller.refresh,
            child: const Text('Retry'),
          ),
        ],
      );
}
