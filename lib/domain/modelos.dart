import 'categoria.dart';

/// Sender_ID fijo del panel de coordinación (SRS, supuesto S9). Debe
/// coincidir con `PANEL_SENDER_ID` del panel; se cambia con
/// `--dart-define=PANEL_SENDER_ID=0000CA0A` (hexadecimal).
final int senderIdPanel = int.parse(
  const String.fromEnvironment('PANEL_SENDER_ID', defaultValue: '0000CA0A'),
  radix: 16,
);

/// Origen de un registro local (SDS, Figura 4).
enum Origen { propio, recibido }

/// Estado de envío; solo aplica a registros propios.
enum EstadoEnvio { pendiente, enviado, error }

/// Estado consolidado de atención de un incidente (SRS 3.2). Se calcula con
/// `consolidarAtencion` (domain/atencion.dart) a partir de los acuses.
enum EstadoAtencion { emitido, enAsistencia, resuelto }

/// Estado transmitido en una trama Safety Check.
abstract final class EstadoSafety {
  static const aSalvo = 0x01;
}

class Posicion {
  const Posicion({
    required this.lat,
    required this.lon,
    required this.hora,
    this.precisionM,
  });

  final double lat;
  final double lon;
  final DateTime hora;
  final double? precisionM;
}

class Incidente {
  const Incidente({
    required this.msgId,
    required this.senderId,
    required this.tipo,
    required this.texto,
    required this.horaEmisor,
    required this.horaRecepcionLocal,
    required this.origen,
    this.lat,
    this.lon,
    this.estadoEnvio,
  });

  final int msgId;
  final int senderId;
  final int tipo;
  final double? lat;
  final double? lon;
  final String texto;

  /// Unix time reportado por el emisor; solo informativo (SRS S4).
  final int horaEmisor;

  /// Hora local de recepción/creación; se usa para antigüedad y orden.
  final DateTime horaRecepcionLocal;
  final Origen origen;
  final EstadoEnvio? estadoEnvio;

  Categoria? get categoria => Categorias.porTipo(tipo);

  /// CU-18: alerta difundida por el panel del puesto de mando.
  bool get esAviso => senderId == senderIdPanel;
  bool get esSos => tipo == tipoSos;
  bool get tieneUbicacion => lat != null && lon != null;
  Prioridad get prioridad => categoria?.prioridad ?? Prioridad.verde;

  Incidente copyWith({EstadoEnvio? estadoEnvio}) => Incidente(
    msgId: msgId,
    senderId: senderId,
    tipo: tipo,
    lat: lat,
    lon: lon,
    texto: texto,
    horaEmisor: horaEmisor,
    horaRecepcionLocal: horaRecepcionLocal,
    origen: origen,
    estadoEnvio: estadoEnvio ?? this.estadoEnvio,
  );
}

class ReporteSafetyCheck {
  const ReporteSafetyCheck({
    required this.msgId,
    required this.senderId,
    required this.estado,
    required this.horaEmisor,
    required this.horaRecepcionLocal,
    required this.origen,
    this.estadoEnvio,
  });

  final int msgId;
  final int senderId;
  final int estado;
  final int horaEmisor;
  final DateTime horaRecepcionLocal;
  final Origen origen;
  final EstadoEnvio? estadoEnvio;
}

enum TipoRecurso {
  puntoReunion('PUNTO_REUNION', 'Punto de reunión'),
  refugio('REFUGIO', 'Refugio'),
  salidaEvacuacion('SALIDA_EVACUACION', 'Salida de evacuación'),
  botiquin('BOTIQUIN', 'Botiquín'),
  dea('DEA', 'DEA');

  const TipoRecurso(this.codigo, this.nombre);

  final String codigo;
  final String nombre;

  static TipoRecurso? porCodigo(String codigo) {
    for (final t in values) {
      if (t.codigo == codigo) return t;
    }
    return null;
  }
}

class RecursoMapa {
  const RecursoMapa({
    required this.id,
    required this.tipo,
    required this.nombre,
    required this.lat,
    required this.lon,
    required this.fechaActualizacion,
    this.descripcion,
  });

  final int id;
  final TipoRecurso tipo;
  final String nombre;
  final String? descripcion;
  final double lat;
  final double lon;
  final DateTime fechaActualizacion;
}

class ProtocoloAuxilio {
  const ProtocoloAuxilio({
    required this.id,
    required this.titulo,
    required this.categoria,
    required this.icono,
    required this.pasos,
    this.advertencias,
  });

  final String id;
  final String titulo;
  final String categoria;
  final String icono;
  final List<String> pasos;
  final String? advertencias;

  /// Un protocolo sin pasos se considera dañado (CU-04 E1).
  bool get valido => pasos.isNotEmpty;
}
