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
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchSignosVitales());
  }

  Future<void> _fetchSignosVitales() async {
    setState(() => _isLoading = true);
    try {
      final expedienteProvider =
          Provider.of<ExpedienteProvider>(context, listen: false);
      final expedienteClinicoId = expedienteProvider.expedienteclinicoId;

      if (expedienteClinicoId == null) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
        return;
      }

      final url = Uri.parse(
        'https://api.movil.cies.org.bo/enfermeria/enfermeria/$expedienteClinicoId/ultima_toma_signos_vitales/?regional=02',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          signosVitales = jsonDecode(response.body);
          _hasError = false;
          _isLoading = false;
        });
      } else {
        throw Exception('Error ${response.statusCode}');
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
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 1, 179, 45),
                Color.fromARGB(255, 0, 62, 143),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        color: Colors.grey[100],
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(strokeWidth: 4),
              )
            : _hasError
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 48, color: Colors.red[700]),
                        const SizedBox(height: 12),
                        const Text(
                          'Error al cargar los signos vitales.',
                          style: TextStyle(fontSize: 18, color: Colors.red),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: _fetchSignosVitales,
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  )
                : Center(
                    child: SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 500),
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 32),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'Última Toma de Signos Vitales',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 24),
                                ..._getSignosVitalesEntries()
                                    .map((e) => Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Flexible(
                                                flex: 2,
                                                child: Text(
                                                  e['label']!,
                                                  style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600),
                                                ),
                                              ),
                                              Flexible(
                                                flex: 3,
                                                child: Text(
                                                  e['value']!,
                                                  style: const TextStyle(
                                                      fontSize: 16),
                                                  textAlign:
                                                      TextAlign.end,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ))
                                    .toList(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
      ),
    );
  }

  List<Map<String, String>> _getSignosVitalesEntries() {
    return [
      {'label': 'Fecha de Registro', 'value': signosVitales?['fecha'] ?? 'ND'},
      {'label': 'Peso kg.', 'value': signosVitales?['peso']?.toString() ?? 'ND'},
      {'label': 'Talla m', 'value': signosVitales?['talla']?.toString() ?? 'ND'},
      {'label': 'Pulso', 'value': signosVitales?['pulso']?.toString() ?? 'ND'},
      {'label': 'Temperatura centigrados', 'value': signosVitales?['temperatura_oral']?.toString() ?? 'ND'},
      {'label': 'Presión Sistólica', 'value': signosVitales?['presion_sistolica']?.toString() ?? 'ND'},
      {'label': 'Presión Diastólica', 'value': signosVitales?['presion_diastolica']?.toString() ?? 'ND'},
      {'label': 'Frecuencia Cardíaca', 'value': signosVitales?['frecuencia_cardiaca']?.toString() ?? 'ND'},
      {'label': 'Saturación Oxigeno en la sangre', 'value': signosVitales?['saturacion_oxigeno']?.toString() ?? 'ND'},
    ];
  }
}
