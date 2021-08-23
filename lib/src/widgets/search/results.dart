import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import 'package:ytsmovies/src/mock/movie.dart';
import 'package:ytsmovies/src/widgets/cards/actionbar.dart';
import 'package:ytsmovies/src/widgets/movie_list.dart';

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
                MovieList(controller: controller),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
