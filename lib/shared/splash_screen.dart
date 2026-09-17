import 'package:flutter/material.dart';
import 'package:ogi_ppkd_app_dev/shared/login_screen.dart';
import 'package:ogi_ppkd_app_dev/shared/preferencens_handler.dart';
import 'package:ogi_ppkd_app_dev/navigator/navigator.dart';

class SplashScreenDay15 extends StatefulWidget {
  const SplashScreenDay15({super.key});

  @override
  State<SplashScreenDay15> createState() => _SplashScreenDay15State();
}

class _SplashScreenDay15State extends State<SplashScreenDay15> {
  @override
  void initState() {
    super.initState();
    goToLogin();
  }

  void goToLogin() async {
    await Future.delayed(Duration(seconds: 3));

    if (PreferenceHandler.isLogin == true) {
      context.pushAndRemoveAll(HalamanTerimaKasih(email: "email"));
    } else {
      context.pushAndRemoveAll(LoginScreenDay15());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Center(child: Image.asset("assets/image/a.jpg")),
      ),
    );
  }
}
