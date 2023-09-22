import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:panelmeditasyon/wrapper.dart';
import 'firebase_options.dart';
import 'package:page_transition/page_transition.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        inputDecorationTheme: const InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.all(Radius.circular(16.0)))),
        appBarTheme: const AppBarTheme(
          color: Color(0xFF2B2B40),
        ),
        scaffoldBackgroundColor: Color.fromARGB(255, 255, 255, 255),

        primaryColor:
            Color.fromARGB(255, 255, 255, 255), // butonlar için ana renk
        // butonlar için ikincil renk
      ),
      home: Align(
          alignment: Alignment.center,
          child: AnimatedSplashScreen(
              duration: 0,
              splashIconSize: 1000,
              centered: true,
              /*   customTween: Tween(begin: 0.0, end: 1.0), */
              splash: Stack(
                children: [
                  Align(
                      alignment: Alignment.center,
                      child: Image.asset(
                        './assets/logo.png',
                      ))
                ],
              ),
              nextScreen: wrapper(),
              splashTransition: SplashTransition.fadeTransition,
              pageTransitionType: PageTransitionType.fade,
              backgroundColor: Colors.black)),
    );
  }
}
