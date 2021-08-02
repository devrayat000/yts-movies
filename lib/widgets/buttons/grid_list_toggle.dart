import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/view_provider.dart';

typedef OnToggle = void Function(bool state);

class GridListToggle extends StatefulWidget {
  final OnToggle? onToggle;
  final ScrollController? controller;
  const GridListToggle({Key? key, this.onToggle, this.controller})
      : super(key: key);

  @override
  _GridListToggleState createState() => _GridListToggleState();
}

class _GridListToggleState extends State<GridListToggle>
    with SingleTickerProviderStateMixin<GridListToggle> {
  late final Animation<double> _animation;
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    )..value = context.read<GridListView>().isTrue ? 0 : 1;
    _animation =
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    super.dispose();
    _animationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GridListView>(
      child: AnimatedIcon(
        icon: AnimatedIcons.list_view,
        progress: _animation,
        semanticLabel: 'Grid/List Toggle',
      ),
      builder: (context, view, icon) => IconButton(
        icon: icon!,
        onPressed: () {
          final _offset = widget.controller?.offset;
          final _dur = const Duration(milliseconds: 400);
          final _curve = Curves.linear;
          if (_animationController.status == AnimationStatus.dismissed) {
            _animationController.forward();
            widget.controller?.animateTo(
              _offset! * 1.8,
              duration: _dur,
              curve: _curve,
            );
          } else if (_animationController.status == AnimationStatus.completed) {
            _animationController.reverse();
            widget.controller?.animateTo(
              _offset! / 1.8,
              duration: _dur,
              curve: _curve,
            );
          }
          context.read<GridListView>().toggle();
          final a = widget.onToggle;
          if (a != null) {
            a(!context.read<GridListView>().isTrue);
          }
        },
      ),
    );
  }
}
