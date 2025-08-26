import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:carbon_emission_app/constant/app_color.dart';
import 'package:carbon_emission_app/constant/app_textstyle.dart';
import '../data/bloc/login_bloc/login_bloc.dart';
import '../data/bloc/login_bloc/login_event.dart';
import '../data/bloc/login_bloc/login_state.dart';
import 'carbon_emissions_calculator_screen.dart';
import 'registration_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late LoginBloc _loginBloc;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loginBloc = context.read<LoginBloc>();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primaryDark, AppColors.primary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'User Login',
          style: AppTextStyles.heading(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: BlocListener<LoginBloc, LoginState>(
            listener: (context, state) {
              if (state is LoginSuccessState) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Login successful!"),
                    duration: Duration(seconds: 3),
                  ),
                );
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const CarbonEmissionsCalculator(),
                  ),
                );
              } else if (state is LoginErrorState) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.errorMessage),
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  alignment: Alignment.center,
                  height: height / 3,
                  child: const Image(image: AssetImage('assets/images/green.png')),
                ),
                SizedBox(height: height / 30),
                _buildTextField("Email", emailController, Icons.email),
                _buildTextField("Password", passwordController, Icons.lock, isPassword: true),
                SizedBox(height: height / 30),
                ElevatedButton(
                  onPressed: () {
                    _loginBloc.add(
                      LoginUserEvent(
                        email: emailController.text,
                        password: passwordController.text,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(width * 2 / 3, height * 1 / 12),
                    foregroundColor: Colors.white,
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                  ),
                  child: Text(
                    'Login',
                    style: AppTextStyles.subtitle(color: Colors.white),
                  ),
                ),
                SizedBox(height: height / 30),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const RegistrationScreen()),
                    );
                  },
                  child: Text(
                    'Not registered? Register here',
                    style: AppTextStyles.bodyMedium(color: AppColors.primaryDark),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.blueAccent.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: controller,
          obscureText: isPassword,
          style: AppTextStyles.bodyLarge(color: Colors.white),
          decoration: InputDecoration(
            hintText: label,
            hintStyle: AppTextStyles.bodyLarge(color: Colors.white70),
            prefixIcon: Icon(icon, color: Colors.white70),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: Colors.transparent),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: Colors.transparent),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15),
            filled: true,
            fillColor: Colors.black87,
          ),
        ),
      ),
    );
  }
}
