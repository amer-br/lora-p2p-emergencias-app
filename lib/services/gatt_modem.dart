/// Contrato GATT con el firmware del T-Beam en modo módem
/// (FirmwareTBeam/src/enlace_ble.cpp; SRS 3.1.2; SDS 7.7).
///
/// Código puro de Dart, sin dependencias de BLE, para probarlo sin hardware.
library;

import 'dart:typed_data';

import 'modem_service.dart';

abstract final class UuidModem {
  static const servicio = '8f1d0001-6b3a-4c2e-9e5d-2a7c4b9e1f00';

  /// Escritura con respuesta: la app escribe la trama binaria por difundir.
  static const txFrame = '8f1d0002-6b3a-4c2e-9e5d-2a7c4b9e1f00';

  /// Notificación: trama recibida por radio con su RSSI y SNR.
  static const rxFrame = '8f1d0003-6b3a-4c2e-9e5d-2a7c4b9e1f00';

  /// Lectura y notificación: batería y confirmación de encolado.
  static const status = '8f1d0004-6b3a-4c2e-9e5d-2a7c4b9e1f00';
}

/// Resultado de la última trama escrita en TX_FRAME, según STATUS.
enum ResultadoEncolado { encolada, invalida, colaLlena, desconocido }

/// Contenido de la característica STATUS (9 bytes, versión 1):
///
///   [0] versión · [1] banderas (bit0 radio lista, bit1 cargando) ·
///   [2] batería % (0xFF sin batería) · [3..6] Msg_ID de la última trama
///   escrita (big-endian) · [7] resultado (0 encolada, 1 inválida, 2 cola
///   llena) · [8] transceptor (1 SX1262, 2 SX1276)
class EstadoGattModem {
  const EstadoGattModem({
    required this.radioLista,
    required this.cargando,
    required this.bateria,
    required this.ultimoMsgId,
    required this.resultado,
  });

  static const version = 1;
  static const longitud = 9;

  final bool radioLista;
  final bool cargando;

  /// Porcentaje de batería; null si el módem no tiene batería.
  final int? bateria;
  final int ultimoMsgId;
  final ResultadoEncolado resultado;

  /// Devuelve null si el contenido no corresponde a esta versión del formato.
  static EstadoGattModem? decodificar(List<int> valor) {
    if (valor.length < longitud || valor[0] != version) return null;
    final b = Uint8List.fromList(valor);
    final d = ByteData.sublistView(b);
    return EstadoGattModem(
      radioLista: b[1] & 0x01 != 0,
      cargando: b[1] & 0x02 != 0,
      bateria: b[2] == 0xFF ? null : b[2].clamp(0, 100),
      ultimoMsgId: d.getUint32(3),
      resultado: switch (b[7]) {
        0 => ResultadoEncolado.encolada,
        1 => ResultadoEncolado.invalida,
        2 => ResultadoEncolado.colaLlena,
        _ => ResultadoEncolado.desconocido,
      },
    );
  }
}

/// RX_FRAME: [0..1] RSSI (int16, dBm) · [2] SNR en cuartos de dB (int8) ·
/// [3..] trama. Devuelve null si no trae al menos los metadatos y un byte.
TramaRecibida? decodificarRxFrame(List<int> valor) {
  const metadatos = 3;
  if (valor.length <= metadatos) return null;
  final b = Uint8List.fromList(valor);
  final d = ByteData.sublistView(b);
  return TramaRecibida(
    bytes: Uint8List.sublistView(b, metadatos),
    rssi: d.getInt16(0),
    snr: d.getInt8(2) / 4,
  );
}

/// Msg_ID de una trama (sus primeros 4 bytes), o null si es demasiado corta.
int? msgIdDe(Uint8List trama) =>
    trama.length < 4 ? null : ByteData.sublistView(trama).getUint32(0);
