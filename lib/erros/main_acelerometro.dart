import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SensorPage(),
    );
  }
}

class SensorPage extends StatefulWidget {
  const SensorPage({super.key});

  @override
  State<SensorPage> createState() => _SensorPageState();
}

class _SensorPageState extends State<SensorPage> {
  double x = 0;
  double y = 0;
  double z = 0;

  bool emMovimento = false;
  int deteccoesMovimento = 0;
  bool indicadorAlternado = false;

  StreamSubscription<AccelerometerEvent>? assinaturaAcelerometro;

  static const double limiarMovimento = 1.5;
  static const double gravidade = 9.8;

  @override
  void initState() {
    super.initState();

    // Recebe os valores do acelerômetro
    assinaturaAcelerometro = accelerometerEventStream().listen((event) {
      final magnitude = sqrt(
        event.x * event.x +
            event.y * event.y +
            event.z * event.z,
      );

      final movimentoDetectado =
          (magnitude - gravidade).abs() > limiarMovimento;

      setState(() {
        x = event.x;
        y = event.y;
        z = event.z;

        emMovimento = movimentoDetectado;

        if (movimentoDetectado) {
          deteccoesMovimento++;
          indicadorAlternado = !indicadorAlternado;
        }
      });
    });
  }

  @override
  void dispose() {
    assinaturaAcelerometro?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sensor do celular'),
        backgroundColor: emMovimento ? Colors.red : Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Acelerômetro',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 40),

            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: indicadorAlternado ? 150 : 110,
              height: indicadorAlternado ? 70 : 50,
              alignment: Alignment.center,
              color: emMovimento ? Colors.red : Colors.green,
              child: Text(
                emMovimento ? 'MOVIMENTO' : 'PARADO',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 16),

            Text(
              'Detecções: $deteccoesMovimento',
              style: const TextStyle(fontSize: 18),
            ),

            const SizedBox(height: 24),

            Text(
              'X: ${x.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 24),
            ),

            Text(
              'Y: ${y.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 24),
            ),

            Text(
              'Z: ${z.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 24),
            ),
          ],
        ),
      ),
    );
  }
}