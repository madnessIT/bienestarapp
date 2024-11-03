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
      firstDate: DateTime.now(), // Solo fechas futuras
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
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
                child: const Text('Continuar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateButton() {
    return ElevatedButton(
      onPressed: () => _selectDate(context),
      child: Text(
        _selectedDate == null
            ? 'Seleccione la Fecha'
            : 'Fecha Seleccionada: ${_selectedDate!.toString().split(' ')[0]}',
      ),
    );
  }

  Widget _buildRegionalDropdown() {
    return _isLoadingRegional
        ? const CircularProgressIndicator()
        : DropdownButton<String>(
            value: _selectedRegionalId,
            hint: const Text('Seleccione la Regional'),
            onChanged: (String? newValue) {
              setState(() => _selectedRegionalId = newValue);
            },
            items: regionales.map((regional) {
              return DropdownMenuItem<String>(
                value: regional['id'].toString(),
                child: Text(regional['nombre']),
              );
            }).toList(),
          );
  }
}
