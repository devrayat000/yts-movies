library app_widgets;

import 'dart:async';
import 'dart:developer';

import 'package:chopper/chopper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'
    show CupertinoSlider, CupertinoSwitch, CupertinoScrollbar;
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:ytsmovies/src/widgets/buttons/index.dart';
import 'package:ytsmovies/src/widgets/cards/index.dart';
import 'package:ytsmovies/src/router/index.dart';
import '../bloc/filter/index.dart';
import '../bloc/api/index.dart';
import 'package:ytsmovies/src/models/index.dart';
import 'package:ytsmovies/src/utils/lists.dart' as list;
import '../utils/index.dart';

export 'package:ytsmovies/src/widgets/buttons/index.dart';
export 'package:ytsmovies/src/widgets/cards/index.dart';
export 'package:ytsmovies/src/widgets/search/search_delegate.dart';

part './unfocus.dart';
part './torrent_tab.dart';
part './shimmer.dart';
part './movie_suggestions.dart';
part './movie_list.dart';
part './image.dart';
part './future_builder.dart';
part './drawers/filter_drawer.dart';
part './appbars/home_appbar.dart';
