import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'sucursal_provider.dart';
import 'servicio_provider.dart';
import 'expediente_provider.dart';
import 'download_helper.dart';

class PrefacturaPage extends StatefulWidget {
  const PrefacturaPage({super.key});

  @override
  State<PrefacturaPage> createState() => _PrefacturaPageState();
}

class _PrefacturaPageState extends State<PrefacturaPage> {
  bool _isGeneratingQR = false;

  Future<List<Map<String, dynamic>>> fetchPricesForCart(List<Map<String, dynamic>> carrito) async {
    List<Map<String, dynamic>> cartWithPrices = [];
    for (var item in carrito) {
      final servicioNombre = item['servicioNombre'];
      final regionalCodigo = item['sucursalCodigo'];
      
      final url = 'https://api.movil.cies.org.bo/administracion/servicios/all/?search=$servicioNombre&regional=$regionalCodigo';
      final headers = {"Content-Type": "application/json"};
      
      try {
        final response = await http.get(Uri.parse(url), headers: headers);
        if (response.statusCode == 200) {
          final List<dynamic> result = json.decode(response.body);
          if (result.isNotEmpty) {
            final selectedService = result.first;
            final precio = selectedService['precio'] is Map
                ? selectedService['precio']['precio']
                : selectedService['precio'];
            
            cartWithPrices.add({
              ...item,
              'precioFinal': precio,
              'codigo_backend': selectedService['codigo'],
            });
          } else {
            cartWithPrices.add({...item, 'precioFinal': 0, 'codigo_backend': item['servicioCodigo']});
          }
        } else {
          throw Exception('Error al cargar precio para $servicioNombre');
        }
      } catch (e) {
        cartWithPrices.add({...item, 'precioFinal': 0, 'codigo_backend': item['servicioCodigo']});
      }
    }
    return cartWithPrices;
  }

  @override
  Widget build(BuildContext context) {
    // Eliminamos la lectura de ModalRoute ya que usaremos el Provider

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

          final carrito = servicioProvider.serviciosCarrito;

          return FutureBuilder<List<Map<String, dynamic>>>(
            future: fetchPricesForCart(carrito),
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
                          ...servicios.map((item) => _buildServicioCard(
                                item,
                              )),
                          const SizedBox(height: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              ElevatedButton(
                                onPressed: _isGeneratingQR
                                    ? null
                                    : () async {
                                        setState(() {
                                          _isGeneratingQR = true;
                                        });
                                        final patientId = expedienteProvider.PatientId ?? 0;
                                        // Utilizaremos el id de la sucursal del primer elemento como regional principal (generalmente será la misma)
                                        final mainRegionalId = carrito.isNotEmpty ? carrito.first['sucursalId'] : sucursalProvider.id;
                                        final mainSucursalCodigo = carrito.isNotEmpty ? carrito.first['sucursalCodigo'] : sucursalProvider.codigo;

                                        List<Map<String, dynamic>> detalles = [];
                                        double montoTotal = 0;
                                        String glosaDescripcion = "";

                                        for (var item in servicios) {
                                          double precioItem = double.tryParse(item['precioFinal'].toString()) ?? 0;
                                          montoTotal += precioItem;
                                          glosaDescripcion += "${item['servicioNombre']} ";

                                          detalles.add({
                                            "cantidad": 1,
                                            "codigo": item['codigo_backend'],
                                            "descripcion": item['servicioNombre'],
                                            "precio": precioItem,
                                            "referencia": item['doctorId'],
                                            "es_emergencia": false,
                                            "turno": item['id'],
                                          });
                                        }

                                        final preFacturaPayload = {
                                          "paciente": patientId,
                                          "razon_social": razonSocialController.text,
                                          "nit": nitController.text,
                                          "sistema": "APP",
                                          "regional": mainRegionalId,
                                          "registrado_por": 2899,
                                          "detalle": detalles
                                        };

                                        //print('Payload pre-factura enviado: $preFacturaPayload');
                                        final preFacturaUrl = 'https://api.movil.cies.org.bo/facturacion/pre_factura/?regional=$mainSucursalCodigo';
                                        try {
                                          final preFacturaResponse = await http.post(
                                            Uri.parse(preFacturaUrl),
                                            headers: {
                                              "Content-Type": "application/json",
                                            },
                                            body: jsonEncode(preFacturaPayload),
                                          );

                                          if (preFacturaResponse.statusCode == 200 || preFacturaResponse.statusCode == 201) {
                                            final preFacturaData = jsonDecode(preFacturaResponse.body);

                                            final id = preFacturaData['id'];

                                            // --- Sección de generación de QR ---
                                            // Obtener valores dinámicos según sucursal
                                            String sucursal = mainSucursalCodigo;
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
                                                  ? "453015|TES SA API QR|8062|$glosaDescripcion"
                                                  : "453017|TES SA SATELITE API QR|8062|$glosaDescripcion",
                                              "monto": montoTotal,
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
                              const SizedBox(height: 12),
                              OutlinedButton.icon(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('Cancelar Reserva'),
                                        content: const Text('¿Estás seguro que deseas cancelar la reserva y volver al inicio? Todos los servicios seleccionados se perderán.'),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context); // Cerrar el diálogo
                                            },
                                            child: const Text('No, continuar'),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              Provider.of<ServicioProvider>(context, listen: false).limpiarCarrito();
                                              Navigator.popUntil(context, ModalRoute.withName('/menu_paciente'));
                                            },
                                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                            child: const Text('Sí, cancelar', style: TextStyle(color: Colors.white)),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                icon: const Icon(Icons.cancel),
                                label: const Text('Cancelar Reserva'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  foregroundColor: Colors.red,
                                  side: const BorderSide(color: Colors.red),
                                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ],
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

  Widget _buildServicioCard(Map<String, dynamic> item) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: const Color.fromARGB(255, 1, 179, 45).withValues(alpha: 0.1),
              child: const Icon(Icons.medical_services, color: Color.fromARGB(255, 1, 179, 45)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['servicioNombre'] ?? 'Servicio',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 0, 62, 143),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Médico: ${item['medico']}',
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                  ),
                  Text(
                    'Fecha: ${item['fecha']}',
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                  ),
                  Text(
                    'Hora: ${item['hora_inicio']} - ${item['hora_fin']}',
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                  ),
                  Text(
                    'Sucursal: ${item['sucursalDescripcion']}',
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 1, 179, 45).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${item['precioFinal'] ?? 0} BOB',
                      style: const TextStyle(
                        color: Color.fromARGB(255, 1, 179, 45),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
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
      final Uint8List imageData = base64Decode(widget.qrResponse['imagen']);
      await saveQRImage(imageData, context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
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

