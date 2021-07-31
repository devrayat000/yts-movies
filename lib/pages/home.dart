import 'package:flutter/material.dart';
import 'package:ytsmovies/widgets/appbars/search_delegate.dart';

import './search.dart';
import './latest.dart';
import '../widgets/appbars/home_appbar.dart';
import '../widgets/drawers/home_drawer.dart';
import '../widgets/cards/search_card.dart';

class HomePage extends StatelessWidget {
  static const routeName = '/';
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HomeAppbar(),
      drawer: const MainDrawer(),
      drawerEnableOpenDragGesture: false,
      body: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.all(4.0),
        children: [
          InkWell(
            onTap: () {
              Navigator.of(context).pushNamed(SearchPage.routeName);
              // showSearch(
              //   context: context,
              //   delegate: MovieSearchDelegate(),
              // );
            },
            child: const SearchTile(),
            splashFactory: NoSplash.splashFactory,
          ),
          Container(
            height: 300.0,
            padding: const EdgeInsets.all(8.0),
            child: const Wrapped(spacing: 8.0),
          ),
        ],
      ),
    );
  }
}

class Wrapped extends StatelessWidget {
  final double? spacing;
  const Wrapped({Key? key, this.spacing = 0.0}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Flex(
      direction: Axis.vertical,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 2,
          child: InkWell(
            child: Card(
              color: Colors.pinkAccent[400],
              elevation: 2.0,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('images/stars.png'),
                    fit: BoxFit.contain,
                    onError: (e, __) => ErrorWidget.builder =
                        (_) => Center(child: Text(_.toString())),
                    alignment: Alignment.topRight,
                  ),
                ),
                alignment: Alignment.bottomLeft,
                child: ListTile(
                  title: Text(
                    'Latest Movies',
                    style: Theme.of(context)
                        .textTheme
                        .headline5
                        ?.copyWith(color: Colors.white),
                  ),
                  subtitle: Text(
                    'New uploads every now & then!',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
            splashFactory: NoSplash.splashFactory,
            onTap: () {
              Navigator.pushNamed(context, LatestMoviesPage.routeName);
            },
          ),
        ),
        SizedBox(height: spacing),
        Expanded(
          flex: 2,
          child: Flex(
            direction: Axis.horizontal,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 1,
                child: Container(
                  height: double.infinity,
                  child: Card(
                    color: Colors.lightBlueAccent,
                    elevation: 2.0,
                  ),
                ),
              ),
              SizedBox(width: spacing),
              Expanded(
                flex: 1,
                child: InkWell(
                  child: Card(
                    color: Colors.pinkAccent[100],
                    elevation: 2.0,
                    child: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('images/4khd/hd4k.png'),
                          fit: BoxFit.contain,
                          onError: (e, __) => ErrorWidget.builder =
                              (_) => Center(child: Text(_.toString())),
                          alignment: Alignment.topRight,
                        ),
                      ),
                      alignment: Alignment.bottomLeft,
                      child: ListTile(
                        title: Text(
                          '4K Movies',
                          style: Theme.of(context)
                              .textTheme
                              .headline5
                              ?.copyWith(color: Colors.black),
                        ),
                        subtitle: Text(
                          'High quality!',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                  splashFactory: NoSplash.splashFactory,
                  onTap: () {
                    Navigator.pushNamed(context, HD4KMoviesPage.routeName);
                  },
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
