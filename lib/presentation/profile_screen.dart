import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';

import '../constant/app_color.dart';
import '../constant/app_textstyle.dart';
import '../data/bloc/carbon_emissions_bloc/carbon_emissions_bloc.dart';
import '../data/database/emissions_database_helper.dart';
import '../presentation/general_information_screen.dart';
import '../presentation/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final DateTime? selectedDate;

  const ProfileScreen({Key? key, required this.selectedDate}) : super(key: key);

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  late Future<List<double>> emissionsHistory;
  DateTime? selectedDateFromBloc;
  String selectedCountry = '';

  Future<void> _loadSelectedCountry() async {
    const secureStorage = FlutterSecureStorage();
    String? storedCountry = await secureStorage.read(key: 'selectedCountry');
    setState(() {
      selectedCountry = storedCountry ?? '';
    });
  }

  Future<Map<String, String>> _loadCountryRegulations(String countryName) async {
    try {
      String jsonString = await rootBundle.loadString('assets/countries_regulations.json');
      Map<String, dynamic> jsonMap = json.decode(jsonString);

      List<dynamic> countriesData = jsonMap['countries'];

      Map<String, String> countryRegulations = {};
      for (var countryData in countriesData) {
        if (countryData['name'] == countryName) {
          countryRegulations['emissionsRegulations'] = countryData['emissions_regulations'];
          break;
        }
      }

      return countryRegulations;
    } catch (e) {
      print('Error loading country regulations: $e');
      return {};
    }
  }

  Future<double> _loadCountryTotalEmissions(String countryName) async {
    try {
      String jsonString = await rootBundle.loadString('assets/countries_emissions.json');
      Map<String, dynamic> jsonData = json.decode(jsonString);

      List<dynamic> countriesData = jsonData['results']['bindings'];

      double totalEmissions = 0.0;
      for (var countryData in countriesData) {
        String country = countryData['country']['value'];
        if (country.toLowerCase() == countryName.toLowerCase()) {
          String emissionsString = countryData['co2kt']['value'];
          totalEmissions = double.tryParse(emissionsString) ?? 0.0;
          break;
        }
      }

      return totalEmissions;
    } catch (e) {
      print('Error loading country total emissions: $e');
      return 0.0;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadSelectedCountry().then((_) {
      setState(() {
        emissionsHistory = _displayEmissionsHistory();
        selectedDateFromBloc = context.read<CarbonEmissionsBloc>().selectedDate;
      });
    });
  }

  Future<List<double>> _displayEmissionsHistory() async {
    EmissionsDatabaseHelper emissionsDatabase = await EmissionsDatabaseHelper.getInstance();
    List<Map<String, dynamic>> history = await emissionsDatabase.getEmissionsHistory();
    return history.map((e) => e['emissions_value'] as double).toList();
  }

  Future<void> _logout() async {
    final secureStorage = FlutterSecureStorage();
    await secureStorage.deleteAll();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()), // Replace with your login screen
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Your Profile',
          style: AppTextStyles.heading(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_present, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const GeneralInformationScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSectionContainer(height, 'Emissions History', _buildEmissionsHistoryList()),
              SizedBox(height: height / 40),
              _buildSectionContainer(height, 'General Emissions for Your Country', _buildGeneralEmissions()),
              SizedBox(height: height / 40),
              _buildSectionContainer(height, 'Total Emissions of Your Country', _buildCountryTotalEmissions()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionContainer(double height, String title, Widget content) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.green[50] ?? const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: AppTextStyles.heading(color: Colors.green[800] ?? const Color(0xFF2E7D32)),
          ),
          SizedBox(height: height / 30),
          content,
        ],
      ),
    );
  }

  Widget _buildEmissionsHistoryList() {
    return FutureBuilder<List<double>>(
      future: emissionsHistory,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text('No emissions history available.', style: TextStyle(color: Color(0xFF2E7D32)));
        } else {
          List<double> emissionsHistory = snapshot.data!;
          return ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(), // Disable scrolling
            itemCount: emissionsHistory.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(
                  '${index + 1}. ${emissionsHistory[index]} kg CO2',
                  style: AppTextStyles.subtitle(color: Colors.green[800] ?? const Color(0xFF2E7D32)),
                ),
              );
            },
          );
        }
      },
    );
  }

  Widget _buildGeneralEmissions() {
    return FutureBuilder<Map<String, String>>(
      future: _loadCountryRegulations(selectedCountry),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}', style: const TextStyle(color: Color(0xFF2E7D32)));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Text(
            'Regulations for $selectedCountry:\nHistorically, this country did not have modern carbon emissions regulations. Please note that this entry refers to a historical entity.',
            style: const TextStyle(color: Color(0xFF2E7D32)),
          );
        } else {
          String emissionsRegulations = snapshot.data!['emissionsRegulations'] ?? 'No specific regulations.';
          return Text(
            'Regulations for $selectedCountry:\n$emissionsRegulations',
            style: const TextStyle(color: Color(0xFF2E7D32)),
          );
        }
      },
    );
  }

  Widget _buildCountryTotalEmissions() {
    return FutureBuilder<double>(
      future: _loadCountryTotalEmissions(selectedCountry),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}', style: const TextStyle(color: Color(0xFF2E7D32)));
        } else if (!snapshot.hasData) {
          return const Text('No data available for country total emissions.', style: TextStyle(color: Color(0xFF2E7D32)));
        } else {
          double totalEmissions = snapshot.data!;
          return Text(
            'Total Emissions for $selectedCountry: $totalEmissions kg CO2',
            style: const TextStyle(color: Color(0xFF2E7D32)),
          );
        }
      },
    );
  }

  Widget _buildSelectedDate() {
    return Text(
      selectedDateFromBloc != null
          ? ' ${DateFormat('yyyy-MM-dd').format(selectedDateFromBloc!)}'
          : 'No date selected',
      style: AppTextStyles.subtitle(color: Colors.green[800] ?? const Color(0xFF2E7D32)),
    );
  }
}
