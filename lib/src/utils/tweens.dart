import 'package:flutter/animation.dart';
import 'package:flutter/rendering.dart';

class MyTween {
  static final slideLeft = Tween<Offset>(
    begin: Offset(1, 0),
    end: Offset.zero,
  );

  static final slideUp = Tween<Offset>(
    begin: Offset(0, 1),
    end: Offset.zero,
  );

  static final slideRight = Tween<Offset>(
    begin: Offset(-1, 0),
    end: Offset.zero,
  );

  static final slideDown = Tween<Offset>(
    begin: Offset(0, -1),
    end: Offset.zero,
  );
}
