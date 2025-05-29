library app_widgets;

import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ytsmovies/src/api/movies.dart';

import 'package:ytsmovies/src/widgets/buttons/index.dart';
import 'package:ytsmovies/src/widgets/cards/index.dart';
import 'package:ytsmovies/src/widgets/error_widgets.dart';
import 'package:ytsmovies/src/widgets/connectivity_widgets.dart';
import 'package:ytsmovies/src/services/connectivity_service.dart';
import 'package:ytsmovies/src/bloc/filter/index.dart';
import 'package:ytsmovies/src/models/index.dart';
import 'package:ytsmovies/src/utils/lists.dart' as list;
import 'package:ytsmovies/src/widgets/movies_list.dart';

export 'package:ytsmovies/src/widgets/buttons/index.dart';
export 'package:ytsmovies/src/widgets/cards/index.dart';
export 'package:ytsmovies/src/widgets/error_widgets.dart';
export 'package:ytsmovies/src/widgets/connectivity_widgets.dart';
export 'package:ytsmovies/src/widgets/search/search_delegate.dart';
export 'package:ytsmovies/src/widgets/splash/dynamic_splash_screen.dart';
export 'package:ytsmovies/src/widgets/splash/splash_wrapper.dart';
export 'package:ytsmovies/src/widgets/splash/splash_wrapper.dart';

part './unfocus.dart';
part './torrent_tab.dart';
part './shimmer.dart';
part './movie_suggestions.dart';
part './image.dart';
part './enhanced_future_builder.dart';
part './drawers/filter_drawer.dart';
part './appbars/home_appbar.dart';
part './movies_paged_view.dart';
