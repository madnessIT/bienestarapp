import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MedicoAtencionPage extends StatefulWidget {
  const MedicoAtencionPage({super.key});

  @override
  _MedicoAtencionPageState createState() => _MedicoAtencionPageState();
}

class _MedicoAtencionPageState extends State<MedicoAtencionPage> {
  List<dynamic> medicos = [];
  bool _isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args != null) {
      final String regionalId = args['regional_id'];
      final String especialidadId = args['especialidad_id'];
      final String fecha = args['fecha'];
      _fetchMedicos(regionalId, especialidadId, fecha);
    }
  }

  // Método para obtener médicos por fecha, regional y especialidad
  Future<void> _fetchMedicos(String regionalId, String especialidadId, String fecha) async {
    var url = Uri.parse(
      'http://test.api.movil.cies.org.bo/agenda/agendas/turno_by_medico_by_especialidad_and_regional/?fecha=$fecha&regional_id=$regionalId&especialidad_id=$especialidadId',
    );

    try {
      var response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          medicos = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        print('Error al obtener los médicos: ${response.statusCode}');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error en la conexión: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar Médico'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : medicos.isEmpty
              ? const Center(child: Text('No hay médicos disponibles'))
              : ListView.builder(
                  itemCount: medicos.length,
                  itemBuilder: (context, index) {
                    var medico = medicos[index];
                    return ListTile(
                      title: Text(medico['nombre'] ?? 'Nombre no disponible'),
                      subtitle: Text('Turno: ${medico['turno']}'),
                      onTap: () {
                        // Aquí puedes manejar la selección del médico
                      },
                    );
                  },
                ),
    );
  }
}
