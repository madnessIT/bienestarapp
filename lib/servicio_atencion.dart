import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'fecha_provider.dart';
import 'servicio_provider.dart';

class ServiciosAtencionPage extends StatefulWidget {
  const ServiciosAtencionPage({super.key});

  @override
  _ServiciosAtencionPageState createState() => _ServiciosAtencionPageState();
}

class _ServiciosAtencionPageState extends State<ServiciosAtencionPage> {
  List<dynamic> servicios = [];
  List<dynamic> filteredServicios = [];
  bool _isLoading = true;
  late String fecha;
  late String departamentoId;
  late String departamentoNombre;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    fecha = Provider.of<FechaProvider>(context).fecha ?? '';
    departamentoId = Provider.of<FechaProvider>(context).departamentoId ?? '';
    departamentoNombre = Provider.of<FechaProvider>(context).departamentoNombre ?? '';

    if (_isLoading) {
      _fetchServicios(fecha, departamentoId);
    }

    return Scaffold(
      appBar: AppBar(
  title: const Text(
    'Servicios Disponibles',
    style: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
    ),
  ),
  flexibleSpace: Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Color.fromARGB(255, 1, 179, 45), // Verde        //const Color.fromARGB(255, 1, 179, 45),
          Color.fromARGB(255, 0, 62, 143), // Azul
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
  ),
),
      body: Column(
        children: [
          // Logo y detalles en la parte superior
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              children: [
                Center(
                  child: Image.asset(
                    'assets/images/logo.png', // Asegúrate de que la ruta sea correcta
                    height: 80,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Fecha de Atención: $fecha',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                Text(
                  'Regional: $departamentoNombre',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          // Buscador
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar servicio...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                  filteredServicios = servicios.where((servicio) {
                    final nombre = servicio['nombre']?.toLowerCase() ?? '';
                    return nombre.contains(searchQuery);
                  }).toList();
                });
              },
            ),
          ),
          // Lista de servicios
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ListView.builder(
                      itemCount: filteredServicios.length,
                      itemBuilder: (context, index) {
                        var servicio = filteredServicios[index];
                        var especialidades = servicio['especialidades'] as List<dynamic>;

                        return Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                            title: Text(
                              servicio['nombre'],
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              servicio['codigo'] ?? 'Sin Codigo',
                              style: const TextStyle(color: Colors.grey),
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.blueAccent),
                            onTap: () {
                              if (especialidades.isNotEmpty) {
                                String especialidadId = especialidades[0]['id'].toString();
                                _onEspecialidadSelected(servicio['nombre'], servicio['codigo'], especialidadId);
                              } else {
                                print("No hay especialidades disponibles para este servicio");
                              }
                            },
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
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
          filteredServicios = servicios;
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

  void _onEspecialidadSelected(String servicioNombre, String servicioCodigo, String especialidadId) async {
    // Actualiza el servicio seleccionado en el ServicioProvider
    Provider.of<ServicioProvider>(context, listen: false).setServicio(servicioNombre, servicioCodigo);

    var url = Uri.parse(
      'http://test.api.movil.cies.org.bo/agenda/regionales_tes/?especialidad=$especialidadId&departamento=$departamentoId&fecha=$fecha',

      ///agenda/regionales_internet/?especialidad=$especialidadId&departamento=$departamentoId&fecha=$fecha',
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
