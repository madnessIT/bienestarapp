import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '/expediente_provider.dart';

class SignosVitalesPage extends StatefulWidget {
  const SignosVitalesPage({super.key});

  @override
  _SignosVitalesPageState createState() => _SignosVitalesPageState();
}

class _SignosVitalesPageState extends State<SignosVitalesPage> {
  Map<String, dynamic>? signosVitales;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchSignosVitales();
  }

  Future<void> _fetchSignosVitales() async {
    try {
      final expedienteProvider = Provider.of<ExpedienteProvider>(context, listen: false);
      final expedienteClinicoId = expedienteProvider.expedienteclinicoId;

      if (expedienteClinicoId == null) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
        return;
      }

      final url = Uri.parse(
        'http://test.api.movil.cies.org.bo/enfermeria/enfermeria/$expedienteClinicoId/ultima_toma_signos_vitales/',
      );

      final response = await http.get(url, headers: {'regional': '02'});

      if (response.statusCode == 200) {
        setState(() {
          signosVitales = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
  title: const Text(
    'Signos Vitales',
    style: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
    ),
  ),
  flexibleSpace: Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Color.fromARGB(255, 1, 179, 45), // Verde        //const Color.fromARGB(255, 1, 179, 45),
          Color.fromARGB(255, 0, 62, 143), // Azul
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
  ),
),
    body: _isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : _hasError
            ? const Center(
                child: Text(
                  'Error al cargar los signos vitales.',
                  style: TextStyle(fontSize: 18, color: Colors.red, fontWeight: FontWeight.bold),
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Text(
                        'Última Toma de Signos Vitales',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _getSignosVitalesEntries().length,
                        itemBuilder: (context, index) {
                          final entry = _getSignosVitalesEntries()[index];
                          return _buildDataRow(entry['label']!, entry['value']!);
                        },
                      ),
                    ),
                  ],
                ),
              ),
  );
}

Widget _buildDataRow(String label, String value) {
  return Card(
    margin: const EdgeInsets.symmetric(vertical: 8.0),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    elevation: 3,
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueAccent),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    ),
  );
}

List<Map<String, String>> _getSignosVitalesEntries() {
  return [
    {'label': 'Fecha de Registro', 'value': signosVitales?['fecha'] ?? 'No disponible'},
    {'label': 'Peso', 'value': signosVitales?['peso']?.toString() ?? 'No disponible'},
    {'label': 'Talla', 'value': signosVitales?['talla']?.toString() ?? 'No disponible'},
    {'label': 'Pulso', 'value': signosVitales?['pulso']?.toString() ?? 'No disponible'},
    {'label': 'Temperatura Oral', 'value': signosVitales?['temperatura_oral']?.toString() ?? 'No disponible'},
    {'label': 'Presión Sistólica', 'value': signosVitales?['presion_sistolica']?.toString() ?? 'No disponible'},
    {'label': 'Presión Diastólica', 'value': signosVitales?['presion_diastolica']?.toString() ?? 'No disponible'},
    {'label': 'Frecuencia Cardíaca', 'value': signosVitales?['frecuencia_cardiaca']?.toString() ?? 'No disponible'},
    {'label': 'Saturación de Oxígeno', 'value': signosVitales?['saturacion_oxigeno']?.toString() ?? 'No disponible'},
  ];
}


}
