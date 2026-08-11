import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Exemplo do Expanded',
      home: Scaffold(
        appBar: AppBar(title: Text("Expanded")),
        body: Column(
          children: [
            Container(
              height: 100,
              width: 100,
              color: Colors.pinkAccent,
              child: const Center(child: Text("Header")),
            ),
            Expanded(
              child: Container(
                color: Colors.deepPurple,
                child: const Center(
                  child: Text(
                    "Ocupa todo espaço restante",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

