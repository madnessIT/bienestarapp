import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '/expediente_provider.dart'; // Importa el proveedor de expediente clínico

class LaboratorioPage extends StatefulWidget {
  const LaboratorioPage({super.key});

  @override
  _LaboratorioPageState createState() => _LaboratorioPageState();
}

class _LaboratorioPageState extends State<LaboratorioPage> {
  late Future<List<Registro>> registros;

  @override
  void initState() {
    super.initState();
    registros = fetchLaboratorioData();
  }

  Future<List<Registro>> fetchLaboratorioData() async {
  try {
    final expedienteClinico = Provider.of<ExpedienteProvider>(context, listen: false).expedienteClinico;

    if (expedienteClinico == null || expedienteClinico <= 0) {
      throw Exception('El ID del expediente clínico es inválido o no está disponible.');
    }

    final url = Uri.parse(
      'https://api.movil.cies.org.bo/laboratorio/ordenes/$expedienteClinico/paciente/?regional=02'
    );

    final response = await http.get(url); // <- sin headers

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);

      if (jsonResponse is Map && jsonResponse.containsKey('message')) {
        throw Exception(jsonResponse['message']);
      }

      if (jsonResponse is List) {
        final registros = jsonResponse.map((x) => Registro.fromJson(x)).toList();

        // Ordenar los registros por fecha de creación en orden descendente
        registros.sort((a, b) => b.fechaCreacion.compareTo(a.fechaCreacion));

        // Retornar los últimos dos registros
        return registros.length > 2 ? registros.sublist(0, 2) : registros;
      } else {
        throw Exception('Respuesta JSON inesperada: $jsonResponse');
      }
    } else {
      throw Exception('Error al cargar los datos del laboratorio: ${response.statusCode}');
    }
  } catch (e) {
    debugPrint('Error al procesar los datos del laboratorio: $e');
    throw Exception('Error al procesar los datos del laboratorio: $e');
  }
}


 @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text(
        'Resultados de Laboratorio',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 1, 179, 45), // Verde
              Color.fromARGB(255, 0, 62, 143), // Azul
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
    ),
    body: FutureBuilder<List<Registro>>(
      future: registros,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text('No hay datos disponibles', style: TextStyle(fontSize: 18)),
          );
        } else {
          final registrosOrdenados = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: registrosOrdenados.length,
            itemBuilder: (context, index) {
              final registro = registrosOrdenados[index];
              return Card(
                elevation: 5,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ExpansionTile(
                  leading: const Icon(Icons.medical_services, color: Colors.blue),
                  title: Text('Orden: ${registro.orden}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Fecha: ${registro.fechaCreacion}', style: const TextStyle(fontSize: 14, color: Colors.grey)),
                  children: registro.items.map((item) {
                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ExpansionTile(
                        leading: const Icon(Icons.list, color: Colors.green),
                        title: Text(
                          item.examen,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('Área: ${item.area}', style: const TextStyle(color: Colors.grey)),
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Detalle del Examen: ',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.blueAccent),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                            child: Text('Examen: ${item.examen}', style: const TextStyle(fontSize: 14)),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                            child: Text('Área: ${item.area}', style: const TextStyle(fontSize: 14)),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                            child: Text('Resultados:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                          ),
                          ...item.resultados.map((resultado) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              child: ListTile(
                                leading: const Icon(Icons.check_circle_outline, color: Colors.blue),
                                title: Text(resultado.prueba, style: const TextStyle(fontSize: 16)),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Resultado: ${resultado.resultado ?? 'No disponible'}',
                                      style: const TextStyle(fontSize: 14, color: Colors.black54),
                                    ),
                                    if (resultado.unidad != null)
                                      Text(
                                        'Unidad: ${resultado.unidad}',
                                        style: const TextStyle(fontSize: 14, color: Colors.black45),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          );
        }
      },
    ),
  );
}


}

class Registro {
  int id;
  int orden;
  String tipo;
  String fechaCreacion;
  List<Item> items;

  Registro({
    required this.id,
    required this.orden,
    required this.tipo,
    required this.fechaCreacion,
    required this.items,
  });

  factory Registro.fromJson(Map<String, dynamic> json) {
    return Registro(
      id: json["id"] ?? 0,
      orden: json["orden"] ?? 0,
      tipo: json["tipo"] ?? "Desconocido",
      fechaCreacion: _formatFecha(json["fecha_creacion"] ?? ""),
      items: (json["items"] as List?)?.map((x) => Item.fromJson(x)).toList() ?? [],
    );
  }

  static String _formatFecha(String fechaOriginal) {
    try {
      final dateTime = DateTime.parse(fechaOriginal);
      return "${dateTime.toLocal().toString().split(' ')[0]} ${dateTime.toLocal().toString().split(' ')[1].substring(0, 5)}";
    } catch (e) {
      return fechaOriginal;
    }
  }
}

class Item {
  int id;
  String examen;
  String area;
  List<Resultado> resultados;

  Item({
    required this.id,
    required this.examen,
    required this.area,
    required this.resultados,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json["id"] ?? 0,
      examen: json["examen"] ?? "Sin examen",
      area: json["area"] ?? "Área desconocida",
      resultados: (json["resultados"] as List?)?.map((x) => Resultado.fromJson(x)).toList() ?? [],
    );
  }
}

class Resultado {
  int id;
  String prueba;
  String? resultado;
  String? unidad;

  Resultado({
    required this.id,
    required this.prueba,
    this.resultado,
    this.unidad,
  });

  factory Resultado.fromJson(Map<String, dynamic> json) {
    return Resultado(
      id: json["id"] ?? 0,
      prueba: json["prueba"] ?? "Prueba desconocida",
      resultado: json["resultado"],
      unidad: json["unidad"],
    );
  }
}
