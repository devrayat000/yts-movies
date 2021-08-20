import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ytsmovies/mock/movie.dart';
import 'package:ytsmovies/utils/constants.dart';
import 'package:ytsmovies/utils/exceptions.dart';
import 'package:ytsmovies/widgets/buttons/show_more_button.dart';

class IntroItem extends StatelessWidget {
  final void Function()? onAction;
  final Widget Function(BuildContext, Movie, int) itemBuilder;
  final Widget title;
  final TextStyle? titleTextStyle;
  final Future<List<Movie>> future;

  const IntroItem({
    Key? key,
    required this.onAction,
    required this.itemBuilder,
    required this.title,
    required this.future,
    this.titleTextStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onAction,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DefaultTextStyle(
                  style: TextStyle(fontSize: 24).merge(titleTextStyle),
                  child: title,
                ),
                Icon(Icons.arrow_forward_ios),
              ],
            ),
          ),
        ),
        SizedBox(
          height: 200,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: ItemBuilder(
              builder: itemBuilder,
              future: future,
              onAction: onAction,
            ),
          ),
        ),
      ],
    );
  }
}

class ItemBuilder extends StatelessWidget {
  final void Function()? onAction;
  final Future<List<Movie>> future;
  final Widget Function(BuildContext, Movie, int) builder;
  ItemBuilder({
    Key? key,
    required this.onAction,
    required this.future,
    required this.builder,
  }) : super(key: key);

  final _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Movie>>(
      future: future,
      // initialData: [],
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print(snapshot.error);
          print(snapshot.error.runtimeType);
        }
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return Center(child: Text('😓'));
          case ConnectionState.waiting:
          case ConnectionState.active:
            return MyGlobals.kCircularLoading;
          case ConnectionState.done:
            if (snapshot.hasError) {
              final error = snapshot.error!;
              if (error is CustomException) {
                return Center(
                  child: Text(error.message),
                );
              }
              return Center(
                child: Text(error.toString()),
              );
            }
            if (snapshot.hasData) {
              return CupertinoScrollbar(
                controller: _scrollController,
                child: CustomScrollView(
                  controller: _scrollController,
                  key: key,
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, i) {
                            return builder(context, snapshot.data![i], i);
                          },
                          childCount: snapshot.data!.length,
                        ),
                      ),
                    ),
                    _moreIcon,
                  ],
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                ),
              );
            }
            return Center(child: Text('😁'));
          default:
            return MyGlobals.kCircularLoading;
        }
      },
    );
  }

  Widget get _moreIcon => SliverToBoxAdapter(
        child: ShowMoreButton(onPressed: onAction),
      );
}
