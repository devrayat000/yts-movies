library app_widgets.button;

import 'dart:developer';
import 'dart:math' hide log;
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:ytsmovies/src/api/favourites.dart';
import 'package:ytsmovies/src/services/error_notification_service.dart';

import 'package:ytsmovies/src/bloc/theme_bloc.dart';
import 'package:ytsmovies/src/utils/index.dart';
import '../../models/movie.dart';
import '../../models/torrent.dart' as m;

part './download_button.dart';
part './favourite_button.dart';
part './popup_fab.dart';
part './show_more_button.dart';
part './theme_button.dart';
