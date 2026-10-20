import 'dart:typed_data';

import 'package:aplicacion/domain/categoria.dart';
import 'package:aplicacion/domain/geo.dart';
import 'package:aplicacion/domain/modelos.dart';
import 'package:aplicacion/protocol/crc16.dart';
import 'package:aplicacion/protocol/tramas.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CRC-16', () {
    test('valor de referencia CCITT-FALSE', () {
      expect(crc16(Uint8List.fromList('123456789'.codeUnits)), 0x29B1);
    });
  });

  group('Trama de alerta', () {
    const alerta = TramaAlerta(
      msgId: 0xA1B2C3D4,
      senderId: 0x01020304,
      tipo: 0x11,
      lat: 22.7760123,
      lon: -102.6150456,
      unixTime: 1790000000,
      texto: 'Humo en edificio B',
    );

    test('mide 56 bytes y se decodifica igual', () {
      final bytes = CodecTramas.codificar(alerta);
      expect(bytes.length, longitudAlerta);
      final t = CodecTramas.decodificar(bytes) as TramaAlerta;
      expect(t.msgId, alerta.msgId);
      expect(t.senderId, alerta.senderId);
      expect(t.ttl, ttlMax);
      expect(t.tipo, 0x11);
      expect(t.lat, closeTo(alerta.lat!, 1e-7));
      expect(t.lon, closeTo(alerta.lon!, 1e-7));
      expect(t.unixTime, alerta.unixTime);
      expect(t.texto, alerta.texto);
    });

    test('sin GPS usa el valor centinela', () {
      const sinGps = TramaAlerta(msgId: 1, senderId: 2, tipo: tipoSos, unixTime: 0);
      final t = CodecTramas.decodificar(CodecTramas.codificar(sinGps)) as TramaAlerta;
      expect(t.lat, isNull);
      expect(t.lon, isNull);
      expect(t.esSos, isTrue);
      expect(t.texto, isEmpty);
    });

    test('el SOS se envía con texto vacío', () {
      const sos = TramaAlerta(msgId: 1, senderId: 2, tipo: tipoSos, unixTime: 0, texto: 'x');
      final t = CodecTramas.decodificar(CodecTramas.codificar(sos)) as TramaAlerta;
      expect(t.texto, isEmpty);
    });

    test('un nodo intermedio puede decrementar el TTL sin romper el CRC', () {
      final bytes = CodecTramas.codificar(alerta);
      bytes[8] = ttlMax - 2;
      final t = CodecTramas.decodificar(bytes) as TramaAlerta;
      expect(t.ttl, ttlMax - 2);
    });

    test('se descarta si el CRC no coincide', () {
      final bytes = CodecTramas.codificar(alerta);
      bytes[30] ^= 0xFF;
      expect(CodecTramas.decodificar(bytes), isNull);
    });

    test('se descarta si la longitud es incorrecta', () {
      final bytes = CodecTramas.codificar(alerta);
      expect(CodecTramas.decodificar(Uint8List.sublistView(bytes, 0, 40)), isNull);
    });

    test('texto con acentos de hasta 32 bytes UTF-8', () {
      const texto = 'Atrapado en el sótano, edif. C';
      expect(bytesUtf8(texto), lessThanOrEqualTo(maxBytesTexto));
      final t = CodecTramas.decodificar(CodecTramas.codificar(TramaAlerta(
          msgId: 1, senderId: 2, tipo: 0x12, unixTime: 0, texto: texto))) as TramaAlerta;
      expect(t.texto, texto);
    });

    test('rechaza texto de más de 32 bytes', () {
      expect(
        () => CodecTramas.codificar(const TramaAlerta(
            msgId: 1, senderId: 2, tipo: 0x12, unixTime: 0, texto: 'ñññññññññññññññññ')),
        throwsArgumentError,
      );
    });
  });

  group('Trama Safety Check', () {
    test('mide 17 bytes y se decodifica igual', () {
      const sc = TramaSafetyCheck(
          msgId: 7, senderId: 9, estado: EstadoSafety.aSalvo, unixTime: 1790000000);
      final bytes = CodecTramas.codificar(sc);
      expect(bytes.length, longitudSafetyCheck);
      final t = CodecTramas.decodificar(bytes) as TramaSafetyCheck;
      expect(t.msgId, 7);
      expect(t.senderId, 9);
      expect(t.estado, EstadoSafety.aSalvo);
      expect(t.unixTime, 1790000000);
    });
  });

  test('un Type desconocido se ignora sin error', () {
    final bytes = CodecTramas.codificar(
        const TramaAlerta(msgId: 1, senderId: 2, tipo: 0x11, unixTime: 0));
    bytes[9] = 0x7E;
    expect(CodecTramas.decodificar(bytes), isNull);
  });

  test('generarId32 nunca devuelve cero y cabe en 32 bits', () {
    for (var i = 0; i < 1000; i++) {
      final id = generarId32();
      expect(id, inInclusiveRange(1, 0xFFFFFFFF));
    }
  });

  group('Haversine', () {
    test('un grado de latitud mide ~111.2 km', () {
      expect(distanciaHaversine(0, 0, 1, 0), closeTo(111195, 1));
    });

    test('distancia cero al mismo punto', () {
      expect(distanciaHaversine(22.776, -102.615, 22.776, -102.615), 0);
    });

    test('formato de distancia', () {
      expect(formatearDistancia(120.4), '120 m');
      expect(formatearDistancia(1520), '1.5 km');
    });
  });
}
