import 'package:flutter/material.dart';
import '../layout/custom_header.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: CustomHeader(),
      body: Center(child: Text('Main Page', style: TextStyle(fontSize: 24))),
    );
  }
}
