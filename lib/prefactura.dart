import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'sucursal_provider.dart';
import 'servicio_provider.dart';
import 'expediente_provider.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;


// Importación condicional para la descarga:
// En web se utilizará download_helper_web.dart, y en Android u otras, download_helper_mobile.dart.
import 'download_helper_mobile.dart'
    if (dart.library.html) 'download_helper_web.dart';

class PrefacturaPage extends StatefulWidget {
  const PrefacturaPage({super.key});

  @override
  State<PrefacturaPage> createState() => _PrefacturaPageState();
}

class _PrefacturaPageState extends State<PrefacturaPage> {
  bool _isGeneratingQR = false;

  Future<List<dynamic>> fetchServicios(String servicioNombre, String regionalCodigo) async {
    final url =
      //'http://test.api.movil.cies.org.bo/administracion/servicios/all/?search=$servicioNombre&regional=$regionalCodigo';
      'https://api.movil.cies.org.bo/administracion/servicios/all/?search=$servicioNombre&regional=$regionalCodigo';
    final headers = {
      //"regional": regionalCodigo,  // Comentado
      "Content-Type": "application/json",
    };
    final response = await http.get(Uri.parse(url), headers: headers);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al cargar los servicios: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? turnoSeleccionado =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    final medico = turnoSeleccionado?['medico'] ?? 'No disponible';
    final fecha = turnoSeleccionado?['fecha'] ?? 'No disponible';
    final horaInicio = turnoSeleccionado?['hora_inicio'] ?? 'No disponible';
    final horaFin = turnoSeleccionado?['hora_fin'] ?? 'No disponible';
    final id = turnoSeleccionado?['id'] ?? 'No disponible';
    final doctorId = turnoSeleccionado?['doctorId'] ?? 'No disponible';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Datos de la cita',
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
      body: Consumer3<SucursalProvider, ServicioProvider, ExpedienteProvider>(
        builder: (context, sucursalProvider, servicioProvider, expedienteProvider, child) {
          final nitController = TextEditingController(
            text: expedienteProvider.nit ?? 'No asignado',
          );
          final razonSocialController = TextEditingController(
            text: expedienteProvider.razonSocial ?? 'No asignado',
          );

          return FutureBuilder<List<dynamic>>(
            future: fetchServicios(servicioProvider.servicioNombre, sucursalProvider.codigo),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No se encontraron servicios.'));
              } else {
                final servicios = snapshot.data!;
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle(context, 'Datos para factura:'),
                          TextField(
                            controller: nitController,
                            decoration: const InputDecoration(
                              labelText: 'NIT',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: razonSocialController,
                            decoration: const InputDecoration(
                              labelText: 'Razón Social',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 24),
                          _buildSectionTitle(context, 'Datos Para la Reserva:'),
                          ...servicios.map((servicio) => _buildServicioCard(
                                servicio,
                                fecha,
                                horaInicio,
                                horaFin,
                                medico,
                                sucursalProvider.descripcion,
                              )),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _isGeneratingQR
                                ? null
                                : () async {
                                    setState(() {
                                      _isGeneratingQR = true;
                                    });
                                    final selectedService = servicios.first;
                                    final patientId = expedienteProvider.PatientId ?? 0;
                                    //print('Código de sucursal: ${sucursalProvider.codigo}');

                                    final preFacturaPayload = {
                                      "paciente": patientId,
                                      "razon_social": razonSocialController.text,
                                      "nit": nitController.text,
                                      "sistema": "APP",
                                      "regional": sucursalProvider.id,
                                      "registrado_por": 2899,
                                      "detalle": [
                                        {
                                          "cantidad": 1,
                                          "codigo": servicioProvider.servicioCodigo,
                                          "descripcion": servicioProvider.servicioNombre,
                                          "precio": selectedService['precio'] is Map
                                              ? selectedService['precio']['precio']
                                              : selectedService['precio'],
                                          "referencia": doctorId,
                                          "es_emergencia": false,
                                          "turno": id,
                                        }
                                      ]
                                    };

                                    //print('Payload pre-factura enviado: $preFacturaPayload');
                                    //final preFacturaUrl = 'http://test.api.movil.cies.org.bo/facturacion/pre_factura/?regional=${sucursalProvider.codigo}';
                                    final preFacturaUrl = 'https://api.movil.cies.org.bo/facturacion/pre_factura/?regional=${sucursalProvider.codigo}';
                                    try {
                                      final preFacturaResponse = await http.post(
                                        Uri.parse(preFacturaUrl),
                                        headers: {
                                          "Content-Type": "application/json",
                                          //"regional": sucursalProvider.codigo,
                                        },
                                        body: jsonEncode(preFacturaPayload),
                                      );

                                     // print('Respuesta de pre-factura: ${preFacturaResponse.body}');

                                      if (preFacturaResponse.statusCode == 200 || preFacturaResponse.statusCode == 201) {
                                        final preFacturaData = jsonDecode(preFacturaResponse.body);

                                        final id = preFacturaData['id'];
                                        final descripcion = preFacturaData['descripcion'] ?? servicioProvider.servicioNombre;
                                        final codigo = selectedService['codigo'];
                                        final precio = selectedService['precio'] is Map
                                            ? selectedService['precio']['precio']
                                            : selectedService['precio'];

                                        // --- Sección de generación de QR ---
                                        // Obtener valores dinámicos según sucursal
                                        String sucursal = sucursalProvider.codigo;
                                        int regional = sucursal == "03" ? 8 : sucursal == "14" ? 9 : 0;

                                        if (regional == 0) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Sucursal no válida para generación de QR')),
                                          );
                                          return;
                                        }

                                        // Crear payload según el regional
                                        final qrPayload = {
                                          "numeroReferencia": id,
                                          "glosa": regional == 8
                                              ? "453015|TES SA API QR|8062|$descripcion $codigo"
                                              : "453017|TES SA SATELITE API QR|8062|$descripcion $codigo",
                                          "monto": precio,
                                          "moneda": "BOB",
                                          "canal": "APP",
                                          "tiempoQr": "00:10:00"
                                        };

                                        // Imprimir el contenido de qrPayload
                                         // print('Payload QR generado: $qrPayload');

                                        // Construir URL del endpoint con regional y sucursal
                                        final qrUrl =
                                            //'http://test.api.movil.cies.org.bo/generarQR/?regional=$regional&sucursal=$sucursal';
                                            'https://api.movil.cies.org.bo/generarQR/?regional=$regional&sucursal=$sucursal';

                                        // Enviar solicitud POST
                                        final qrResponse = await http.post(
                                          Uri.parse(qrUrl),
                                          headers: {
                                            "Content-Type": "application/json",
                                          },
                                          body: jsonEncode(qrPayload),
                                        );

                                        //print('Respuesta de QR: ${qrResponse.body}');

                                        if (qrResponse.statusCode == 200) {
                                          // Navegar a QRResponsePage con datos
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => QRResponsePage(
                                                qrResponse: jsonDecode(qrResponse.body),
                                                sucursal: sucursal,
                                                regional: regional,
                                              ),
                                            ),
                                          );
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Error al generar el código QR')),
                                          );
                                        }
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Error al generar la pre-factura')),
                                        );
                                      }
                                    } catch (e) {
                                      print('Excepción en pre-factura: $e');
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Excepción: $e')),
                                      );
                                    } finally {
                                      if (mounted) {
                                        setState(() {
                                          _isGeneratingQR = false;
                                        });
                                      }
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              backgroundColor: const Color.fromARGB(255, 1, 179, 45),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: _isGeneratingQR
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('Continuar'),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildServicioCard(Map<String, dynamic> servicio, String fecha, String horaInicio, String horaFin, String medico, String sucursalDescripcion) {
    final precio = servicio['precio'] ?? 'No disponible';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        elevation: 3,
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Sucursal: $sucursalDescripcion', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('${servicio['nombre']}', style: const TextStyle(fontWeight: FontWeight.bold)),
              Text('Precio: ${precio['precio']} Bs.'),
              Text('Médico: $medico'),
              Text('Fecha: $fecha'),
              Text('Hora: $horaInicio - $horaFin'),
            ],
          ),
        ),
      ),
    );
  }
}

class QRResponsePage extends StatefulWidget {
  final Map<String, dynamic> qrResponse;
  final String sucursal;
  final int regional;

  const QRResponsePage({
    super.key,
    required this.qrResponse,
    required this.sucursal,
    required this.regional,
  });

  @override
  State<QRResponsePage> createState() => _QRResponsePageState();
}

class _QRResponsePageState extends State<QRResponsePage> {
  final GlobalKey _qrKey = GlobalKey();

  Future<void> _captureAndDownloadQR() async {
    try {
      RenderRepaintBoundary boundary =
          _qrKey.currentContext?.findRenderObject() as RenderRepaintBoundary;

      if (boundary.debugNeedsPaint) {
        await Future.delayed(const Duration(milliseconds: 20));
        return _captureAndDownloadQR(); // Espera a que termine el render
      }

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();
      await downloadImage(bytes);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('QR descargado correctamente')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al descargar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final String imagenBase64 = widget.qrResponse['imagen'];
    final Uint8List imageBytes = base64Decode(imagenBase64);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.regional == 8
              ? 'QR CLINICA BIENESTAR Central'
              : widget.regional == 9
                  ? 'QR BIENESTAR Satélite'
                  : 'QR generado',
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  RepaintBoundary(
                    key: _qrKey,
                    child: Image.memory(imageBytes),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Sucursal: ${widget.sucursal} | Regional: ${widget.regional}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  TextButton.icon(
                    onPressed: _captureAndDownloadQR,
                    icon: const Icon(Icons.download),
                    label: const Text('Descargar imagen QR'),
                  ),
                  const SizedBox(height: 16),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/mis_atenciones_medicas');
                    },
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Ir a mis Atenciones Médicas'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

