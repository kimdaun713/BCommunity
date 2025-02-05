import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';

class FadeAnimation extends StatelessWidget {
  final double delay;
  final Widget child;

  FadeAnimation(this.delay, this.child);

  @override
  Widget build(BuildContext context) {
    final tween = MovieTween()
      ..tween("opacity", Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 500))
      ..tween("translateY", Tween(begin: -30.0, end: 0.0),
          duration: Duration(milliseconds: 500), curve: Curves.easeOut);

    return PlayAnimationBuilder<Movie>(
      delay: Duration(milliseconds: (500 * delay).round()),
      tween: tween, // 애니메이션 트랙 설정
      duration: tween.duration,
      child: child, //
      builder: (context, value, child) => Opacity(
        opacity: value.get("opacity"),
        child: Transform.translate(
          offset: Offset(0, value.get("translateY")),
          child: child,
        ),
      ),
    );
  }
}
