import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:ytsmovies/src/api/movies.dart';
import 'package:ytsmovies/src/app.dart';
import 'package:ytsmovies/src/bloc/theme_bloc.dart';
import 'package:ytsmovies/src/theme/index.dart';

/// Main app widget that handles initialization and provides dependencies
class YTSAppInitializer extends StatelessWidget {
  const YTSAppInitializer({super.key});
  @override
  Widget build(BuildContext context) {
    // Always provide the theme cubit since storage is now initialized
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(
          create: (_) => ThemeCubit(theme: AppTheme()),
        ),
        BlocProvider(
          create: (_) => MoviesClientCubit(),
        )
      ],
      child: const YTSApp(),
    );
  }
}
