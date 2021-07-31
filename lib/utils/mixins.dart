import 'package:flutter/material.dart';

import 'package:ytsmovies/models/constants.dart';

mixin PageStorageCache<T extends StatefulWidget> on State<T> {
  T? getCache<T>({required Object key}) => kPageStorageBucket.readState(
        context,
        identifier: key,
      ) as T?;

  void setCache<T>({required Object key, required T? data}) =>
      kPageStorageBucket.writeState(
        context,
        data,
        identifier: key,
      );
}
