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

  // Método para manejar la selección de especialidad y navegar a sucursal_atencion.dart
  void _onEspecialidadSelected(String especialidadId) async {
    // Construir la URL para el endpoint con los parámetros necesarios
    var url = Uri.parse(
      'http://test.api.movil.cies.org.bo/agenda/regionales_internet/?especialidad=$especialidadId&departamento=${widget.departamentoId}&fecha=${widget.fecha}',
    );

    try {
      var response = await http.get(url);

      if (response.statusCode == 200) {
        // Decodificar la respuesta y navegar a la siguiente página con los datos recibidos
        var data = jsonDecode(response.body);
        Navigator.pushNamed(
          context,
          '/sucursal_atencion',
          arguments: {
            'fecha': widget.fecha,
            'departamento_id': widget.departamentoId,
            'especialidad_id': especialidadId,
            'sucursales': data, // Enviar las sucursales obtenidas
          },
        );
      } else {
        print('Error al obtener las sucursales: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en la conexión: $e');
    }
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
                var especialidades = servicio['especialidades'] as List<dynamic>;

                return ListTile(
                  title: Text(servicio['nombre']),
                  subtitle: Text(servicio['descripcion'] ?? 'Sin descripción'),
                  onTap: () {
                    // Obtener el id de la primera especialidad
                    if (especialidades.isNotEmpty) {
                      String especialidadId = especialidades[0]['id'].toString();
                      _onEspecialidadSelected(especialidadId);
                    } else {
                      print("No hay especialidades disponibles para este servicio");
                    }
                  },
                );
              },
            ),
    );
  }
}
