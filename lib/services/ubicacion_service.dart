import 'dart:async';

import 'package:geolocator/geolocator.dart';

import '../domain/modelos.dart';

enum PermisoUbicacion { concedido, denegado, servicioApagado }

/// Acceso al GNSS del teléfono. Los sensores se activan solo cuando se
/// necesitan (RNF-6): lectura puntual al emitir y flujo solo con el radar abierto.
class UbicacionService {
  /// Antigüedad máxima para reutilizar la última lectura al emitir (CU-01/02).
  static const vigenciaUltimaLectura = Duration(seconds: 30);

  /// Tiempo máximo para obtener una lectura nueva al emitir.
  static const tiempoMaximoLectura = Duration(seconds: 2);

  Posicion? _ultima;

  Posicion? get ultimaConocida => _ultima;

  Future<PermisoUbicacion> verificarPermiso({bool solicitar = false}) async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        return PermisoUbicacion.servicioApagado;
      }
      var permiso = await Geolocator.checkPermission();
      if (solicitar && permiso == LocationPermission.denied) {
        permiso = await Geolocator.requestPermission();
      }
      return switch (permiso) {
        LocationPermission.always ||
        LocationPermission.whileInUse =>
          PermisoUbicacion.concedido,
        _ => PermisoUbicacion.denegado,
      };
    } catch (_) {
      return PermisoUbicacion.denegado;
    }
  }

  /// Posición para adjuntar a una alerta: la última si tiene ≤ 30 s, si no una
  /// nueva con tiempo máximo de 2 s. Devuelve null si no hay señal (E2/A1).
  Future<Posicion?> posicionParaEnvio() async {
    final ultima = _ultima;
    if (ultima != null &&
        DateTime.now().difference(ultima.hora) <= vigenciaUltimaLectura) {
      return ultima;
    }
    if (await verificarPermiso() != PermisoUbicacion.concedido) return null;
    try {
      final p = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: tiempoMaximoLectura,
        ),
      );
      return _registrar(p);
    } catch (_) {
      return null;
    }
  }

  /// Flujo continuo de posiciones mientras alguien esté suscrito.
  Stream<Posicion> seguir() => Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 3,
        ),
      ).map(_registrar);

  Posicion _registrar(Position p) => _ultima = Posicion(
        lat: p.latitude,
        lon: p.longitude,
        precisionM: p.accuracy,
        hora: DateTime.now(),
      );
}
