import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TelaControler(),
    );
  }
}

class TelaControler extends StatefulWidget {
  const TelaControler({super.key});

  @override
  _TelaControlerState createState() => _TelaControlerState();
}

class _TelaControlerState extends State<TelaControler> {

  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Exemplo: TextEditingController")),
      body: Column(
          children: [

            TextField(
              controller: controller,
            ),
            ElevatedButton(
              onPressed: () {
                print("TextField: ${controller.text}");
              },
              child: Text("Mostrar"),
            ),
          ],  
      ),
    );  
  } 
}