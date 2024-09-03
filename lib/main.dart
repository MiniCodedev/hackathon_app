import 'package:flutter/material.dart';
import 'package:hackathon_app/pages/responsive_layout.dart';
import 'constant.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ResponsiveLayout(),
      theme: ThemeData(
        fontFamily: "Poppins",
        colorSchemeSeed: primaryColor,
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
    );
  }
}
