// models/paciente.dart

class Paciente {
  final int id;
  final String nombres;
  final String paterno;
  final String materno;
  final String sexo;
  final String fechaNacimiento;
  final String documento;
  final int expedido;
  final String domicilio;
  final String nit;
  final String razonSocial;
  final String tipoDocumento;
  final ExpedienteClinico expedienteClinico;

  Paciente({
    required this.id,
    required this.nombres,
    required this.paterno,
    required this.materno,
    required this.sexo,
    required this.fechaNacimiento,
    required this.documento,
    required this.expedido,
    required this.domicilio,
    required this.nit,
    required this.razonSocial,
    required this.tipoDocumento,
    required this.expedienteClinico,
  });

  factory Paciente.fromJson(Map<String, dynamic> json) {
    return Paciente(
      id: json['id'],
      nombres: json['nombres'],
      paterno: json['paterno'],
      materno: json['materno'],
      sexo: json['sexo'],
      fechaNacimiento: json['fecha_nacimiento'],
      documento: json['documento'],
      expedido: json['expedido'] ?? 0,
      domicilio: json['domicilio'] ?? '',
      nit: json['nit'] ?? '',
      razonSocial: json['razon_social'] ?? '',
      tipoDocumento: json['tipo_documento'] ?? '',
      expedienteClinico: ExpedienteClinico.fromJson(json['expedienteclinico']),
    );
  }
}

class ExpedienteClinico {
  final int id;
  final int telefono;
  final String email;
  final int expedienteClinico;
  final int pinApp;
  final int regional;

  ExpedienteClinico({
    required this.id,
    required this.telefono,
    required this.email,
    required this.expedienteClinico,
    required this.pinApp,
    required this.regional,
  });

  factory ExpedienteClinico.fromJson(Map<String, dynamic> json) {
    return ExpedienteClinico(
      id: json['id'],
      telefono: json['telefono'] ?? 0,
      email: json['email'] ?? '',
      expedienteClinico: json['expediente_clinico'],
      pinApp: json['pin_app'],
      regional: json['regional'],
    );
  }
}
