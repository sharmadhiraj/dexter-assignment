import 'package:dexter_assignment/screens/home.dart';
import 'package:dexter_assignment/util/constants.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DexterAssignmentApp());
}

class DexterAssignmentApp extends StatelessWidget {
  const DexterAssignmentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Constant.appName,
      theme: _buildThemeData(context),
      home: const HomeScreen(),
    );
  }

  ThemeData _buildThemeData(BuildContext context) {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Constant.primaryColor),
      primaryColor: Constant.primaryColor,
      useMaterial3: true,
    );
  }
}
