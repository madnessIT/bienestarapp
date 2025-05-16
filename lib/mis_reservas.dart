import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'expediente_provider.dart';
import 'reserva_card.dart'; // NUEVO archivo con el widget personalizado

class MisReservasPage extends StatefulWidget {
  const MisReservasPage({super.key});

  @override
  _MisReservasPageState createState() => _MisReservasPageState();
}

class _MisReservasPageState extends State<MisReservasPage> {
  List<dynamic> atenciones = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAtenciones();
  }

  Future<void> fetchAtenciones() async {
    try {
      final expedienteProvider = Provider.of<ExpedienteProvider>(context, listen: false);
      final idExpedienteClinico = expedienteProvider.expedienteclinicoId;

      final url = 'https://api.movil.cies.org.bo/historia_clinica/atenciones/$idExpedienteClinico/atenciones_por_paciente/?regional=03';
final response = await http.get(
  Uri.parse(url),
);


      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        data.sort((a, b) => (b['id'] as int).compareTo(a['id'] as int));

        final seen = <String>{};
        final List<dynamic> unicos = [];

        for (final atencion in data) {
          final servicio = atencion['servicio']?['descripcion'] ?? '';
          final turno = atencion['reserva']?['turno'] ?? {};
          final fecha = turno['fecha'] ?? '';
          final hora = turno['hora_inicio'] ?? '';
          final key = '$servicio|$fecha|$hora';

          if (!seen.contains(key)) {
            seen.add(key);
            unicos.add(atencion);
          }

          if (unicos.length == 3) break;
        }

        setState(() {
          atenciones = unicos;
          isLoading = false;
        });
      } else {
        throw Exception('Error al obtener las atenciones');
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Reservas', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.home, color: Colors.white),
            tooltip: 'Ir al menú de inicio',
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/menu_paciente');
            },
          ),
        ],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color.fromARGB(255, 1, 179, 45), Color.fromARGB(255, 0, 62, 143)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.teal))
          : atenciones.isEmpty
              ? const Center(
                  child: Text('No tienes reservas registradas.', style: TextStyle(fontSize: 18, color: Colors.grey)),
                )
              : ListView.builder(
                  itemCount: atenciones.length,
                 itemBuilder: (context, index) {
  return Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 600), // ajusta el ancho deseado
      child: ReservaCard(atencion: atenciones[index]),
    ),
  );
},

                ),
    );
  }
}
