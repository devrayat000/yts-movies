import 'dart:math' as math;

import 'package:flutter/material.dart';

class CustomSliverAppbar extends StatelessWidget {
  const CustomSliverAppbar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: CustomDelegate(
        extendedHeight: MediaQuery.of(context).size.width,
      ),
    );
  }
}

class CustomDelegate extends SliverPersistentHeaderDelegate {
  final double collapsedHeight;
  final double extendedHeight;
  CustomDelegate({
    this.collapsedHeight = kToolbarHeight,
    this.extendedHeight = kToolbarHeight,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    double tempVal = 34 * maxExtent / 100;
    final progress = shrinkOffset > tempVal ? 1.0 : shrinkOffset / tempVal;
    print("Objechjkf === $progress $shrinkOffset");
    return FlexibleSpaceBar.createSettings(
      minExtent: minExtent,
      maxExtent: maxExtent,
      currentExtent: math.max(minExtent, maxExtent - shrinkOffset),
      toolbarOpacity: 1.0,
      child: Stack(
        children: [
          AppBar(
            backgroundColor: Colors.cyan,
            bottomOpacity: 0.7,
            flexibleSpace: FlexibleSpaceBar(
              background: Image(
                image: NetworkImage(
                  'https://img.yts.mx/assets/images/movies/the_suicide_squad_2021/medium-cover.jpg',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          if (progress <= 1.0)
            Transform.scale(
              scale: math.cos(progress * math.pi / 2),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                margin: const EdgeInsets.symmetric(horizontal: 8.0),
                width: double.infinity,
                // duration: Duration(milliseconds: 100),
                decoration: BoxDecoration(
                  color: Colors.grey[900]?.withOpacity(0.38),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: _detailsCard(context),
              ),
            ),
        ],
      ),
    );
  }

  @override
  double get maxExtent => extendedHeight;

  @override
  double get minExtent => collapsedHeight;

  @override
  bool shouldRebuild(covariant CustomDelegate oldDelegate) {
    return oldDelegate.collapsedHeight != collapsedHeight ||
        oldDelegate.extendedHeight != extendedHeight;
  }

  Widget _detailsCard(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: [
              Text('The Suicide Squad'),
              IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.favorite_outline,
                  color: Colors.pinkAccent[400],
                ),
              ),
            ],
          ),
          Wrap(
            spacing: 4.0,
            alignment: WrapAlignment.start,
            children: [
              Chip(
                label: Text('Action'),
                backgroundColor: Colors.pink,
                padding: EdgeInsets.zero,
                labelStyle: Theme.of(context).textTheme.subtitle2?.copyWith(
                      fontSize: 10.0,
                    ),
              ),
              Chip(
                label: Text('2.30 Hours'),
                backgroundColor: Colors.purple,
                padding: EdgeInsets.zero,
                labelStyle: Theme.of(context).textTheme.subtitle2?.copyWith(
                      fontSize: 10.0,
                    ),
              ),
              Chip(
                label: Text('7.8'),
                // avatar: Icon(Icons.star),
                backgroundColor: Colors.amber,
                padding: EdgeInsets.zero,
                labelStyle: Theme.of(context).textTheme.subtitle2?.copyWith(
                      fontSize: 10.0,
                    ),
              ),
            ],
          ),
        ],
      );
}
