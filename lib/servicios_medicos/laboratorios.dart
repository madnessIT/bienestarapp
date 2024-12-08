import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import '/expediente_provider.dart';

class LaboratoriosPage extends StatefulWidget {
  const LaboratoriosPage({super.key});

  @override
  _LaboratoriosPageState createState() => _LaboratoriosPageState();
}

class _LaboratoriosPageState extends State<LaboratoriosPage> {
  List<dynamic> ordenesLaboratorio = [];
  bool _isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchOrdenesLaboratorio();
  }

  // Método para obtener las órdenes de laboratorio
  Future<void> _fetchOrdenesLaboratorio() async {
    final expedienteClinico = Provider.of<ExpedienteProvider>(context, listen: false).expedienteClinico;

    if (expedienteClinico == null) {
      setState(() {
        errorMessage = "El ID del expediente clínico no está disponible.";
        _isLoading = false;
      });
      return;
    }

    final url = Uri.parse(
        'http://test.api.movil.cies.org.bo/laboratorio/ordenes/$expedienteClinico/paciente/');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          ordenesLaboratorio = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = "Error al obtener las órdenes de laboratorio. Código: ${response.statusCode}";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Error de conexión: $e";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Órdenes de Laboratorio'),
        backgroundColor: Colors.blueAccent,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(
                  child: Text(
                    errorMessage!,
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                )
              : _buildOrdenesLaboratorioList(),
    );
  }

  // Construir la vista de órdenes de laboratorio
  Widget _buildOrdenesLaboratorioList() {
    if (ordenesLaboratorio.isEmpty) {
      return const Center(
        child: Text(
          'No hay órdenes de laboratorio disponibles.',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: ordenesLaboratorio.length,
      itemBuilder: (context, index) {
        var orden = ordenesLaboratorio[index];

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            title: Text(
              orden['descripcion'] ?? 'Orden sin descripción',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'Fecha: ${orden['fecha_creacion'] ?? 'No disponible'}',
              style: const TextStyle(fontSize: 14),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.blueAccent),
            onTap: () {
              // Aquí podrías implementar navegación a más detalles si es necesario
              print('Orden seleccionada: ${orden['id']}');
            },
          ),
        );
      },
    );
  }
}
