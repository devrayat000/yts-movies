library;

import 'dart:developer';
import 'dart:math' hide log;
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ytsmovies/src/injection.dart';
import 'package:ytsmovies/src/services/foreground_download_service.dart';
import 'package:ytsmovies/src/services/preferences_service.dart';
import 'package:ytsmovies/src/service_extensions.dart';
import 'package:ytsmovies/src/bloc/download_manager/index.dart';
import 'package:ytsmovies/src/models/download_task.dart';
import 'package:ytsmovies/src/pages/download_settings.dart';

import 'package:ytsmovies/src/bloc/theme_bloc.dart';
import 'package:ytsmovies/src/utils/index.dart';
import 'package:ytsmovies/src/utils/storage_permission.dart';
import 'package:ytsmovies/src/utils/urls.dart';
import '../../models/movie.dart';
import '../../models/torrent.dart' as m;

part './download_button.dart';
part './favourite_button.dart';
part './popup_fab.dart';
part './show_more_button.dart';
part './theme_button.dart';
