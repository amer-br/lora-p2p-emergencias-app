import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/repositorios.dart';
import '../domain/atencion.dart';
import '../domain/modelos.dart';
import '../protocol/tramas.dart';
import '../services/modem_service.dart';

/// Procesador de alertas entrantes (SDS, nivel 3): valida y deduplica las
/// tramas que entrega el módem y las registra en la bitácora local.
///
/// Los acuses se guardan aunque su incidente aún no haya llegado (huérfanos,
/// RNF-2.6): el estado se calcula uniendo por Msg_ID al leer, así que se
/// aplican solos cuando llega el incidente.
class ProcesadorEntrante {
  ProcesadorEntrante({
    required ModemService modem,
    required IncidenteRepository incidentes,
    required AcuseRepository acuses,
    required SafetyCheckRepository safetyChecks,
  }) : _incidentes = incidentes,
       _acuses = acuses,
       _safetyChecks = safetyChecks {
    _sub = modem.tramasRecibidas.listen(_procesar);
  }

  final IncidenteRepository _incidentes;
  final AcuseRepository _acuses;
  final SafetyCheckRepository _safetyChecks;
  final _nuevos = StreamController<Incidente>.broadcast();
  final _acusesNuevos = StreamController<Acuse>.broadcast();
  late final StreamSubscription<TramaRecibida> _sub;

  /// Tramas descartadas por longitud, CRC o Type desconocido.
  int descartadas = 0;

  /// Incidentes recibidos por primera vez (para CU-03 A4).
  Stream<Incidente> get incidentesNuevos => _nuevos.stream;

  /// Acuses recibidos por primera vez (para avisar a quien pidió ayuda).
  Stream<Acuse> get acusesNuevos => _acusesNuevos.stream;

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
        case TramaAcuse t:
          final tipo = TipoAcuse.porTipo(t.tipo);
          if (tipo == null) return;
          final acuse = Acuse(
            msgId: t.msgId,
            senderId: t.senderId,
            tipo: tipo,
            refMsgId: t.refMsgId,
            horaEmisor: t.unixTime,
            horaRecepcionLocal: ahora,
            origen: Origen.recibido,
            rssi: recibida.rssi,
            snr: recibida.snr,
          );
          if (await _acuses.insertarSiNuevo(acuse)) _acusesNuevos.add(acuse);
        case TramaSafetyCheck t:
          // Se almacena para el censo de evacuación (CU-07, fuera del MVP).
          if (t.estado != EstadoSafety.aSalvo) return;
          await _safetyChecks.insertarSiNuevo(
            ReporteSafetyCheck(
              msgId: t.msgId,
              senderId: t.senderId,
              estado: t.estado,
              horaEmisor: t.unixTime,
              horaRecepcionLocal: ahora,
              origen: Origen.recibido,
            ),
          );
      }
    } catch (e) {
      debugPrint('Error al procesar trama entrante: $e');
    }
  }

  void dispose() {
    _sub.cancel();
    _nuevos.close();
    _acusesNuevos.close();
  }
}
