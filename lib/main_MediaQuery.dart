import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'MediaQuery', home: const homescreen());
  }
}

class homescreen extends StatelessWidget {
  const homescreen({super.key});

  @override
  Widget build(BuildContext context) {
    double largura = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(title: Text("MediaQuery")),
      body: Center(
        child: Container(
          height: 100,
          width: largura * 0.8,
          color: Colors.green,
          child: const Center(
            child: Text(
              "Container com largura de 80% da tela",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
