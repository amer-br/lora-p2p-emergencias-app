import 'dart:math' as math;

const double radioTierraM = 6371000;

/// Distancia en metros entre dos coordenadas con la fórmula de Haversine
/// (SRS CU-03): a = sen²(Δφ/2) + cos φ₁ · cos φ₂ · sen²(Δλ/2); d = 2R · arcsen(√a).
double distanciaHaversine(double lat1, double lon1, double lat2, double lon2) {
  final p1 = _rad(lat1);
  final p2 = _rad(lat2);
  final dp = _rad(lat2 - lat1);
  final dl = _rad(lon2 - lon1);
  final a = math.pow(math.sin(dp / 2), 2) +
      math.cos(p1) * math.cos(p2) * math.pow(math.sin(dl / 2), 2);
  return 2 * radioTierraM * math.asin(math.sqrt(a));
}

double _rad(double grados) => grados * math.pi / 180;

String formatearDistancia(double metros) {
  if (metros < 1000) return '${metros.round()} m';
  return '${(metros / 1000).toStringAsFixed(1)} km';
}

String formatearAntiguedad(DateTime hora, {DateTime? ahora}) {
  final d = (ahora ?? DateTime.now()).difference(hora);
  if (d.inSeconds < 60) return 'hace ${d.inSeconds.clamp(0, 59)} s';
  if (d.inMinutes < 60) return 'hace ${d.inMinutes} min';
  if (d.inHours < 24) return 'hace ${d.inHours} h';
  return 'hace ${d.inDays} d';
}
