import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'fecha_provider.dart';

class ReservarCitasPage extends StatefulWidget {
  const ReservarCitasPage({super.key});

  @override
  State<ReservarCitasPage> createState() => _ReservarCitasPageState();
}

class _ReservarCitasPageState extends State<ReservarCitasPage> {
  DateTime? _selectedDate;
  final String _selectedRegionalId = '1'; // Regional por defecto: La Paz (ID=1)
  bool _isLoadingRegional = true;
  List<dynamic> regionales = [];

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    // Se establece la fecha y la regional por defecto en el provider
    Provider.of<FechaProvider>(context, listen: false)
      ..setFecha(_selectedDate!.toIso8601String().split('T')[0])
      ..setDepartamentoId(_selectedRegionalId)
      ..setDepartamentoNombre('La Paz'); // Regional fija
    _fetchRegionales();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
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
    //var url = Uri.parse('http://test.api.movil.cies.org.bo/administracion/departamentos/');
    var url = Uri.parse('https://api.movil.cies.org.bo/administracion/departamentos/');
    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        setState(() {
          // Filtramos solo las regionales activas
          regionales = data.where((regional) => regional['activo'] == true).toList();
          _isLoadingRegional = false;
          // Actualizamos el provider si se encuentra la regional "1"
          if (regionales.any((regional) => regional['id'].toString() == '1')) {
            Provider.of<FechaProvider>(context, listen: false)
              ..setDepartamentoId(_selectedRegionalId)
              ..setDepartamentoNombre('La Paz');
          } else if (regionales.isNotEmpty) {
            // Si no se encuentra la regional "1", se toma la primera disponible
            final first = regionales.first;
            Provider.of<FechaProvider>(context, listen: false)
              ..setDepartamentoId(first['id'].toString())
              ..setDepartamentoNombre(first['nombre']);
          }
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
    if (_selectedDate != null) {
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
          'Reservar cita médica',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
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
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.blue.shade100],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 8,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Image.asset(
                            'assets/images/logo.png',
                            height: 100,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Introducir Fecha:',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        _buildDateButton(),
                        const SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: (_selectedDate != null)
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
                      ],
                    ),
                  ),
                ),
              ),
            ),
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
        'Fecha Seleccionada: ${_selectedDate!.toString().split(' ')[0]}',
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
}
