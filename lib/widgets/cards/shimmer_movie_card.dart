import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:ytsmovies/providers/view_provider.dart';
import 'package:ytsmovies/theme/index.dart';
import 'package:ytsmovies/widgets/cards/shimmer_shapes.dart';

import '../shimmer.dart';

class MovieListShimmer extends StatelessWidget {
  const MovieListShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      linearGradient: context
          .select<AppTheme, LinearGradient>((theme) => theme.shimmerGradient),
      child: Consumer<GridListView>(
        builder: (context, view, child) {
          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: view.crossAxis,
              childAspectRatio: view.aspectRatio,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 6,
            shrinkWrap: true,
            itemBuilder: (context, i) {
              return ShimmerMovieCard(isGrid: view.isTrue);
            },
          );
        },
      ),
    );
  }
}

class ShimmerMovieCard extends StatelessWidget {
  final bool isGrid;

  const ShimmerMovieCard({Key? key, required this.isGrid}) : super(key: key);

  const ShimmerMovieCard.list({Key? key})
      : isGrid = false,
        super(key: key);
  const ShimmerMovieCard.grid({Key? key})
      : isGrid = true,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      isLoading: true,
      child: Container(
        child: Card(
          color: Theme.of(context).colorScheme.surface,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: isGrid ? _grid : _list,
          ),
        ),
      ),
    );
  }

  Widget get _list => Flex(
        direction: Axis.horizontal,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerShape.image(),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerShape.title(height: isGrid ? 12 : 16),
                Expanded(
                  child: ShimmerShape.desc(
                    height: isGrid ? 4 : 8,
                    count: isGrid ? 3 : 4,
                  ),
                ),
              ],
            ),
          ),
        ],
      );

  Widget get _grid => Flex(
        direction: Axis.vertical,
        children: [
          Expanded(
            flex: 3,
            child: Flex(
              direction: Axis.horizontal,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: ShimmerShape.image()),
                Expanded(
                  child: ShimmerShape.desc(
                    height: isGrid ? 4 : 8,
                    count: isGrid ? 3 : 4,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: ShimmerShape.title(height: isGrid ? 12 : 16),
          ),
        ],
      );
}
