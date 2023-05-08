import 'package:flutter/animation.dart';

class MyTween {
  static final slideLeft = Tween<Offset>(
    begin: const Offset(1, 0),
    end: Offset.zero,
  );

  static final slideUp = Tween<Offset>(
    begin: const Offset(0, 1),
    end: Offset.zero,
  );

  static final slideRight = Tween<Offset>(
    begin: const Offset(-1, 0),
    end: Offset.zero,
  );

  static final slideDown = Tween<Offset>(
    begin: const Offset(0, -1),
    end: Offset.zero,
  );
}
