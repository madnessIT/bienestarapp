import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '/expediente_provider.dart';

class RecetasPage extends StatefulWidget {
  const RecetasPage({super.key});

  @override
  _RecetasPageState createState() => _RecetasPageState();
}

class _RecetasPageState extends State<RecetasPage> {
  Map<String, dynamic>? ultimaReceta;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchUltimaReceta();
  }

  Future<void> _fetchUltimaReceta() async {
    try {
      final expedienteProvider =
          Provider.of<ExpedienteProvider>(context, listen: false);
      final expedienteClinico = expedienteProvider.expedienteClinico;

      if (expedienteClinico == null) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Expediente clínico no disponible.';
          _isLoading = false;
        });
        return;
      }

      final url = Uri.parse(
        'https://api.movil.cies.org.bo/historia_clinica/expediente_clinico/$expedienteClinico/',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Buscar la última receta
        final recetas = <Map<String, dynamic>>[];

        for (var entry in data) {
          if (entry['evoluciones'] is List) {
            for (var evolucion in entry['evoluciones']) {
              if (evolucion['indicaciones']?['recetas'] is List) {
                recetas.addAll(
                  (evolucion['indicaciones']['recetas'] as List<dynamic>)
                      .whereType<Map<String, dynamic>>(),
                );
              }
            }
          }
        }

        // Ordenar recetas por fecha y obtener la última
        recetas.sort((a, b) {
          final fechaA = DateTime.parse(a['fecha_creacion']);
          final fechaB = DateTime.parse(b['fecha_creacion']);
          return fechaB.compareTo(fechaA);
        });

        setState(() {
          ultimaReceta = recetas.isNotEmpty ? recetas.first : null;
          _isLoading = false;
        });
      } else {
        throw Exception('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        _hasError = true;
        _errorMessage = 'Error al cargar las recetas: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  title: const Text(
    'Receta Medica',
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
          ? const Center(child: CircularProgressIndicator())
          : _hasError
              ? Center(
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(fontSize: 18, color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                )
              : ultimaReceta == null
                  ? const Center(
                      child: Text(
                        'No hay recetas disponibles.',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    )
                  : Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 800),
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: _buildRecetaCard(ultimaReceta!),
                        ),
                      ),
                    ),
    );
  }

  Widget _buildRecetaCard(Map<String, dynamic> receta) {
    final detalles = receta['detalles'] as List<dynamic>?;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.white,
        shadowColor: Colors.black26,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF27AE60).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.receipt_long,
                      color: Color(0xFF27AE60),
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'Última Receta Médica',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildInfoRow('ID de receta:', receta['id']?.toString() ?? 'No disponible'),
              const SizedBox(height: 12),
              _buildInfoRow('Fecha de Creación:', receta['fecha_creacion']?.split('T')[0] ?? 'No disponible'),
              const SizedBox(height: 24),
              const Divider(thickness: 1.5),
              const SizedBox(height: 16),
              const Text(
                'Medicamentos Recetados',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2980B9),
                ),
              ),
              const SizedBox(height: 16),
              if (detalles != null && detalles.isNotEmpty)
                ...detalles.asMap().entries.map((entry) {
                  return Column(
                    children: [
                      _buildDetalleRow(entry.value),
                      if (entry.key != detalles.length - 1)
                        const Divider(height: 24, color: Colors.black12),
                    ],
                  );
                })
              else
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text(
                      'No hay detalles disponibles en esta receta.',
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 16, color: Colors.black54),
          ),
        ),
      ],
    );
  }

  Widget _buildDetalleRow(Map<String, dynamic> detalle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Icon(
          Icons.medication_liquid,
          color: Color(0xFF8E44AD),
          size: 32,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                detalle['nombre_generico'] ?? 'No disponible',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF34495E),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Indicaciones: ${detalle['indicaciones'] ?? 'No especificadas'}',
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF27AE60).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF27AE60).withOpacity(0.3)),
          ),
          child: Text(
            'Cant: ${detalle['cantidad']?.toString() ?? '-'}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF27AE60),
            ),
          ),
        ),
      ],
    );
  }


}
