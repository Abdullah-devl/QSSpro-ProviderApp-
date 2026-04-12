import 'package:flutter/material.dart';

class ComplaintsView extends StatelessWidget {
  const ComplaintsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الشكاوي'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text('صفحة الشكاوي قريباً'),
      ),
    );
  }
}
