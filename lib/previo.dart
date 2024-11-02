import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ServiciosAtencionPage extends StatefulWidget {
  final String fecha;
  final String departamentoId;

  const ServiciosAtencionPage({
    super.key,
    required this.fecha,
    required this.departamentoId,
  });

  @override
  _ServiciosAtencionPageState createState() => _ServiciosAtencionPageState();
}

class _ServiciosAtencionPageState extends State<ServiciosAtencionPage> {
  List<dynamic> servicios = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchServicios();
  }

  // Método para obtener los servicios por fecha y departamento
  Future<void> _fetchServicios() async {
    var url = Uri.parse(
      'http://test.api.movil.cies.org.bo/administracion/servicios_by_departamento_fecha/?fecha=${widget.fecha}&departamento_id=${widget.departamentoId}',
    );

    try {
      var response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          servicios = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        print('Error: ${response.statusCode}');
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

  // Método para manejar la selección de especialidad
  void _onEspecialidadSelected(String especialidadId, String especialidadNombre) {
    Navigator.pushNamed(
      context,
      '/sucursal_atencion',
      arguments: {
        'fecha': widget.fecha,
        'departamento_id': widget.departamentoId,
        'especialidad_id': especialidadId,
        'especialidad_nombre': especialidadNombre,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Servicios Disponibles'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: servicios.length,
              itemBuilder: (context, index) {
                var servicio = servicios[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    title: Text(servicio['nombre']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Código: ${servicio['codigo']}'),
                        const SizedBox(height: 5),
                        const Text('Especialidades:', style: TextStyle(fontWeight: FontWeight.bold)),
                        ...servicio['especialidades'].map<Widget>((especialidad) {
                          return ListTile(
                            title: Text(especialidad['nombre']),
                            onTap: () {
                              _onEspecialidadSelected(
                                especialidad['id'].toString(), // Usar el ID de la especialidad
                                especialidad['nombre'],
                              );
                            },
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
