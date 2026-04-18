import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EPFL Lend&&Borrow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE50914), // EPFL red-ish seed color
          primary: const Color(0xFFDA291C),
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
