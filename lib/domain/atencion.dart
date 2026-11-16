/// Acuses y ciclo de vida compartido de los incidentes (F6, CU-08 a CU-11).
///
/// El estado de atención no viaja por radio: cada nodo lo calcula a partir
/// del conjunto de acuses que conoce, sin importar su orden ni sus
/// duplicados, así que dos nodos con los mismos acuses siempre concuerdan
/// (RNF-2.2; SDS DD-05). Son las mismas reglas que aplica el panel
/// (PanelCampus/emergencias/servicios.py).
library;

import 'modelos.dart';

enum TipoAcuse {
  enCamino(0x02, 'Voy en camino'),
  llegue(0x03, 'Llegué'),
  resuelto(0x04, 'Resuelto');

  const TipoAcuse(this.tipo, this.etiqueta);

  /// Valor del campo Type de la trama (SDS 8.5).
  final int tipo;
  final String etiqueta;

  static TipoAcuse? porTipo(int tipo) {
    for (final t in values) {
      if (t.tipo == tipo) return t;
    }
    return null;
  }
}

class Acuse {
  const Acuse({
    required this.msgId,
    required this.senderId,
    required this.tipo,
    required this.refMsgId,
    required this.horaEmisor,
    required this.horaRecepcionLocal,
    required this.origen,
    this.estadoEnvio,
    this.rssi,
    this.snr,
  });

  final int msgId;
  final int senderId;
  final TipoAcuse tipo;

  /// Msg_ID del incidente al que se refiere. No es una referencia
  /// obligatoria: un acuse puede llegar antes que su incidente (RNF-2.6).
  final int refMsgId;

  /// Unix time reportado por el emisor; solo informativo.
  final int horaEmisor;
  final DateTime horaRecepcionLocal;
  final Origen origen;
  final EstadoEnvio? estadoEnvio;
  final int? rssi;
  final double? snr;

  Acuse copyWith({EstadoEnvio? estadoEnvio}) => Acuse(
    msgId: msgId,
    senderId: senderId,
    tipo: tipo,
    refMsgId: refMsgId,
    horaEmisor: horaEmisor,
    horaRecepcionLocal: horaRecepcionLocal,
    origen: origen,
    estadoEnvio: estadoEnvio ?? this.estadoEnvio,
    rssi: rssi,
    snr: snr,
  );
}

/// Estado consolidado de la atención de un incidente.
class AtencionIncidente {
  const AtencionIncidente({
    required this.estado,
    required this.enCamino,
    required this.enSitio,
    required this.historial,
  });

  static const sinAcuses = AtencionIncidente(
    estado: EstadoAtencion.emitido,
    enCamino: 0,
    enSitio: 0,
    historial: [],
  );

  final EstadoAtencion estado;

  /// Personas (Sender_ID distintos) cuyo acuse más avanzado es «en camino».
  final int enCamino;

  /// Personas cuyo acuse más avanzado es «llegué».
  final int enSitio;

  /// Acuses conocidos, del más reciente al más antiguo.
  final List<Acuse> historial;

  bool get resuelto => estado == EstadoAtencion.resuelto;

  /// Texto breve del estado, p. ej. «En asistencia · 2 en camino · 1 en el sitio».
  String get resumen {
    switch (estado) {
      case EstadoAtencion.emitido:
        return 'Emitido · Sin atención';
      case EstadoAtencion.resuelto:
        return 'Resuelto';
      case EstadoAtencion.enAsistencia:
        return [
          'En asistencia',
          if (enCamino > 0) '$enCamino en camino',
          if (enSitio > 0) '$enSitio en el sitio',
        ].join(' · ');
    }
  }
}

/// Calcula el estado de atención a partir de los acuses de un incidente.
///
/// Resuelto si hay al menos un acuse «resuelto» (estado terminal); En
/// asistencia si hay algún «en camino» o «llegué»; si no, Emitido. Cada
/// persona cuenta una sola vez, según su acuse más avanzado.
AtencionIncidente consolidarAtencion(Iterable<Acuse> acuses) {
  final lista =
      acuses.toList()
        ..sort((a, b) => b.horaRecepcionLocal.compareTo(a.horaRecepcionLocal));
  if (lista.isEmpty) return AtencionIncidente.sinAcuses;

  final masAvanzado = <int, TipoAcuse>{};
  var resuelto = false;
  for (final a in lista) {
    if (a.tipo == TipoAcuse.resuelto) {
      resuelto = true;
      continue;
    }
    final previo = masAvanzado[a.senderId];
    if (previo == null || a.tipo.tipo > previo.tipo) {
      masAvanzado[a.senderId] = a.tipo;
    }
  }
  final enCamino =
      masAvanzado.values.where((t) => t == TipoAcuse.enCamino).length;
  final enSitio = masAvanzado.values.where((t) => t == TipoAcuse.llegue).length;
  return AtencionIncidente(
    estado:
        resuelto
            ? EstadoAtencion.resuelto
            : masAvanzado.isEmpty
            ? EstadoAtencion.emitido
            : EstadoAtencion.enAsistencia,
    enCamino: enCamino,
    enSitio: enSitio,
    historial: lista,
  );
}

/// Agrupa los acuses por el incidente al que se refieren.
Map<int, AtencionIncidente> atencionPorIncidente(Iterable<Acuse> acuses) {
  final grupos = <int, List<Acuse>>{};
  for (final a in acuses) {
    (grupos[a.refMsgId] ??= []).add(a);
  }
  return grupos.map((ref, l) => MapEntry(ref, consolidarAtencion(l)));
}

/// CU-09: solo el emisor original o quien ya acusó «Llegué» puede resolver.
bool puedeResolver({
  required Incidente incidente,
  required int miSenderId,
  required Iterable<Acuse> acuses,
}) =>
    incidente.senderId == miSenderId ||
    acuses.any((a) => a.senderId == miSenderId && a.tipo == TipoAcuse.llegue);

/// A1 de CU-08: cada persona emite cada tipo de acuse una sola vez.
bool yaAcuso({
  required int miSenderId,
  required TipoAcuse tipo,
  required Iterable<Acuse> acuses,
}) => acuses.any((a) => a.senderId == miSenderId && a.tipo == tipo);
