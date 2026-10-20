import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/repositorios.dart';
import '../domain/modelos.dart';
import '../protocol/tramas.dart';
import '../services/modem_service.dart';

/// Procesador de alertas entrantes (SDS, nivel 3): valida y deduplica las
/// tramas que entrega el módem y las registra en la bitácora local.
class ProcesadorEntrante {
  ProcesadorEntrante({
    required ModemService modem,
    required IncidenteRepository incidentes,
    required SafetyCheckRepository safetyChecks,
  })  : _incidentes = incidentes,
        _safetyChecks = safetyChecks {
    _sub = modem.tramasRecibidas.listen(_procesar);
  }

  final IncidenteRepository _incidentes;
  final SafetyCheckRepository _safetyChecks;
  final _nuevos = StreamController<Incidente>.broadcast();
  late final StreamSubscription<TramaRecibida> _sub;

  /// Tramas descartadas por longitud, CRC o Type desconocido.
  int descartadas = 0;

  /// Incidentes recibidos por primera vez (para CU-03 A4).
  Stream<Incidente> get incidentesNuevos => _nuevos.stream;

  Future<void> _procesar(TramaRecibida recibida) async {
    final trama = CodecTramas.decodificar(recibida.bytes);
    final ahora = DateTime.now();
    try {
      switch (trama) {
        case null:
          descartadas++;
        case TramaAlerta t:
          final incidente = Incidente(
            msgId: t.msgId,
            senderId: t.senderId,
            tipo: t.tipo,
            lat: t.lat,
            lon: t.lon,
            texto: t.texto,
            horaEmisor: t.unixTime,
            horaRecepcionLocal: ahora,
            origen: Origen.recibido,
          );
          if (await _incidentes.insertarSiNuevo(incidente)) {
            _nuevos.add(incidente);
          }
        case TramaSafetyCheck t:
          // Se almacena para el censo de evacuación (CU-07, fuera del MVP).
          if (t.estado != EstadoSafety.aSalvo) return;
          await _safetyChecks.insertarSiNuevo(ReporteSafetyCheck(
            msgId: t.msgId,
            senderId: t.senderId,
            estado: t.estado,
            horaEmisor: t.unixTime,
            horaRecepcionLocal: ahora,
            origen: Origen.recibido,
          ));
      }
    } catch (e) {
      debugPrint('Error al procesar trama entrante: $e');
    }
  }

  void dispose() {
    _sub.cancel();
    _nuevos.close();
  }
}
