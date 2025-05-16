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
                  : _buildRecetaCard(ultimaReceta!),
    );
  }

  Widget _buildRecetaCard(Map<String, dynamic> receta) {
  final detalles = receta['detalles'] as List<dynamic>?;

  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Colors.white,
      shadowColor: Colors.grey.withOpacity(0.4),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Última Receta',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.medication,
                  color: Color(0xFF27AE60),
                  size: 30,
                ),
                const SizedBox(width: 10),
                Text(
                  'ID: ${receta['id'] ?? 'No disponible'}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Fecha de Creación: ${receta['fecha_creacion']?.split('T')[0] ?? 'No disponible'}',
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 15),
            const Text(
              'Detalles:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2980B9),
              ),
            ),
            const SizedBox(height: 12),
            if (detalles != null && detalles.isNotEmpty)
              ...detalles.map((detalle) => _buildDetalleRow(detalle))
            else
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text(
                  'No hay detalles disponibles.',
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildDetalleRow(Map<String, dynamic> detalle) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Row(
      children: [
        const Icon(
          Icons.medication, // Use the medication icon
          color: Color(0xFF8E44AD),
          size: 24,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            detalle['nombre_generico'] ?? 'No disponible',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF34495E),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'Cantidad: ${detalle['cantidad']?.toString() ?? 'No disponible'}',
          style: const TextStyle(fontSize: 16, color: Color(0xFF27AE60)),
        ),
      ],
    ),
  );
}


}
