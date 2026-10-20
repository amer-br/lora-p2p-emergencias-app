import 'dart:typed_data';

/// CRC-16/CCITT-FALSE (polinomio 0x1021, valor inicial 0xFFFF).
int crc16(Uint8List datos, [int inicio = 0, int? fin]) {
  var crc = 0xFFFF;
  for (var i = inicio; i < (fin ?? datos.length); i++) {
    crc ^= datos[i] << 8;
    for (var b = 0; b < 8; b++) {
      crc = (crc & 0x8000) != 0 ? (crc << 1) ^ 0x1021 : crc << 1;
      crc &= 0xFFFF;
    }
  }
  return crc;
}
