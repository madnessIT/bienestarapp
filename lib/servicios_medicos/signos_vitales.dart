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
        title: const Text('Signos Vitales'),
        backgroundColor: Colors.blueAccent,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hasError
              ? const Center(
                  child: Text(
                    'Error al cargar los signos vitales.',
                    style: TextStyle(fontSize: 18, color: Colors.red),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Última Toma de Signos Vitales',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      _buildSignosVitalesData(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildSignosVitalesData() {
    if (signosVitales == null || signosVitales!.isEmpty) {
      return const Text(
        'No se encontraron datos de signos vitales.',
        style: TextStyle(fontSize: 16),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDataRow('Fecha de Registro', signosVitales!['fecha']),
        _buildDataRow('Peso', signosVitales!['peso']),
        _buildDataRow('Talla', signosVitales!['talla']),
        _buildDataRow('Pulso', signosVitales!['pulso']),
        _buildDataRow('Temperatura Oral', signosVitales!['temperatura_oral']),
        _buildDataRow('Temperatura Axila', signosVitales!['temperatura_axila']),
        _buildDataRow('Temperatura Rectal', signosVitales!['temperatura_rectal']),
        _buildDataRow('Temperatura Digital', signosVitales!['temperatura_digital']),
        _buildDataRow('Presión Sistolica', signosVitales!['presion_sistolica']),
        _buildDataRow('Presión Diastolica', signosVitales!['presion_diastolica']),
        _buildDataRow('Frecuencia Respiratoria', signosVitales!['frecuencia_respiratoria']),
        _buildDataRow('Frecuencia Cardíaca', signosVitales!['frecuencia_cardiaca']),
        _buildDataRow('Saturación de Oxígeno', signosVitales!['saturacion_oxigeno']),
        _buildDataRow('Evolucion', signosVitales!['evolucion']),
        
      ],
    );
  }

  Widget _buildDataRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(
            value != null ? value.toString() : 'No disponible',
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
