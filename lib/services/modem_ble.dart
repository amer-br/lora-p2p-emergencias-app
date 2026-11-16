import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'gatt_modem.dart';
import 'modem_service.dart';

/// Servicio de conexión (SDS, DD-08) con el módem LilyGO T-Beam por BLE.
///
/// Busca un módem que anuncie el servicio de [UuidModem]: prefiere el último
/// al que se conectó este teléfono y, si no lo encuentra, toma el primero que
/// aparezca y lo recuerda. El firmware acepta un solo teléfono a la vez, así
/// que un módem en uso no aparece en la búsqueda.
///
/// Mientras la app quiera estar conectada (después de [conectar] y hasta
/// [desconectar]), reintenta cada [esperaReintento] si no encuentra el módem o
/// si se pierde el enlace (RNF-2.4: reconexión en ≤ 10 s).
class ModemBle implements ModemService {
  ModemBle(this._prefs);

  static const _claveUltimoModem = 'modem_ble_id';
  static const tiempoBusqueda = Duration(seconds: 8);
  static const tiempoConexion = Duration(seconds: 10);
  static const esperaReintento = Duration(seconds: 3);

  /// Tiempo máximo para que STATUS confirme que la trama quedó encolada.
  static const tiempoConfirmacion = Duration(seconds: 2);

  static final _servicio = Guid(UuidModem.servicio);
  static final _txFrame = Guid(UuidModem.txFrame);
  static final _rxFrame = Guid(UuidModem.rxFrame);
  static final _statusGuid = Guid(UuidModem.status);

  final SharedPreferences _prefs;
  final _estado = ValueNotifier(
    const EstadoModem(conexion: ConexionModem.desconectado),
  );
  final _rx = StreamController<TramaRecibida>.broadcast();
  final _statusRecibido = StreamController<EstadoGattModem>.broadcast();

  BluetoothDevice? _dispositivo;
  BluetoothCharacteristic? _tx;
  final _suscripciones = <StreamSubscription<Object?>>[];
  Timer? _reintento;
  bool _deseado = false;
  bool _cerrado = false;
  int? _bateria;

  @override
  ValueListenable<EstadoModem> get estado => _estado;

  @override
  Stream<TramaRecibida> get tramasRecibidas => _rx.stream;

  @override
  Future<void> conectar() async {
    _deseado = true;
    _reintento?.cancel();
    if (_cerrado || _estado.value.conexion != ConexionModem.desconectado) {
      return;
    }
    _ponerEstado(ConexionModem.conectando);
    try {
      final dispositivo = await _buscar();
      if (dispositivo == null) {
        throw StateError('No se encontró ningún módem LoRa cercano');
      }
      await _enlazar(dispositivo);
      _ponerEstado(ConexionModem.conectado);
    } catch (e) {
      debugPrint('Módem BLE: $e');
      await _soltar();
      _ponerEstado(ConexionModem.desconectado);
      _programarReintento();
    }
  }

  @override
  Future<void> desconectar() async {
    _deseado = false;
    _reintento?.cancel();
    await _soltar();
    _ponerEstado(ConexionModem.desconectado);
  }

  @override
  Future<bool> enviar(Uint8List trama) async {
    final tx = _tx;
    final msgId = msgIdDe(trama);
    if (tx == null || msgId == null || !_estado.value.conectado) return false;

    // Se escucha STATUS antes de escribir para no perder una confirmación rápida.
    final confirmacion = _statusRecibido.stream
        .firstWhere((s) => s.ultimoMsgId == msgId)
        .timeout(tiempoConfirmacion);
    confirmacion.ignore(); // el error, si lo hay, se atiende abajo
    try {
      await tx.write(trama, withoutResponse: false);
      final estado = await confirmacion;
      if (estado.resultado != ResultadoEncolado.encolada) {
        debugPrint(
          'Módem BLE: la trama no se encoló (${estado.resultado.name})',
        );
      }
      return estado.resultado == ResultadoEncolado.encolada;
    } catch (e) {
      // Si la confirmación no llega, la trama queda Pendiente y se reenvía
      // con el mismo Msg_ID; la red descarta el duplicado si sí salió.
      debugPrint('Módem BLE: no se confirmó el envío: $e');
      return false;
    }
  }

  Future<BluetoothDevice?> _buscar() async {
    if (!await FlutterBluePlus.isSupported) {
      throw UnsupportedError('Este teléfono no tiene Bluetooth LE');
    }
    await FlutterBluePlus.adapterState
        .where((s) => s == BluetoothAdapterState.on)
        .first
        .timeout(
          const Duration(seconds: 5),
          onTimeout: () => throw StateError('El Bluetooth está apagado'),
        );

    final preferido = _prefs.getString(_claveUltimoModem);
    final encontrado = Completer<BluetoothDevice?>();
    BluetoothDevice? primero;
    final sub = FlutterBluePlus.onScanResults.listen((resultados) {
      for (final r in resultados) {
        primero ??= r.device;
        if (preferido == null || r.device.remoteId.str == preferido) {
          if (!encontrado.isCompleted) encontrado.complete(r.device);
        }
      }
    });
    try {
      await FlutterBluePlus.startScan(
        withServices: [_servicio],
        timeout: tiempoBusqueda,
      );
      final fin = FlutterBluePlus.isScanning.where((s) => !s).first;
      await Future.any([encontrado.future, fin]);
    } finally {
      await sub.cancel();
      await FlutterBluePlus.stopScan();
    }
    // Si el módem recordado no apareció, se usa el primero que haya.
    if (encontrado.isCompleted) return encontrado.future;
    return primero;
  }

  Future<void> _enlazar(BluetoothDevice d) async {
    // En Android, connect() negocia un MTU de 512: una trama de 56 B con sus
    // 3 B de metadatos no cabe en los 20 B útiles por omisión.
    await d.connect(timeout: tiempoConexion);
    _dispositivo = d;

    final servicios = await d.discoverServices();
    final servicio = servicios.firstWhere(
      (s) => s.uuid == _servicio,
      orElse: () => throw StateError('El dispositivo no es un módem LoRa'),
    );
    BluetoothCharacteristic caracteristica(Guid uuid) =>
        servicio.characteristics.firstWhere(
          (c) => c.uuid == uuid,
          orElse: () => throw StateError('Falta la característica $uuid'),
        );
    final tx = caracteristica(_txFrame);
    final rx = caracteristica(_rxFrame);
    final status = caracteristica(_statusGuid);

    _suscripciones
      ..add(rx.onValueReceived.listen(_alRecibirTrama))
      ..add(status.onValueReceived.listen(_alRecibirStatus))
      ..add(
        d.connectionState.listen((s) {
          if (s == BluetoothConnectionState.disconnected) _alPerderEnlace();
        }),
      );
    await rx.setNotifyValue(true);
    await status.setNotifyValue(true);
    _alRecibirStatus(await status.read());

    _tx = tx;
    await _prefs.setString(_claveUltimoModem, d.remoteId.str);
    debugPrint('Módem BLE conectado: ${d.platformName} (${d.remoteId})');
  }

  void _alRecibirTrama(List<int> valor) {
    final trama = decodificarRxFrame(valor);
    if (trama != null && !_rx.isClosed) _rx.add(trama);
  }

  void _alRecibirStatus(List<int> valor) {
    final status = EstadoGattModem.decodificar(valor);
    if (status == null) return;
    if (!_statusRecibido.isClosed) _statusRecibido.add(status);
    if (status.bateria != _bateria) {
      _bateria = status.bateria;
      _ponerEstado(_estado.value.conexion);
    }
  }

  void _alPerderEnlace() {
    if (_tx == null) return; // aún no terminaba de enlazar
    debugPrint('Módem BLE: se perdió el enlace');
    _soltar().then((_) {
      _ponerEstado(ConexionModem.desconectado);
      _programarReintento();
    });
  }

  void _programarReintento() {
    if (!_deseado || _cerrado) return;
    _reintento?.cancel();
    _reintento = Timer(esperaReintento, conectar);
  }

  Future<void> _soltar() async {
    _tx = null;
    for (final s in _suscripciones) {
      await s.cancel();
    }
    _suscripciones.clear();
    final d = _dispositivo;
    _dispositivo = null;
    if (d != null) {
      try {
        await d.disconnect();
      } catch (_) {
        // Ya estaba desconectado.
      }
    }
  }

  void _ponerEstado(ConexionModem conexion) {
    if (_cerrado) return;
    _estado.value = EstadoModem(conexion: conexion, bateria: _bateria);
  }

  @override
  void dispose() {
    _cerrado = true;
    _reintento?.cancel();
    _soltar();
    _rx.close();
    _statusRecibido.close();
    _estado.dispose();
  }
}
