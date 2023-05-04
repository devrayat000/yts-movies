library app_pages;

import 'dart:async';
import 'dart:developer';
import 'dart:ui';

import 'package:flutter/cupertino.dart' show CupertinoNavigationBarBackButton;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ytsmovies/src/theme/index.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:flutter_breadcrumb/flutter_breadcrumb.dart'
    show BreadCrumb, BreadCrumbItem;
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import 'package:ytsmovies/src/utils/index.dart';
import 'package:ytsmovies/src/router/index.dart';
import 'package:ytsmovies/src/bloc/api/index.dart';
import 'package:ytsmovies/src/widgets/index.dart';
import '../models/index.dart';
import '../widgets/search/search_delegate.dart';

part 'home-2.dart';
part 'favourites.dart';
part 'latest.dart';
part 'movie.dart';
part 'test.dart';

class Routes {
  static PageRoute<T> _slideLeft<T>(
    BuildContext context, {
    required Widget child,
    String? name,
  }) {
    final _modal = ModalRoute.of(context)!;
    return MaterialPageRoute<T>(
      builder: (context) => SlideTransition(
        position: _modal.secondaryAnimation!.drive(MyTween.slideLeft),
        child: child,
      ),
      settings: _modal.settings.copyWith(name: name),
    );
  }

  static PageRoute<T> latest<T>(BuildContext context) => _slideLeft(
        context,
        child: const LatestMoviesPage(),
        name: '/latest',
      );

  static PageRoute<T> hd<T>(BuildContext context) => _slideLeft(
        context,
        child: HD4KMoviesPage(),
        name: '/hd',
      );

  static PageRoute<T> rated<T>(BuildContext context) => _slideLeft(
        context,
        child: RatedMoviesPage(),
        name: '/rated',
      );

  static PageRoute<T> home<T>(BuildContext context) {
    final _modal = ModalRoute.of(context);
    return MaterialPageRoute<T>(
      builder: (context) => const HomePage2(),
      settings: _modal?.settings.copyWith(name: '/'),
    );
  }

  static PageRoute<T> favourites<T>(BuildContext context) {
    final _modal = ModalRoute.of(context)!;
    return MaterialPageRoute<T>(
      builder: (context) => ScaleTransition(
        scale: _modal.secondaryAnimation!,
        alignment: Alignment.topRight,
        child: const FavouratesPage(),
      ),
      settings: _modal.settings.copyWith(name: '/favourites'),
    );
  }

  static PageRoute<T> search<T>(BuildContext context) {
    final _modal = ModalRoute.of(context)!;
    return MaterialPageRoute<T>(
      builder: (context) => SlideTransition(
        position: _modal.secondaryAnimation!.drive(MyTween.slideUp),
        child: const FavouratesPage(),
      ),
      settings: _modal.settings.copyWith(name: '/search'),
    );
  }

  static PageRoute<T> details<T>(BuildContext context,
      {required MovieArg argument}) {
    final _modal = ModalRoute.of(context)!;
    return MaterialPageRoute<T>(
      builder: (context) => MoviePage(item: argument.movie),
      settings: _modal.settings.copyWith(name: '/details/${argument.movie.id}'),
    );
  }
}
