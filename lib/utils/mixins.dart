import 'package:flutter/material.dart';

import 'constants.dart';

mixin PageStorageCache<T extends StatefulWidget> on State<T> {
  T? getCache<T>({required Object key}) => context.bucket.readState(
        context,
        identifier: key,
      ) as T?;

  void setCache<T>({required Object key, required T? data}) =>
      context.bucket.writeState(
        context,
        data,
        identifier: key,
      );
}
