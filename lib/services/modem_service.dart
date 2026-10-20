import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

enum ConexionModem { desconectado, conectando, conectado }

class EstadoModem {
  const EstadoModem({required this.conexion, this.bateria});

  final ConexionModem conexion;

  /// Porcentaje de batería reportado por STATUS; null si no lo reporta.
  final int? bateria;

  bool get conectado => conexion == ConexionModem.conectado;
}

/// Trama notificada por RX_FRAME junto con sus metadatos de radio.
class TramaRecibida {
  const TramaRecibida({
    required this.bytes,
    required this.rssi,
    required this.snr,
  });

  final Uint8List bytes;
  final int rssi;
  final double snr;
}

/// Servicio de conexión (SDS, nivel 3): contrato entre la app y el módem
/// ESP32 + SX1262 por BLE/GATT (SRS 3.1.2).
abstract class ModemService {
  ValueListenable<EstadoModem> get estado;

  /// Tramas recibidas por radio (característica RX_FRAME).
  Stream<TramaRecibida> get tramasRecibidas;

  Future<void> conectar();

  Future<void> desconectar();

  /// Escribe la trama en TX_FRAME. Completa con true cuando STATUS confirma
  /// que quedó encolada para transmisión; false si no hay conexión.
  Future<bool> enviar(Uint8List trama);

  void dispose();
}

/// Módem simulado para desarrollar y demostrar la app sin hardware.
///
/// Se sustituirá por una implementación con flutter_blue_plus cuando se
/// definan los UUID del servicio GATT en el documento de protocolo.
class ModemSimulado implements ModemService {
  final _estado = ValueNotifier(
    const EstadoModem(conexion: ConexionModem.desconectado),
  );
  final _rx = StreamController<TramaRecibida>.broadcast();
  final _rnd = Random();

  @override
  ValueListenable<EstadoModem> get estado => _estado;

  @override
  Stream<TramaRecibida> get tramasRecibidas => _rx.stream;

  @override
  Future<void> conectar() async {
    if (_estado.value.conectado) return;
    _estado.value = EstadoModem(
      conexion: ConexionModem.conectando,
      bateria: _estado.value.bateria,
    );
    await Future<void>.delayed(const Duration(milliseconds: 800));
    _estado.value = const EstadoModem(
      conexion: ConexionModem.conectado,
      bateria: 87,
    );
  }

  @override
  Future<void> desconectar() async {
    _estado.value = EstadoModem(
      conexion: ConexionModem.desconectado,
      bateria: _estado.value.bateria,
    );
  }

  @override
  Future<bool> enviar(Uint8List trama) async {
    if (!_estado.value.conectado) return false;
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return _estado.value.conectado;
  }

  /// Simula la llegada de una trama desde otro nodo de la red.
  void inyectar(Uint8List trama) {
    if (!_estado.value.conectado) return;
    _rx.add(
      TramaRecibida(
        bytes: trama,
        rssi: -70 - _rnd.nextInt(45),
        snr: 10 - _rnd.nextInt(18).toDouble(),
      ),
    );
  }

  @override
  void dispose() {
    _rx.close();
    _estado.dispose();
  }
}

/// Módem conectado por WebSocket a `tool/simulador_radio.dart`, que hace de
/// red de radio: permite inyectar tramas desde Postman y que varias
/// instancias de la app se escuchen entre sí.
class ModemPuente implements ModemService {
  ModemPuente(this.url);

  final Uri url;
  final _estado = ValueNotifier(
    const EstadoModem(conexion: ConexionModem.desconectado),
  );
  final _rx = StreamController<TramaRecibida>.broadcast();
  WebSocketChannel? _canal;

  @override
  ValueListenable<EstadoModem> get estado => _estado;

  @override
  Stream<TramaRecibida> get tramasRecibidas => _rx.stream;

  @override
  Future<void> conectar() async {
    if (_estado.value.conexion != ConexionModem.desconectado) return;
    _estado.value = const EstadoModem(conexion: ConexionModem.conectando);
    final canal = WebSocketChannel.connect(url);
    _canal = canal;
    try {
      await canal.ready;
    } catch (e) {
      debugPrint('No se pudo conectar al simulador en $url: $e');
      if (_canal == canal) _cerrado(canal);
      return;
    }
    if (_canal != canal) return;
    _estado.value = const EstadoModem(
      conexion: ConexionModem.conectado,
      bateria: 100,
    );
    canal.stream.listen(
      (mensaje) {
        final m = jsonDecode(mensaje as String) as Map<String, dynamic>;
        _rx.add(
          TramaRecibida(
            bytes: _deHex(m['hex'] as String),
            rssi: (m['rssi'] as num).toInt(),
            snr: (m['snr'] as num).toDouble(),
          ),
        );
      },
      onDone: () => _cerrado(canal),
      onError: (_) => _cerrado(canal),
    );
  }

  void _cerrado(WebSocketChannel canal) {
    if (_canal != canal) return;
    _canal = null;
    _estado.value = const EstadoModem(conexion: ConexionModem.desconectado);
  }

  @override
  Future<void> desconectar() async {
    final canal = _canal;
    if (canal == null) return;
    _cerrado(canal);
    await canal.sink.close();
  }

  @override
  Future<bool> enviar(Uint8List trama) async {
    final canal = _canal;
    if (canal == null || !_estado.value.conectado) return false;
    canal.sink.add(jsonEncode({'hex': _aHex(trama)}));
    return true;
  }

  static String _aHex(Uint8List b) =>
      b.map((x) => x.toRadixString(16).padLeft(2, '0')).join();

  static Uint8List _deHex(String hex) => Uint8List.fromList([
    for (var i = 0; i + 1 < hex.length; i += 2)
      int.parse(hex.substring(i, i + 2), radix: 16),
  ]);

  @override
  void dispose() {
    _canal?.sink.close();
    _rx.close();
    _estado.dispose();
  }
}
