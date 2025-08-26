import 'package:flutter/material.dart';

class EmissionsHistoryScreen extends StatelessWidget {
  const EmissionsHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emissions History'),
      ),
      body: const Center(
        child: Text('Display emissions history here'),
      ),
    );
  }
}
