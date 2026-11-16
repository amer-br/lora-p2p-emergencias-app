import 'dart:typed_data';

import 'package:aplicacion/services/gatt_modem.dart';
import 'package:flutter_test/flutter_test.dart';

/// Bytes tal como los publica el firmware (FirmwareTBeam/src/enlace_ble.cpp).
void main() {
  group('STATUS', () {
    test('trama encolada con batería y carga', () {
      final s =
          EstadoGattModem.decodificar([
            1,
            0x03,
            87,
            0x0B,
            0xAD,
            0xCA,
            0xFE,
            0,
            2,
          ])!;
      expect(s.radioLista, isTrue);
      expect(s.cargando, isTrue);
      expect(s.bateria, 87);
      expect(s.ultimoMsgId, 0x0BADCAFE);
      expect(s.resultado, ResultadoEncolado.encolada);
    });

    test('sin batería y cola llena', () {
      final s = EstadoGattModem.decodificar([1, 0x01, 0xFF, 0, 0, 0, 7, 2, 1])!;
      expect(s.bateria, isNull);
      expect(s.cargando, isFalse);
      expect(s.ultimoMsgId, 7);
      expect(s.resultado, ResultadoEncolado.colaLlena);
    });

    test('versión desconocida o contenido corto se ignoran', () {
      expect(EstadoGattModem.decodificar([2, 1, 50, 0, 0, 0, 1, 0, 1]), isNull);
      expect(EstadoGattModem.decodificar([1, 1, 50]), isNull);
    });
  });

  group('RX_FRAME', () {
    test('RSSI negativo, SNR en cuartos de dB y la trama', () {
      final trama = List<int>.generate(56, (i) => i);
      // RSSI -102 = 0xFF9A; SNR -3.25 dB = -13 cuartos = 0xF3.
      final t = decodificarRxFrame([0xFF, 0x9A, 0xF3, ...trama])!;
      expect(t.rssi, -102);
      expect(t.snr, -3.25);
      expect(t.bytes, Uint8List.fromList(trama));
    });

    test('sin trama después de los metadatos se descarta', () {
      expect(decodificarRxFrame([0xFF, 0x9A, 0x10]), isNull);
    });
  });

  test('Msg_ID de una trama', () {
    expect(
      msgIdDe(Uint8List.fromList([0x0B, 0xAD, 0xCA, 0xFE, 9])),
      0x0BADCAFE,
    );
    expect(msgIdDe(Uint8List.fromList([1, 2])), isNull);
  });
}
