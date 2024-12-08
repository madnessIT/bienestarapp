import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '/expediente_provider.dart'; // Importa tu provider

class RecetasPage extends StatefulWidget {
  const RecetasPage({super.key});

  @override
  _RecetasPageState createState() => _RecetasPageState();
}

class _RecetasPageState extends State<RecetasPage> {
  bool _isLoading = true;
  List<dynamic> _recetas = []; // Aquí almacenaremos las recetas

  @override
  void initState() {
    super.initState();
    _fetchRecetas();
  }

  Future<void> _fetchRecetas() async {
    // Obtener el ID del expediente clínico desde el Provider
    final expedienteClinico = Provider.of<ExpedienteProvider>(context, listen: false).expedienteClinico;

    if (expedienteClinico == null) {
      // Manejar el caso en que el expedienteId no esté disponible
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se encontró el expediente clínico')),
      );
      return;
    }
      var url = Uri.parse('http://test.api.movil.cies.org.bo/historia_clinica/expediente_clinico/$expedienteClinico/');
    //var url = Uri.parse('http://test.api.movil.cies.org.bo/laboratorio/ordenes/$expedienteId/paciente/');
                             
    try {
      var response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          _recetas = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.statusCode} al cargar recetas')),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de conexión: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recetas Médicas'),
        backgroundColor: Colors.blueAccent,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _recetas.isEmpty
              ? const Center(
                  child: Text('No hay recetas disponibles'),
                )
              : ListView.builder(
                  itemCount: _recetas.length,
                  itemBuilder: (context, index) {
                    var receta = _recetas[index];
                    return Card(
                      margin: const EdgeInsets.all(10.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 5,
                      child: ListTile(
                        title: Text(
                          receta['nombre_receta'] ?? 'Receta sin nombre',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Fecha: ${receta['fecha_emision'] ?? 'No disponible'}',
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.blueAccent),
                        onTap: () {
                          // Aquí puedes agregar la lógica para mostrar más detalles de la receta
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
