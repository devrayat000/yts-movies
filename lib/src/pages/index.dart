library app_pages;

import 'dart:async';
import 'dart:developer';

import 'package:flutter/cupertino.dart' show CupertinoNavigationBarBackButton;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ytsmovies/src/theme/index.dart';
import 'package:flutter_breadcrumb/flutter_breadcrumb.dart'
    show BreadCrumb, BreadCrumbItem;
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import 'package:ytsmovies/src/utils/index.dart';
import 'package:ytsmovies/src/widgets/index.dart';
import '../models/index.dart';

part 'favourites.dart';
part 'movie.dart';
part 'test.dart';
