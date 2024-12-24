import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '/expediente_provider.dart'; // Asegúrate de importar tu archivo provider

class CapturaHibridaHistorialPage extends StatefulWidget {
  const CapturaHibridaHistorialPage({super.key});

  @override
  _CapturaHibridaHistorialPageState createState() =>
      _CapturaHibridaHistorialPageState();
}

class _CapturaHibridaHistorialPageState
    extends State<CapturaHibridaHistorialPage> {
  List<dynamic> resultados = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchHistorial();
  }

  Future<void> _fetchHistorial() async {
    // Obtener el expediente clínico ID desde el provider
    final expedienteClinico = Provider.of<ExpedienteProvider>(
      context,
      listen: false,
    ).expedienteClinico;

    // Validar si expedienteClinico está disponible
    if (expedienteClinico == null) {
      setState(() {
        _isLoading = false;
      });
      print("Error: expedienteClinico es nulo");
      return;
    }

    final url = Uri.parse(
     // 'http://test.api.movil.cies.org.bo/resultado_captura_hibrida_resultado_editar/list_captura_hibrida_historial_con_resultado_informados_no_informados/?expediente_clinico=$expedienteClinico',
         'http://test.api.movil.cies.org.bo/resultado_pap_informado/list_pap_historial_con_resultado_informados_no_informados/?expediente_clinico=$expedienteClinico',   
    );

    print(expedienteClinico);
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          resultados = data['results'];
          _isLoading = false;
        });
      } else {
        throw Exception('Error: ${response.statusCode}');
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
    // Obtener solo los últimos 2 resultados
    final ultimosResultados =
        resultados.length > 2 ? resultados.sublist(resultados.length - 2) : resultados;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Historial de PAPANICOLAO"),
        backgroundColor: Colors.blueAccent,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ultimosResultados.isEmpty
              ? const Center(child: Text("No se encontraron registros."))
              : ListView.builder(
                  itemCount: ultimosResultados.length,
                  itemBuilder: (context, index) {
                    final item = ultimosResultados[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      child: ListTile(
                        title: Text(
                          "Resultado: ${item['resultado'] ?? 'No disponible'}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                "Paciente: ${item['expediente_clinico']['nombre_paciente']}"),
                            Text(
                                "Médico: ${item['comprobante_detalle']['nombre_medico']}"),
                            Text(
                                "Fecha toma: ${item['fecha_toma_muestra']?.split('T')[0]}"),
                          ],
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          // Acción al seleccionar un registro
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
