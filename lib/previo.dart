import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ServiciosAtencionPage extends StatefulWidget {
  const ServiciosAtencionPage({super.key});

  @override
  _ServiciosAtencionPageState createState() => _ServiciosAtencionPageState();
}

class _ServiciosAtencionPageState extends State<ServiciosAtencionPage> {
  List<dynamic> servicios = [];
  bool _isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      _fetchServicios(args['fecha'], args['departamento_id']);
    }
  }

  Future<void> _fetchServicios(String fecha, String departamentoId) async {
    // Construimos la URL con los parámetros
    var url = Uri.parse(
      'http://test.api.movil.cies.org.bo/administracion/servicios_by_departamento_fecha/?fecha=$fecha&departamento_id=$departamentoId',
    );

    try {
      // Agrega el token de autenticación en los encabezados
      var response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer TU_TOKEN_DE_AUTENTICACION', // Reemplaza con tu token
          'Content-Type': 'application/json',
        },
      );

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
                return ListTile(
                  title: Text(servicios[index]['nombre']),
                  subtitle: Text(servicios[index]['descripcion'] ?? 'Sin descripción'),
                );
              },
            ),
    );
  }
}
