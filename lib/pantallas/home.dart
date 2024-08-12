import 'dart:async';
import 'package:flutter/material.dart';
import 'package:after_layout/after_layout.dart';
import 'package:firebase_database/firebase_database.dart';
import 'GTemp.dart';
import 'GHume.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

// Función para mostrar el mensaje de temperatura
Widget temperatureMessage(double temperature) {
  if (temperature < 0) {
    return Text(
      'Hace frío',
      style: TextStyle(color: Colors.blue),
    );
  } else if (temperature <= 30) {
    return Text(
      'La temperatura está agradable',
      style: TextStyle(color: Colors.green),
    );
  } else {
    return Text(
      'La temperatura está muy alta',
      style: TextStyle(color: Colors.red),
    );
  }
}

// Función para mostrar el mensaje de humedad
Widget humidityMessage(double humidity) {
  if (humidity < 0) {
    return Text(
      'El tiempo es seco',
      style: TextStyle(color: Colors.brown),
    );
  } else if (humidity < 50) {
    return Text(
      'La humedad es media',
      style: TextStyle(color: Colors.yellow),
    );
  } else {
    return Text(
      'La humedad es alta',
      style: TextStyle(color: Colors.purple),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with AfterLayoutMixin<Home> {
  double humidity = 0, temperature = 0;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gauge"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              setState(() {
                isLoading = true;
              });
              await getData();
              setState(() {
                isLoading = false;
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: GTemp(temperature: temperature)),
              const Divider(height: 5),
              Expanded(child: GHume(humidity: humidity)),
              const Divider(height: 5),
              temperatureMessage(temperature),
              humidityMessage(humidity),
            ],
          ),
          if (isLoading)
            Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }

  @override
  FutureOr<void> afterFirstLayout(BuildContext context) async {
    Timer.periodic(
      const Duration(seconds: 30),
          (timer) async {
        await getData();
      },
    );
    await getData();
  }

  Future<void> getData() async {
    final ref = FirebaseDatabase.instance.ref();
    final temp = await ref.child("Living Room/temperature/value").get();
    final humi = await ref.child("Living Room/humidity/value").get();
    if (temp.exists && humi.exists) {
      setState(() {
        temperature = double.parse(temp.value.toString());
        humidity = double.parse(humi.value.toString());
      });
    } else {
      setState(() {
        temperature = -1;
        humidity = -1;
      });
    }
  }
}
