import 'package:flutter/material.dart';
import 'package:carbon_emission_app/presentation/login_screen.dart';
import 'package:carbon_emission_app/presentation/hallway_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HallwayScreen()),
      );
    });

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/DALE3.jpg'),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
