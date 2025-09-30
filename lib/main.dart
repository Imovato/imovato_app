import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: Scaffold(
          backgroundColor: Color(0xFFD10B58),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: Text(
                      'Imovato :)',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ));
  }
}
