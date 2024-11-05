import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'fecha_provider.dart';

class ServiciosAtencionPage extends StatefulWidget {
  const ServiciosAtencionPage({super.key});

  @override
  _ServiciosAtencionPageState createState() => _ServiciosAtencionPageState();
}

class _ServiciosAtencionPageState extends State<ServiciosAtencionPage> {
  List<dynamic> servicios = [];
  bool _isLoading = true;
  late String fecha;
  late String departamentoId;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    fecha = Provider.of<FechaProvider>(context).fecha ?? '';
    departamentoId = Provider.of<FechaProvider>(context).departamentoId ?? '';

    if (_isLoading) {
      _fetchServicios(fecha, departamentoId);
    }

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

  Future<void> _fetchServicios(String fecha, String departamentoId) async {
    if (fecha.isEmpty || departamentoId.isEmpty) return;

    var url = Uri.parse(
      'http://test.api.movil.cies.org.bo/administracion/servicios_by_departamento_fecha/?fecha=$fecha&departamento_id=$departamentoId',
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

  void _onEspecialidadSelected(String especialidadId) async {
    var url = Uri.parse(
      'http://test.api.movil.cies.org.bo/agenda/regionales_internet/?especialidad=$especialidadId&departamento=$departamentoId&fecha=$fecha',
    );

    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        Navigator.pushNamed(
          context,
          '/sucursal_atencion',
          arguments: {
            'fecha': fecha,
            'departamento_id': departamentoId,
            'especialidad_id': especialidadId,
            'sucursales': data,
          },
        );
      } else {
        print('Error al obtener las sucursales: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en la conexión: $e');
    }
  }
}
