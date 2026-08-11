import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // 🔹 Função que cria um cartão
  Widget cartao({
    required String banco,
    required Color cor,
    required String numero,
    required String nome,
    required String validade,
  }) {
    return Container(
      width: 350,
      height: 200,
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Topo
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                banco,
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(Icons.contactless, size: 25, color: Colors.white),
            ],
          ),

          // Chip
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(height: 20),
              Icon(Icons.sim_card, size: 25, color: Colors.white),
            ],
          ),

          // Número do cartão
          Row(
            children: [
              Text(numero, style: TextStyle(fontSize: 25, color: Colors.white)),
            ],
          ),

          // Labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Titular",
                style: TextStyle(fontSize: 12, color: Colors.white),
              ),
              Text(
                "Validade",
                style: TextStyle(fontSize: 12, color: Colors.white),
              ),
            ],
          ),

          // Nome e validade
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                nome,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                validade,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text("Carteira Digital")),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 🔹 Cartão 1
              cartao(
                banco: "Banco SENAI",
                cor: Colors.deepPurple,
                numero: "0000 0000 0000 0000",
                nome: "João Pedro",
                validade: "12/30",
              ),

              // 🔹 Cartão 2
              cartao(
                banco: "Banco SENAI",
                cor: Colors.blue,
                numero: "1111 2222 3333 4444",
                nome: "João Pedro",
                validade: "01/28",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
