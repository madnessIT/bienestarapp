import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ReservarCitasPage extends StatefulWidget {
  const ReservarCitasPage({super.key});

  @override
  _ReservarCitasPageState createState() => _ReservarCitasPageState();
}

class _ReservarCitasPageState extends State<ReservarCitasPage> {
  DateTime? _selectedDate;
  String? _selectedRegionalId; // Guardar el ID del departamento seleccionado
  bool _isLoadingRegional = true;
  List<dynamic> regionales = [];

  @override
  void initState() {
    super.initState();
    _fetchRegionales();
  }

  // Método para seleccionar fecha
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Método para obtener regionales desde la API
  Future<void> _fetchRegionales() async {
    var url = Uri.parse('http://test.api.movil.cies.org.bo/administracion/departamentos/');

    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        setState(() {
          // Filtrar solo departamentos activos
          regionales = data.where((regional) => regional['activo'] == true).toList();
          _isLoadingRegional = false;
        });
      } else {
        print('Error al obtener las regionales: ${response.statusCode}');
        setState(() {
          _isLoadingRegional = false;
        });
      }
    } catch (e) {
      print('Error en la conexión: $e');
      setState(() {
        _isLoadingRegional = false;
      });
    }
  }

  // Navegar a la página de servicios clínicos con fecha y ID de departamento seleccionado
  void _goToServiciosClinica() {
  if (_selectedDate != null && _selectedRegionalId != null) {
    Navigator.pushNamed(
      context,
      '/servicio_atencion',
      arguments: {
        'fecha': _selectedDate!.toIso8601String().split('T')[0], // Solo la fecha
        'departamento_id': _selectedRegionalId, // Enviar el ID de la regional
      },
    );
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reservar Cita Médica'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Introducir Fecha:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _selectDate(context),
              child: Text(
                _selectedDate == null
                    ? 'Seleccione la Fecha'
                    : 'Fecha Seleccionada: ${_selectedDate!.toString().split(' ')[0]}',
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Seleccione una Regional:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _isLoadingRegional
                ? const CircularProgressIndicator()
                : DropdownButton<String>(
                    value: _selectedRegionalId, // El valor seleccionado es el ID
                    hint: const Text('Seleccione la Regional'),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedRegionalId = newValue; // Guardar el ID de la regional seleccionada
                      });
                    },
                    items: regionales.isNotEmpty
                        ? regionales.map((regional) {
                            return DropdownMenuItem<String>(
                              value: regional['id'].toString(), // Usar el ID como valor
                              child: Text(regional['nombre']), // Mostrar el nombre
                            );
                          }).toList()
                        : [],
                  ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: (_selectedDate != null && _selectedRegionalId != null)
                    ? _goToServiciosClinica
                    : null, // Desactiva el botón si no hay fecha y regional seleccionada
                child: const Text('Continuar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
