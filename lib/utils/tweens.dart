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

  static final zeroOne = Tween<double>(
    begin: 0,
    end: 1,
  );

  static final wiggleShrink = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 1, end: 0.3), weight: 50),
    TweenSequenceItem(tween: Tween(begin: 0.3, end: 1), weight: 50),
  ]);

  static final wiggleEnlarge = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 1, end: 2), weight: 50),
    TweenSequenceItem(tween: Tween(begin: 2, end: 1), weight: 50),
  ]);
}
