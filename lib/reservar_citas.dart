import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'fecha_provider.dart';

class ReservarCitasPage extends StatefulWidget {
  const ReservarCitasPage({super.key});

  @override
  _ReservarCitasPageState createState() => _ReservarCitasPageState();
}

class _ReservarCitasPageState extends State<ReservarCitasPage> {
  DateTime? _selectedDate;
  String? _selectedRegionalId;
  bool _isLoadingRegional = true;
  List<dynamic> regionales = [];

  @override
  void initState() {
    super.initState();
    _fetchRegionales();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        Provider.of<FechaProvider>(context, listen: false)
            .setFecha(picked.toIso8601String().split('T')[0]);
      });
    }
  }

  Future<void> _fetchRegionales() async {
    var url = Uri.parse('http://test.api.movil.cies.org.bo/administracion/departamentos/');
    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        setState(() {
          regionales = data.where((regional) => regional['activo'] == true).toList();
          _isLoadingRegional = false;
        });
      } else {
        _showError('Error al obtener las regionales. Código: ${response.statusCode}');
        setState(() => _isLoadingRegional = false);
      }
    } catch (e) {
      _showError('Error en la conexión: $e');
      setState(() => _isLoadingRegional = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _goToServiciosClinica() {
    if (_selectedDate != null && _selectedRegionalId != null) {
      Navigator.pushNamed(
        context,
        '/servicio_atencion',
        arguments: {
          'fecha': _selectedDate!.toIso8601String().split('T')[0],
          'departamento_id': _selectedRegionalId,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Reservar Cita Medica',
          style: TextStyle(
            color: Colors.white,  // Cambiar el color del texto a blanco
            fontWeight: FontWeight.bold, // Fuente en negrita
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 1, 179, 45),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo en la parte superior
              Center(
                child: Image.asset(
                  'assets/images/logo.png',  // Ruta de tu logo en assets
                  height: 100,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Introducir Fecha:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _buildDateButton(),
              const SizedBox(height: 20),
              const Text(
                'Seleccione una Regional:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _buildRegionalDropdown(),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: (_selectedDate != null && _selectedRegionalId != null)
                      ? _goToServiciosClinica
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 1, 179, 45),
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Continuar',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateButton() {
    return ElevatedButton.icon(
      onPressed: () => _selectDate(context),
      icon: const Icon(Icons.calendar_today, color: Colors.white),
      label: Text(
        _selectedDate == null
            ? 'Seleccione la Fecha'
            : 'Fecha Seleccionada: ${_selectedDate!.toString().split(' ')[0]}',
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 1, 179, 45),
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
Widget _buildRegionalDropdown() {
  return _isLoadingRegional
      ? const Center(child: CircularProgressIndicator())
      : DropdownButtonFormField<String>(
          value: _selectedRegionalId,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          hint: const Text('Seleccione la Regional'),
          onChanged: (String? newValue) {
            setState(() {
              _selectedRegionalId = newValue;
              if (newValue != null) {
                final regional = regionales.firstWhere(
                  (r) => r['id'].toString() == newValue,
                  orElse: () => null,
                );
                final regionalNombre = regional != null ? regional['nombre'] : '';
                Provider.of<FechaProvider>(context, listen: false)
                  ..setDepartamentoId(newValue)
                  ..setDepartamentoNombre(regionalNombre);
              }
            });
          },
          items: regionales
              .where((regional) => regional['id'] == 1) // Filtrar solo regionales con ID 1
              .map((regional) {
                return DropdownMenuItem<String>(
                  value: regional['id'].toString(),
                  child: Text(regional['nombre']),
                );
              }).toList(),
        );
}

 
}