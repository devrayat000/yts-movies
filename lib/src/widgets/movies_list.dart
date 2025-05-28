import 'package:flutter/material.dart';
import 'package:ytsmovies/src/models/index.dart';
import 'package:ytsmovies/src/widgets/index.dart';

typedef ApiHandler<T> = Future<T> Function(int page);

class MoviesList extends StatefulWidget {
  final ApiHandler<MovieListResponse> handler;
  final PreferredSizeWidget? appBar;
  final String label;
  final Widget? endDrawer;
  final WidgetBuilder? noItemBuilder;

  const MoviesList({
    super.key,
    required this.handler,
    this.appBar,
    this.label = '',
    this.endDrawer,
    this.noItemBuilder,
  });

  @override
  MoviesListState createState() => MoviesListState();
}

class MoviesListState extends State<MoviesList> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController(debugLabel: 'scroll-popup');
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.appBar,
      endDrawer: widget.endDrawer,
      body: MoviesPagedView(
        handler: widget.handler,
        label: widget.label,
        scrollController: _scrollController,
        noItemBuilder: widget.noItemBuilder,
      ),
      floatingActionButton: PopupFloatingActionButton(
        scrollController: _scrollController,
      ),
    );
  }
}
