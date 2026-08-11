import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext contetxt) {
    return MaterialApp(home: ContadorTela());
  }
}

class ContadorTela extends StatefulWidget {
  const ContadorTela({super.key});

  @override
  _ContadorTelaState createState() => _ContadorTelaState();
}

class _ContadorTelaState extends State<ContadorTela> {
  int contador = 0;

  void incrementar() {
    setState(() {
      contador++;
    });
  }

  void tirar() {
    setState(() {
      if (contador > 0) {
        contador--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Exemplo setState")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite, size: 60, color: Colors.deepOrange),
            Text("$contador Curtidas", style: TextStyle(fontSize: 30)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton.extended(
                  onPressed: incrementar,
                  icon: Icon(Icons.thumb_up_alt),
                  label: Text("Curtir"),
                  backgroundColor: const Color.fromARGB(255, 123, 255, 7),
                ),
                SizedBox(width: 10),
                FloatingActionButton.extended(
                  onPressed: tirar,
                  icon: Icon(Icons.thumb_down_alt),
                  label: Text("Descutir"),
                  backgroundColor: Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
