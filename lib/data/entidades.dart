import 'package:isar_community/isar.dart';

import '../domain/modelos.dart';

part 'entidades.g.dart';

/// Colecciones Isar (SDS, Figura 4). Se mantienen separadas de los modelos
/// de dominio para que la lógica de negocio no dependa de la base de datos.

@collection
class IncidenteEntity {
  /// Msg_ID (uint32) usado como Id de Isar: deduplica de forma natural.
  Id msgId = 0;
  late int senderId;
  late int tipo;
  double? lat;
  double? lon;

  /// No aparece en el diagrama ER, pero es necesario para mostrar el mensaje.
  late String texto;
  late int horaEmisor;
  @Index()
  late DateTime horaRecepcionLocal;
  @enumerated
  late Origen origen;
  @Enumerated(EnumType.ordinal32)
  EstadoEnvio? estadoEnvio;
}

/// Acuses propios y recibidos (SDS 8.1). Se relacionan con su incidente por
/// refMsgId y no por un enlace obligatorio, para poder guardar un acuse que
/// llega antes que su incidente (RNF-2.6).
@collection
class AcuseEntity {
  Id msgId = 0;
  late int senderId;
  late int tipo;
  @Index()
  late int refMsgId;
  late int horaEmisor;
  @Index()
  late DateTime horaRecepcionLocal;
  @enumerated
  late Origen origen;
  @Enumerated(EnumType.ordinal32)
  EstadoEnvio? estadoEnvio;
  int? rssi;
  double? snr;
}

@collection
class SafetyCheckEntity {
  Id msgId = 0;
  @Index()
  late int senderId;
  late int estado;
  late int horaEmisor;
  @Index()
  late DateTime horaRecepcionLocal;
  @enumerated
  late Origen origen;
  @Enumerated(EnumType.ordinal32)
  EstadoEnvio? estadoEnvio;
}

@collection
class RecursoEntity {
  Id id = Isar.autoIncrement;
  @enumerated
  late TipoRecurso tipo;
  late String nombre;
  String? descripcion;
  late double lat;
  late double lon;
  late DateTime fechaActualizacion;
}
