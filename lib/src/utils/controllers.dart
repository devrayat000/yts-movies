import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class PageStorageProvider<T extends PageStorageBucket>
    extends InheritedProvider<T> {
  PageStorageProvider({
    Key? key,
    required Create<T> create,
    Dispose<T>? dispose,
    bool? lazy,
    TransitionBuilder? builder,
    Widget? child,
  }) : super(
          key: key,
          lazy: lazy,
          builder: child != null
              ? (context, _) => PageStorage(
                    bucket:
                        Provider.of<PageStorageBucket>(context, listen: false),
                    child: builder?.call(context, _) ?? child,
                  )
              : null,
          create: create,
          dispose: dispose,
          debugCheckInvalidValueType: kReleaseMode
              ? null
              : (T value) =>
                  Provider.debugCheckInvalidValueType?.call<T>(value),
          child: child,
        );

  PageStorageProvider.value({
    Key? key,
    required T value,
    UpdateShouldNotify<T>? updateShouldNotify,
    TransitionBuilder? builder,
    Widget? child,
  })  : assert(() {
          Provider.debugCheckInvalidValueType?.call<T>(value);
          return true;
        }()),
        super.value(
          key: key,
          builder: (context, childX) => PageStorage(
            bucket: value,
            child: builder?.call(context, childX) ?? child!,
          ),
          value: value,
          updateShouldNotify: updateShouldNotify,
          child: child,
        );
}
