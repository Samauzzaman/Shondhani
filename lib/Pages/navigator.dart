import 'package:flutter/material.dart';

class Nav {
  // A static method means you don't have to create an instance of 'Nav' to use it
  static Future<void> fadeTo(BuildContext context, Widget destinationPage) async {
    await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => destinationPage,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }
}