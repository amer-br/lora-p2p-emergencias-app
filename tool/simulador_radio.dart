/// Simulador de la red de radio LoRa para pruebas sin hardware.
///
/// Las apps se conectan por WebSocket en /ws (ModemPuente) y lo que una
/// transmite les llega a las demás, como si estuvieran al alcance de radio.
/// Por HTTP (Postman, curl) se pueden inyectar tramas y consultar las que
/// emitieron las apps.
///
///   dart run tool/simulador_radio.dart [puerto]
///
/// Endpoints:
///   GET  /estado          apps conectadas y tramas registradas
///   GET  /enviadas        tramas transmitidas por las apps (decodificadas)
///   DELETE /enviadas      borra el registro
///   POST /alerta          {categoria|tipo, lat, lon, texto, ttl, msgId, senderId, rssi, snr}
///   POST /safety-check    {estado, ttl, msgId, senderId, rssi, snr}
///   POST /trama           {hex, rssi, snr}  bytes crudos (p. ej. con CRC inválido)
// ignore_for_file: avoid_print
library;

import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:aplicacion/domain/categoria.dart';
import 'package:aplicacion/domain/modelos.dart';
import 'package:aplicacion/protocol/tramas.dart';

/// Centro del campus (mismo valor que lib/app_scope.dart).
const _latCentro = (22.77481 + 22.76790) / 2;
const _lonCentro = (-102.64876 + -102.63754) / 2;

final _rnd = Random();
final _apps = <WebSocket>{};
final _enviadas = <Map<String, Object?>>[];

Future<void> main(List<String> args) async {
  final puerto = args.isNotEmpty ? int.parse(args.first) : 8080;
  final servidor = await HttpServer.bind(InternetAddress.anyIPv4, puerto);
  print(
    'Simulador de radio en http://localhost:$puerto  (WebSocket: ws://localhost:$puerto/ws)',
  );
  await for (final req in servidor) {
    _cors(req.response);
    try {
      await _atender(req);
    } on FormatException catch (e) {
      await _json(req, {'error': e.message}, HttpStatus.badRequest);
    } on ArgumentError catch (e) {
      await _json(req, {'error': '${e.message}'}, HttpStatus.badRequest);
    } catch (e) {
      await _json(req, {'error': '$e'}, HttpStatus.internalServerError);
    }
  }
}

Future<void> _atender(HttpRequest req) async {
  final ruta = '${req.method} ${req.uri.path}';
  switch (ruta) {
    case 'GET /ws':
      _registrarApp(await WebSocketTransformer.upgrade(req));
    case 'OPTIONS /alerta' ||
        'OPTIONS /safety-check' ||
        'OPTIONS /trama' ||
        'OPTIONS /enviadas':
      await req.response.close();
    case 'GET /estado':
      await _json(req, {
        'appsConectadas': _apps.length,
        'tramasEnviadas': _enviadas.length,
      });
    case 'GET /enviadas':
      await _json(req, _enviadas);
    case 'DELETE /enviadas':
      _enviadas.clear();
      await _json(req, {'ok': true});
    case 'POST /alerta':
      final c = await _cuerpo(req);
      final tipo = _tipoDe(c);
      final trama = TramaAlerta(
        msgId: _int(c['msgId']) ?? generarId32(),
        senderId: _int(c['senderId']) ?? generarId32(),
        tipo: tipo,
        lat:
            (c['lat'] as num?)?.toDouble() ??
            _latCentro + (_rnd.nextDouble() - 0.5) * 0.004,
        lon:
            (c['lon'] as num?)?.toDouble() ??
            _lonCentro + (_rnd.nextDouble() - 0.5) * 0.004,
        unixTime: _int(c['unixTime']) ?? _ahora(),
        texto: c['texto'] as String? ?? '',
        ttl: _int(c['ttl']) ?? ttlMax - 1,
      );
      await _difundirDesdePostman(req, CodecTramas.codificar(trama), c);
    case 'POST /safety-check':
      final c = await _cuerpo(req);
      final trama = TramaSafetyCheck(
        msgId: _int(c['msgId']) ?? generarId32(),
        senderId: _int(c['senderId']) ?? generarId32(),
        estado: _int(c['estado']) ?? EstadoSafety.aSalvo,
        unixTime: _int(c['unixTime']) ?? _ahora(),
        ttl: _int(c['ttl']) ?? ttlMax - 1,
      );
      await _difundirDesdePostman(req, CodecTramas.codificar(trama), c);
    case 'POST /trama':
      final c = await _cuerpo(req);
      await _difundirDesdePostman(req, _deHex(c['hex'] as String? ?? ''), c);
    default:
      await _json(req, {
        'error': 'Ruta no encontrada: $ruta',
      }, HttpStatus.notFound);
  }
}

void _registrarApp(WebSocket ws) {
  _apps.add(ws);
  print('App conectada (${_apps.length} en total)');
  ws.listen(
    (mensaje) {
      final bytes = _deHex(
        (jsonDecode(mensaje as String) as Map)['hex'] as String,
      );
      final registro = {
        'hora': DateTime.now().toIso8601String(),
        ..._describir(bytes),
      };
      _enviadas.add(registro);
      print('TX app → ${jsonEncode(registro)}');
      // Las demás apps "escuchan" la transmisión por radio.
      _difundir(bytes, excepto: ws);
    },
    onDone: () {
      _apps.remove(ws);
      print('App desconectada (${_apps.length} en total)');
    },
  );
}

Future<void> _difundirDesdePostman(
  HttpRequest req,
  Uint8List bytes,
  Map<String, Object?> c,
) async {
  final receptores = _difundir(
    bytes,
    rssi: _int(c['rssi']),
    snr: (c['snr'] as num?)?.toDouble(),
  );
  print('RX inyectada → ${_aHex(bytes)} ($receptores apps)');
  await _json(req, {'appsQueRecibieron': receptores, ..._describir(bytes)});
}

int _difundir(Uint8List bytes, {WebSocket? excepto, int? rssi, double? snr}) {
  var n = 0;
  for (final app in _apps) {
    if (app == excepto) continue;
    app.add(
      jsonEncode({
        'hex': _aHex(bytes),
        'rssi': rssi ?? -70 - _rnd.nextInt(45),
        'snr': snr ?? 10 - _rnd.nextInt(18).toDouble(),
      }),
    );
    n++;
  }
  return n;
}

Map<String, Object?> _describir(Uint8List bytes) {
  final base = {'hex': _aHex(bytes), 'longitud': bytes.length};
  return switch (CodecTramas.decodificar(bytes)) {
    TramaAlerta t => {
      ...base,
      'trama': t.esSos ? 'SOS' : 'Alerta',
      'categoria': Categorias.porTipo(t.tipo)?.nombre,
      'msgId': t.msgId,
      'senderId': t.senderId,
      'ttl': t.ttl,
      'lat': t.lat,
      'lon': t.lon,
      'unixTime': t.unixTime,
      'texto': t.texto,
    },
    TramaSafetyCheck t => {
      ...base,
      'trama': 'SafetyCheck',
      'msgId': t.msgId,
      'senderId': t.senderId,
      'ttl': t.ttl,
      'estado': t.estado,
      'unixTime': t.unixTime,
    },
    null => {...base, 'trama': 'inválida (longitud, CRC o Type)'},
  };
}

/// Acepta `categoria` por clave ("incendio", "medica", "estructural", "sos")
/// o `tipo` numérico.
int _tipoDe(Map<String, Object?> c) {
  final tipo = _int(c['tipo']);
  if (tipo != null) return tipo;
  final clave = (c['categoria'] as String? ?? 'sos').toLowerCase();
  final categorias = [...Categorias.seleccionables, Categorias.sos];
  for (final cat in categorias) {
    if (cat.clave == clave) return cat.tipo;
  }
  throw FormatException(
    'Categoría desconocida "$clave". Usa: ${categorias.map((c) => c.clave).join(', ')}',
  );
}

Future<Map<String, Object?>> _cuerpo(HttpRequest req) async {
  final texto = await utf8.decoder.bind(req).join();
  if (texto.trim().isEmpty) return {};
  return (jsonDecode(texto) as Map).cast<String, Object?>();
}

/// Acepta números o cadenas hexadecimales ("0x1A2B3C4D").
int? _int(Object? v) => switch (v) {
  int n => n,
  String s when s.startsWith('0x') => int.parse(s.substring(2), radix: 16),
  String s => int.parse(s),
  _ => null,
};

int _ahora() => DateTime.now().millisecondsSinceEpoch ~/ 1000;

String _aHex(Uint8List b) =>
    b.map((x) => x.toRadixString(16).padLeft(2, '0')).join().toUpperCase();

Uint8List _deHex(String hex) {
  final limpio = hex.replaceAll(RegExp(r'[\s:]'), '');
  if (limpio.length.isOdd) {
    throw const FormatException('Hex con longitud impar');
  }
  return Uint8List.fromList([
    for (var i = 0; i < limpio.length; i += 2)
      int.parse(limpio.substring(i, i + 2), radix: 16),
  ]);
}

void _cors(HttpResponse r) =>
    r.headers
      ..set('Access-Control-Allow-Origin', '*')
      ..set('Access-Control-Allow-Methods', 'GET, POST, DELETE, OPTIONS')
      ..set('Access-Control-Allow-Headers', 'Content-Type');

Future<void> _json(
  HttpRequest req,
  Object? cuerpo, [
  int status = HttpStatus.ok,
]) async {
  req.response
    ..statusCode = status
    ..headers.contentType = ContentType.json
    ..write(const JsonEncoder.withIndent('  ').convert(cuerpo));
  await req.response.close();
}
