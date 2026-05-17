import 'package:flutter/material.dart';
import '../layout/custom_header.dart';

class BookPage extends StatelessWidget {
  const BookPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: CustomHeader(),
      body: Center(
        child: Text('Book With Us Page', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
