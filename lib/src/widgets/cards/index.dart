library app_widgets.card;

import 'package:flutter/cupertino.dart' show CupertinoScrollbar;
import 'package:flutter/material.dart';

import 'package:ytsmovies/src/models/movie.dart';
import 'package:ytsmovies/src/utils/index.dart';
import 'package:ytsmovies/src/widgets/buttons/index.dart';
import 'package:ytsmovies/src/widgets/index.dart';
import 'package:provider/provider.dart';

import 'package:ytsmovies/src/bloc/theme_bloc.dart';
import 'package:ytsmovies/src/router/index.dart';

import '../../models/movie.dart';

part './actionbar.dart';
part './intro_item.dart';
part './movie_card.dart';
part './search_card.dart';
part './shimmer_movie_card.dart';
part './shimmer_shapes.dart';
