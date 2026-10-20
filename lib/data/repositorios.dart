import 'dart:convert';

import 'package:flutter/services.dart';

import '../domain/modelos.dart';

/// Contratos de persistencia local. La implementación se elige en
/// `almacen.dart`: Isar en Android/iOS/escritorio y memoria en la web
/// (Isar no puede compilarse a JavaScript).

abstract class IncidenteRepository {
  Future<void> guardar(Incidente i);

  /// Inserta solo si el Msg_ID no existe. Devuelve false si era duplicado.
  Future<bool> insertarSiNuevo(Incidente i);

  Future<void> actualizarEstadoEnvio(int msgId, EstadoEnvio estado);

  Future<List<Incidente>> pendientesPropios();

  /// Todos los incidentes, del más reciente al más antiguo.
  Stream<List<Incidente>> observarTodos();

  Stream<Incidente?> observar(int msgId);
}

abstract class SafetyCheckRepository {
  Future<void> guardar(ReporteSafetyCheck r);

  Future<bool> insertarSiNuevo(ReporteSafetyCheck r);

  Future<void> actualizarEstadoEnvio(int msgId, EstadoEnvio estado);

  Future<List<ReporteSafetyCheck>> pendientesPropios();

  Future<int> propiosDesde(DateTime desde);

  /// Último reporte propio, para CU-06 A1 ("Ya reportaste que estás a salvo").
  Stream<ReporteSafetyCheck?> observarUltimoPropio();
}

/// Recursos del mapa precargados con la instalación (SRS S7).
abstract class RecursoRepository {
  static const asset = 'assets/data/recursos.json';

  Future<void> cargarSiVacio(AssetBundle bundle);

  Future<List<RecursoMapa>> todos();
}

class Almacen {
  const Almacen({
    required this.incidentes,
    required this.safetyChecks,
    required this.recursos,
  });

  final IncidenteRepository incidentes;
  final SafetyCheckRepository safetyChecks;
  final RecursoRepository recursos;
}

/// Lee `recursos.json`. Lanza una excepción si el contenido es inválido (E1).
Future<List<RecursoMapa>> leerRecursosIncluidos(AssetBundle bundle) async {
  final datos = jsonDecode(await bundle.loadString(RecursoRepository.asset)) as List;
  final ahora = DateTime.now();
  var id = 1;
  return [
    for (final d in datos.cast<Map<String, dynamic>>())
      RecursoMapa(
        id: id++,
        tipo: TipoRecurso.porCodigo(d['tipo'] as String)!,
        nombre: d['nombre'] as String,
        descripcion: d['descripcion'] as String?,
        lat: (d['lat'] as num).toDouble(),
        lon: (d['lon'] as num).toDouble(),
        fechaActualizacion: ahora,
      ),
  ];
}

/// Guía de primeros auxilios: contenido estático embebido, no reside en la BD.
class ProtocoloRepository {
  static const asset = 'assets/data/primeros_auxilios.json';

  List<ProtocoloAuxilio>? _cache;

  Future<List<ProtocoloAuxilio>> cargar(AssetBundle bundle) async {
    if (_cache != null) return _cache!;
    final datos = jsonDecode(await bundle.loadString(asset)) as List;
    return _cache = [
      for (final d in datos.cast<Map<String, dynamic>>()) _parsear(d),
    ];
  }

  /// Un tema con contenido inválido se conserva en la lista pero sin pasos,
  /// para que al abrirlo se informe el error sin afectar a los demás (E1).
  static ProtocoloAuxilio _parsear(Map<String, dynamic> d) {
    List<String> pasos;
    try {
      pasos = (d['pasos'] as List).cast<String>();
    } catch (_) {
      pasos = const [];
    }
    return ProtocoloAuxilio(
      id: d['id'] as String? ?? '',
      titulo: d['titulo'] as String? ?? 'Tema sin título',
      categoria: d['categoria'] as String? ?? '',
      icono: d['icono'] as String? ?? '',
      pasos: pasos,
      advertencias: d['advertencias'] as String?,
    );
  }
}
