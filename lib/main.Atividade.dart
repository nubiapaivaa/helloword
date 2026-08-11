import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Atividade 1 - Container, Row e Column')),

        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 200,
                height: 100,
                color: (Colors.green),
                child: Center(
                  child: Text("CAIXA 1!", style: TextStyle(color: Colors.white)
                  ),
                ),
              ),

              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  Container(
                    width: 80,
                    height: 80,
                    color: (Colors.blue),
                  ),

                  SizedBox(width: 10),

                  Container(
                    width: 80,
                    height: 80,
                    color:  (Colors.purple),
                  ),

                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}