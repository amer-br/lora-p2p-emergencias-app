/// Manejo de protocolo (SDS, nivel 3): único punto del código que conoce el
/// formato de bits de las tramas. Todas las tramas son binarias, big-endian.
///
/// Alerta / SOS (56 B):
///   Msg_ID 4 | Sender_ID 4 | TTL 1 | Type 1 | Lat 4 | Lon 4 | Unix 4 | Texto 32 | CRC 2
/// Acuse (20 B):
///   Msg_ID 4 | Sender_ID 4 | TTL 1 | Type 1 | Ref_Msg_ID 4 | Unix 4 | CRC 2
/// Safety Check (17 B):
///   Msg_ID 4 | Sender_ID 4 | TTL 1 | Type 1 | Estado 1 | Unix 4 | CRC 2
///
/// Lat/Lon se codifican como grados × 10⁷ en int32; el valor centinela
/// 0x7FFFFFFF en ambos indica "sin posición válida".
///
/// El CRC-16 se calcula con el byte TTL puesto en 0, para que los nodos
/// intermedios puedan decrementar el TTL sin recalcularlo.
library;

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import '../domain/categoria.dart';
import 'crc16.dart';

/// TTL inicial de toda trama (SRS S3).
const int ttlMax = 5;

/// Longitud máxima del texto corto de una alerta, en bytes UTF-8.
const int maxBytesTexto = 32;

abstract final class TipoTrama {
  static const sos = tipoSos;
  static const ackEnCamino = 0x02;
  static const ackLlegue = 0x03;
  static const ackResuelto = 0x04;
  static const safetyCheck = 0x05;
}

const int longitudAlerta = 56;
const int longitudAcuse = 20;
const int longitudSafetyCheck = 17;
const int _centinelaGps = 0x7FFFFFFF;
const int _offsetTtl = 8;
const int _offsetType = 9;

int bytesUtf8(String texto) => utf8.encode(texto).length;

/// Genera un identificador de 32 bits distinto de cero.
int generarId32([Random? rnd]) =>
    ((rnd ?? Random.secure()).nextInt(0xFFFFFFFF)) + 1;

sealed class Trama {
  const Trama({required this.msgId, required this.senderId, required this.ttl});

  final int msgId;
  final int senderId;
  final int ttl;
}

class TramaAlerta extends Trama {
  const TramaAlerta({
    required super.msgId,
    required super.senderId,
    required this.tipo,
    required this.unixTime,
    this.lat,
    this.lon,
    this.texto = '',
    super.ttl = ttlMax,
  });

  final int tipo;
  final double? lat;
  final double? lon;
  final int unixTime;
  final String texto;

  bool get esSos => tipo == TipoTrama.sos;
}

/// Acuse de atención (CU-08, CU-09): ACK_EN_CAMINO, ACK_LLEGUE o ACK_RESUELTO.
class TramaAcuse extends Trama {
  const TramaAcuse({
    required super.msgId,
    required super.senderId,
    required this.tipo,
    required this.refMsgId,
    required this.unixTime,
    super.ttl = ttlMax,
  });

  final int tipo;

  /// Msg_ID del incidente al que se refiere.
  final int refMsgId;
  final int unixTime;
}

class TramaSafetyCheck extends Trama {
  const TramaSafetyCheck({
    required super.msgId,
    required super.senderId,
    required this.estado,
    required this.unixTime,
    super.ttl = ttlMax,
  });

  final int estado;
  final int unixTime;
}

abstract final class CodecTramas {
  static Uint8List codificar(Trama trama) => switch (trama) {
    TramaAlerta t => _codificarAlerta(t),
    TramaAcuse t => _codificarAcuse(t),
    TramaSafetyCheck t => _codificarSafetyCheck(t),
  };

  /// Devuelve null si la trama tiene longitud incorrecta, CRC inválido o un
  /// Type desconocido (se ignora por compatibilidad hacia adelante).
  static Trama? decodificar(Uint8List bytes) {
    if (bytes.length < _offsetType + 1) return null;
    final tipo = bytes[_offsetType];
    if (tipo == TipoTrama.safetyCheck) {
      if (bytes.length != longitudSafetyCheck || !_crcValido(bytes)) {
        return null;
      }
      return _decodificarSafetyCheck(bytes);
    }
    if (_esAcuse(tipo)) {
      if (bytes.length != longitudAcuse || !_crcValido(bytes)) return null;
      return _decodificarAcuse(bytes);
    }
    if (Categorias.porTipo(tipo) != null) {
      if (bytes.length != longitudAlerta || !_crcValido(bytes)) return null;
      return _decodificarAlerta(bytes);
    }
    return null;
  }

  static Uint8List _codificarAlerta(TramaAlerta t) {
    final b = Uint8List(longitudAlerta);
    final d = ByteData.sublistView(b);
    d.setUint32(0, t.msgId);
    d.setUint32(4, t.senderId);
    d.setUint8(_offsetTtl, t.ttl);
    d.setUint8(_offsetType, t.tipo);
    final conGps = t.lat != null && t.lon != null;
    d.setInt32(10, conGps ? (t.lat! * 1e7).round() : _centinelaGps);
    d.setInt32(14, conGps ? (t.lon! * 1e7).round() : _centinelaGps);
    d.setUint32(18, t.unixTime);
    final texto = t.esSos ? const <int>[] : utf8.encode(t.texto);
    if (texto.length > maxBytesTexto) {
      throw ArgumentError('El texto excede $maxBytesTexto bytes UTF-8');
    }
    b.setRange(22, 22 + texto.length, texto);
    d.setUint16(54, _crc(b));
    return b;
  }

  static TramaAlerta _decodificarAlerta(Uint8List b) {
    final d = ByteData.sublistView(b);
    final latE7 = d.getInt32(10);
    final lonE7 = d.getInt32(14);
    final sinGps = latE7 == _centinelaGps && lonE7 == _centinelaGps;
    var fin = 22 + maxBytesTexto;
    while (fin > 22 && b[fin - 1] == 0) {
      fin--;
    }
    return TramaAlerta(
      msgId: d.getUint32(0),
      senderId: d.getUint32(4),
      ttl: d.getUint8(_offsetTtl),
      tipo: d.getUint8(_offsetType),
      lat: sinGps ? null : latE7 / 1e7,
      lon: sinGps ? null : lonE7 / 1e7,
      unixTime: d.getUint32(18),
      texto: utf8.decode(b.sublist(22, fin), allowMalformed: true),
    );
  }

  static bool _esAcuse(int tipo) =>
      tipo == TipoTrama.ackEnCamino ||
      tipo == TipoTrama.ackLlegue ||
      tipo == TipoTrama.ackResuelto;

  static Uint8List _codificarAcuse(TramaAcuse t) {
    if (!_esAcuse(t.tipo)) {
      throw ArgumentError('Type de acuse inválido: ${t.tipo}');
    }
    final b = Uint8List(longitudAcuse);
    final d = ByteData.sublistView(b);
    d.setUint32(0, t.msgId);
    d.setUint32(4, t.senderId);
    d.setUint8(_offsetTtl, t.ttl);
    d.setUint8(_offsetType, t.tipo);
    d.setUint32(10, t.refMsgId);
    d.setUint32(14, t.unixTime);
    d.setUint16(18, _crc(b));
    return b;
  }

  static TramaAcuse _decodificarAcuse(Uint8List b) {
    final d = ByteData.sublistView(b);
    return TramaAcuse(
      msgId: d.getUint32(0),
      senderId: d.getUint32(4),
      ttl: d.getUint8(_offsetTtl),
      tipo: d.getUint8(_offsetType),
      refMsgId: d.getUint32(10),
      unixTime: d.getUint32(14),
    );
  }

  static Uint8List _codificarSafetyCheck(TramaSafetyCheck t) {
    final b = Uint8List(longitudSafetyCheck);
    final d = ByteData.sublistView(b);
    d.setUint32(0, t.msgId);
    d.setUint32(4, t.senderId);
    d.setUint8(_offsetTtl, t.ttl);
    d.setUint8(_offsetType, TipoTrama.safetyCheck);
    d.setUint8(10, t.estado);
    d.setUint32(11, t.unixTime);
    d.setUint16(15, _crc(b));
    return b;
  }

  static TramaSafetyCheck _decodificarSafetyCheck(Uint8List b) {
    final d = ByteData.sublistView(b);
    return TramaSafetyCheck(
      msgId: d.getUint32(0),
      senderId: d.getUint32(4),
      ttl: d.getUint8(_offsetTtl),
      estado: d.getUint8(10),
      unixTime: d.getUint32(11),
    );
  }

  static int _crc(Uint8List b) {
    final copia = Uint8List.fromList(b.sublist(0, b.length - 2));
    copia[_offsetTtl] = 0;
    return crc16(copia);
  }

  static bool _crcValido(Uint8List b) {
    final recibido = ByteData.sublistView(b).getUint16(b.length - 2);
    return recibido == _crc(b);
  }
}
