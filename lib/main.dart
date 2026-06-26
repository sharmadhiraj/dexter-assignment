import 'package:dexter_assignment/config/app_theme.dart';
import 'package:dexter_assignment/config/constants.dart';
import 'package:dexter_assignment/features/home/bloc/home.dart';
import 'package:dexter_assignment/features/home/presentation/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  _startNativeService();
  runApp(const DexterApp());
}

void _startNativeService() {
  const channel = MethodChannel(AppConfig.nativeChannelName);
  Future.delayed(
    const Duration(milliseconds: 1500),
    () => channel.invokeMethod("startService"),
  );
}

class DexterApp extends StatelessWidget {
  const DexterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TranscriptionCubit()..init(),
      child: MaterialApp(
        title: AppConfig.appName,
        theme: buildAppTheme(),
        home: const HomeScreen(),
      ),
    );
  }
}
