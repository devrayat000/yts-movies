part of app_widgets;

class MyFutureBuilder<T> extends StatelessWidget {
  final Future<T>? future;
  final T? initialData;
  final Widget Function(BuildContext, Object?) errorBuilder;
  final Widget Function(BuildContext, T?) successBuilder;
  final WidgetBuilder? loadingBuilder;
  final WidgetBuilder? idleBuilder;

  const MyFutureBuilder({
    Key? key,
    this.future,
    this.initialData,
    this.loadingBuilder,
    this.idleBuilder,
    required this.errorBuilder,
    required this.successBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      initialData: initialData,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return idleBuilder?.call(context) ??
                _defaultLoadingBuilder(context);
          case ConnectionState.waiting:
          case ConnectionState.active:
            return loadingBuilder?.call(context) ??
                _defaultLoadingBuilder(context);
          case ConnectionState.done:
            if (snapshot.hasError) {
              return errorBuilder(context, snapshot.error);
            } else if (snapshot.hasData) {
              return successBuilder(context, snapshot.data);
            } else {
              return loadingBuilder?.call(context) ??
                  _defaultLoadingBuilder(context);
            }
          default:
            return loadingBuilder?.call(context) ??
                _defaultLoadingBuilder(context);
        }
      },
    );
  }

  Widget _defaultLoadingBuilder(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}
