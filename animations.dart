import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class CustomAnimations {
  // Fade transition
  static PageTransition fadeTransition(Widget page) {
    return PageTransition(
      type: PageTransitionType.fade,
      child: page,
      duration: const Duration(milliseconds: 300),
    );
  }

  // Slide from right
  static PageTransition slideRight(Widget page) {
    return PageTransition(
      type: PageTransitionType.rightToLeft,
      child: page,
      duration: const Duration(milliseconds: 350),
    );
  }

  // Scale transition
  static PageTransition scaleTransition(Widget page) {
    return PageTransition(
      type: PageTransitionType.scale,
      alignment: Alignment.center,
      child: page,
      duration: const Duration(milliseconds: 400),
    );
  }

  // Rotate transition
  static PageTransition rotateTransition(Widget page) {
    return PageTransition(
      type: PageTransitionType.rotate,
      child: page,
      duration: const Duration(milliseconds: 500),
    );
  }
}