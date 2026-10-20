import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/repositorios.dart';
import '../domain/categoria.dart';
import '../domain/modelos.dart';
import '../protocol/tramas.dart';
import '../services/modem_service.dart';
import '../services/ubicacion_service.dart';

enum ResultadoEnvio {
  /// El módem confirmó el encolado.
  enviado,

  /// Módem sin conexión: se enviará al reconectar.
  pendiente,

  /// No se pudo guardar en la base local; la trama no se envió.
  errorBaseDatos,

  /// Se excedió el límite de 6 reportes por minuto (RNF-4.3).
  limiteExcedido,
}

class ResultadoEmision {
  const ResultadoEmision(this.resultado, [this.incidente]);

  final ResultadoEnvio resultado;
  final Incidente? incidente;

  bool get sinUbicacion => incidente != null && !incidente!.tieneUbicacion;
}

/// Manejador de envío de mensajes (SDS, nivel 3): valida, serializa y
/// persiste lo que emite el usuario y lo entrega al módem.
class EnvioService {
  EnvioService({
    required this.senderId,
    required IncidenteRepository incidentes,
    required SafetyCheckRepository safetyChecks,
    required ModemService modem,
    required UbicacionService ubicacion,
  })  : _incidentes = incidentes,
        _safetyChecks = safetyChecks,
        _modem = modem,
        _ubicacion = ubicacion {
    _modem.estado.addListener(_alCambiarModem);
  }

  static const maxReportesPorMinuto = 6;

  final int senderId;
  final IncidenteRepository _incidentes;
  final SafetyCheckRepository _safetyChecks;
  final ModemService _modem;
  final UbicacionService _ubicacion;
  bool _reenviando = false;

  /// CU-01: redactar y emitir una alerta con categoría y texto corto.
  Future<ResultadoEmision> emitirAlerta(
    Categoria categoria,
    String texto, {
    required bool usarUbicacion,
  }) async {
    final pos = usarUbicacion ? await _ubicacion.posicionParaEnvio() : null;
    final incidente = _nuevoIncidente(categoria.tipo, texto.trim(), pos);
    try {
      await _incidentes.guardar(incidente);
    } catch (e) {
      debugPrint('Error al guardar alerta: $e');
      return const ResultadoEmision(ResultadoEnvio.errorBaseDatos);
    }
    return ResultadoEmision(await _transmitirIncidente(incidente), incidente);
  }

  /// CU-02: SOS de un toque, prioridad Rojo y sin texto.
  Future<ResultadoEmision> emitirSos() async {
    final pos = await _ubicacion.posicionParaEnvio();
    final incidente = _nuevoIncidente(tipoSos, '', pos);
    try {
      await _incidentes.guardar(incidente);
    } catch (e) {
      // E1: por ser crítico, el SOS se envía aunque falle la base local.
      debugPrint('Error al guardar SOS (se envía de todos modos): $e');
      final ok = await _modem.enviar(_tramaDe(incidente));
      return ResultadoEmision(
          ok ? ResultadoEnvio.enviado : ResultadoEnvio.pendiente, incidente);
    }
    return ResultadoEmision(await _transmitirIncidente(incidente), incidente);
  }

  /// CU-02 paso 2: retransmite la misma trama (mismo Msg_ID).
  Future<ResultadoEnvio> reenviar(Incidente incidente) =>
      _transmitirIncidente(incidente);

  /// CU-06: reporte "Estoy a salvo". Cada reenvío usa un Msg_ID nuevo (A1).
  Future<ResultadoEnvio> reportarASalvo() async {
    final haceUnMinuto = DateTime.now().subtract(const Duration(minutes: 1));
    if (await _safetyChecks.propiosDesde(haceUnMinuto) >= maxReportesPorMinuto) {
      return ResultadoEnvio.limiteExcedido;
    }
    final ahora = DateTime.now();
    final reporte = ReporteSafetyCheck(
      msgId: generarId32(),
      senderId: senderId,
      estado: EstadoSafety.aSalvo,
      horaEmisor: ahora.millisecondsSinceEpoch ~/ 1000,
      horaRecepcionLocal: ahora,
      origen: Origen.propio,
      estadoEnvio: EstadoEnvio.pendiente,
    );
    try {
      await _safetyChecks.guardar(reporte);
    } catch (e) {
      debugPrint('Error al guardar Safety Check: $e');
      return ResultadoEnvio.errorBaseDatos;
    }
    return _transmitirSafetyCheck(reporte);
  }

  /// Envía lo que quedó Pendiente mientras el módem estaba desconectado.
  Future<void> reenviarPendientes() async {
    if (_reenviando || !_modem.estado.value.conectado) return;
    _reenviando = true;
    try {
      for (final i in await _incidentes.pendientesPropios()) {
        await _transmitirIncidente(i);
      }
      for (final r in await _safetyChecks.pendientesPropios()) {
        await _transmitirSafetyCheck(r);
      }
    } finally {
      _reenviando = false;
    }
  }

  void _alCambiarModem() {
    if (_modem.estado.value.conectado) reenviarPendientes();
  }

  Incidente _nuevoIncidente(int tipo, String texto, Posicion? pos) {
    final ahora = DateTime.now();
    return Incidente(
      msgId: generarId32(),
      senderId: senderId,
      tipo: tipo,
      lat: pos?.lat,
      lon: pos?.lon,
      texto: texto,
      horaEmisor: ahora.millisecondsSinceEpoch ~/ 1000,
      horaRecepcionLocal: ahora,
      origen: Origen.propio,
      estadoEnvio: EstadoEnvio.pendiente,
    );
  }

  Uint8List _tramaDe(Incidente i) => CodecTramas.codificar(TramaAlerta(
        msgId: i.msgId,
        senderId: i.senderId,
        tipo: i.tipo,
        lat: i.lat,
        lon: i.lon,
        unixTime: i.horaEmisor,
        texto: i.texto,
      ));

  Future<ResultadoEnvio> _transmitirIncidente(Incidente i) async {
    if (!await _modem.enviar(_tramaDe(i))) return ResultadoEnvio.pendiente;
    await _incidentes.actualizarEstadoEnvio(i.msgId, EstadoEnvio.enviado);
    return ResultadoEnvio.enviado;
  }

  Future<ResultadoEnvio> _transmitirSafetyCheck(ReporteSafetyCheck r) async {
    final trama = CodecTramas.codificar(TramaSafetyCheck(
      msgId: r.msgId,
      senderId: r.senderId,
      estado: r.estado,
      unixTime: r.horaEmisor,
    ));
    if (!await _modem.enviar(trama)) return ResultadoEnvio.pendiente;
    await _safetyChecks.actualizarEstadoEnvio(r.msgId, EstadoEnvio.enviado);
    return ResultadoEnvio.enviado;
  }

  void dispose() => _modem.estado.removeListener(_alCambiarModem);
}
