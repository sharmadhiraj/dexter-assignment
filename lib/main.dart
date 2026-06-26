import 'package:dexter_assignment/config/constants.dart';
import 'package:dexter_assignment/features/home/bloc/home.dart';
import 'package:dexter_assignment/features/home/presentation/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  _initMethodChannel();
  runApp(const DexterAssignmentApp());
}

void _initMethodChannel() {
  Future.delayed(
    const Duration(milliseconds: 1000),
    () {
      const MethodChannel methodChannel = MethodChannel(Constant.channelName);
      Future.delayed(
        const Duration(milliseconds: 500),
        () => methodChannel.invokeMethod("startService"),
      );
    },
  );
}

class DexterAssignmentApp extends StatelessWidget {
  const DexterAssignmentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => HomeCubit()..init()),
      ],
      child: MaterialApp(
        title: Constant.appName,
        theme: _buildThemeData(context),
        home: const HomeScreen(),
      ),
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
