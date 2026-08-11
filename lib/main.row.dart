import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text("exemplo Row")),
        body: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.home, size: 50),

              SizedBox(width: 20), // Espaçamento entre os ícones

              Icon(Icons.favorite, size: 40),

              SizedBox(width: 20), // Espaçamento entre os ícones

              Icon(Icons.settings, size: 40),
            ],
          ),
        ), // Center
      ), // Scaffold
    ); // MaterialApp
  }
}
