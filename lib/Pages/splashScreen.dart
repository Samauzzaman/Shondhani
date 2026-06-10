import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:blood_donation/Pages/userORadmin.dart';
import 'package:blood_donation/Pages/demo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 3800), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const Useroradmin()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          CupertinoColors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 🩸 THE EVOLVING LOGO
            Expanded(
              child:
                  Image.asset(
                        'assets/images/logo.png',
                      )
                      .animate()
                      .fade(
                        duration: 2500.ms,
                        curve: Curves.easeInCubic,
                      ) // 1. Slowly materializes opacity
                      .scaleXY(
                        begin: 0.2,
                        end: 1.5,
                        duration: 2800.ms,
                        curve: Curves.fastOutSlowIn,
                      ) // 2. Expands out of a single pixel
                      .blurXY(
                        begin: 25,
                        end: 0,
                        duration: 2200.ms,
                        curve: Curves.easeOut,
                      ),
            ),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }
}
