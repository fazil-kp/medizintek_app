import 'package:flutter/material.dart';
import 'package:medizintek_app/presentation/pages/medizintek.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Medizinitek',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const Medizintek(),
    );
  }
}
