import 'package:flutter/material.dart';
import '../layout/custom_header.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: CustomHeader(),
      body: Center(
        child: Text('About Us Page', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
