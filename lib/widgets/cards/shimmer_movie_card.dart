import 'package:flutter/material.dart';
import 'package:ytsmovies/widgets/shimmer.dart';

class ShimmerMovieCard extends StatelessWidget {
  // const ShimmerMovieCard({ Key? key }) : super(key: key);
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
            child: isGrid ? _grid(context) : _list(context),
          ),
        ),
      ),
    );
  }

  Widget _list(BuildContext context) => Flex(
        direction: Axis.horizontal,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _image(context),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _title(context),
                ..._desc(context),
              ],
            ),
          ),
        ],
      );

  Widget _grid(BuildContext context) => Flex(
        direction: Axis.vertical,
        children: [
          Expanded(
            flex: 3,
            child: Flex(
              direction: Axis.horizontal,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _image(context)),
                Expanded(
                  child: Column(
                    children: _desc(context),
                  ),
                ),
              ],
            ),
          ),
          Expanded(flex: 1, child: _title(context)),
        ],
      );

  Widget _image(BuildContext context) => LimitedBox(
        maxHeight: 170,
        child: AspectRatio(
          aspectRatio: 2 / 3,
          child: ColoredBox(color: Theme.of(context).colorScheme.onSurface),
        ),
      );

  Widget _title(BuildContext context) => Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              width: double.infinity,
              height: 16,
              decoration: _decoration(context),
            ),
            const SizedBox(height: 12),
            FractionallySizedBox(
              widthFactor: 0.7,
              child: Container(
                height: 16,
                decoration: _decoration(context),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      );

  List<Widget> _desc(BuildContext context) => [
        ...List.generate(
            4,
            (i) => Container(
                  height: 8,
                  margin: EdgeInsets.symmetric(vertical: 4.0),
                  decoration: _decoration(context),
                )),
        FractionallySizedBox(
          widthFactor: 0.6,
          child: Container(
            height: 10,
            margin: EdgeInsets.symmetric(vertical: 4.0),
            decoration: _decoration(context),
          ),
        ),
      ];

  Decoration _decoration(BuildContext context) => BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface,
        borderRadius: BorderRadius.circular(16),
      );
}
