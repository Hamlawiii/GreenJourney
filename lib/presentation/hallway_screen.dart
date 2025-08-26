import 'package:carbon_emission_app/presentation/general_information_screen.dart';
import 'package:carbon_emission_app/presentation/login_screen.dart';
import 'package:carbon_emission_app/presentation/registration_screen.dart';
import 'package:carbon_emission_app/presentation/carbon_emissions_calculator_screen.dart';
import 'package:flutter/material.dart';

class HallwayScreen extends StatelessWidget {
  const HallwayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Green Journey'),
        backgroundColor: Colors.green[700],
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF8F8F8), // New shade of white (light grey)
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Image.asset(
                  'assets/images/Logo2.jpeg',
                  height: 150,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Welcome to GreenJourney!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1, // Ensures squares
                    children: <Widget>[
                      _buildGridButton(
                        context,
                        icon: Icons.login,
                        label: 'Login',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                          );
                        },
                      ),
                      _buildGridButton(
                        context,
                        icon: Icons.person_add,
                        label: 'Register',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const RegistrationScreen()),
                          );
                        },
                      ),
                      _buildGridButton(
                        context,
                        icon: Icons.info,
                        label: 'General Info',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const GeneralInformationScreen()),
                          );
                        },
                      ),
                      _buildGridButton(
                        context,
                        icon: Icons.calculate,
                        label: 'Emission Calculator',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const CarbonEmissionsCalculator()),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGridButton(BuildContext context, {required IconData icon, required String label, required VoidCallback onPressed}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green[600],
        padding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: Colors.white, width: 2),
        ),
        elevation: 5,
      ),
      onPressed: onPressed,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 40),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
