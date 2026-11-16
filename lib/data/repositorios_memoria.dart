import 'dart:async';

import 'package:flutter/services.dart';

import '../domain/atencion.dart';
import '../domain/modelos.dart';
import 'repositorios.dart';

/// Persistencia en memoria para la versión web (solo demostración): los
/// datos se pierden al recargar la página.
Future<Almacen> abrirAlmacen() async => Almacen(
  incidentes: _IncidenteRepositoryMemoria(),
  acuses: AcuseRepositoryMemoria(),
  safetyChecks: _SafetyCheckRepositoryMemoria(),
  recursos: _RecursoRepositoryMemoria(),
);

/// Mapa Msg_ID → registro con notificación de cambios, para imitar los
/// `watch` de Isar.
class _Tabla<T> {
  final datos = <int, T>{};
  final _cambios = StreamController<void>.broadcast();

  void poner(int id, T valor) {
    datos[id] = valor;
    _cambios.add(null);
  }

  Stream<R> observar<R>(R Function() leer) async* {
    yield leer();
    await for (final _ in _cambios.stream) {
      yield leer();
    }
  }
}

class _IncidenteRepositoryMemoria implements IncidenteRepository {
  final _t = _Tabla<Incidente>();

  @override
  Future<void> guardar(Incidente i) async => _t.poner(i.msgId, i);

  @override
  Future<bool> insertarSiNuevo(Incidente i) async {
    if (_t.datos.containsKey(i.msgId)) return false;
    _t.poner(i.msgId, i);
    return true;
  }

  @override
  Future<void> actualizarEstadoEnvio(int msgId, EstadoEnvio estado) async {
    final i = _t.datos[msgId];
    if (i != null) _t.poner(msgId, i.copyWith(estadoEnvio: estado));
  }

  @override
  Future<List<Incidente>> pendientesPropios() async =>
      _t.datos.values
          .where(
            (i) =>
                i.origen == Origen.propio &&
                i.estadoEnvio == EstadoEnvio.pendiente,
          )
          .toList();

  @override
  Stream<List<Incidente>> observarTodos() => _t.observar(
    () =>
        _t.datos.values.toList()..sort(
          (a, b) => b.horaRecepcionLocal.compareTo(a.horaRecepcionLocal),
        ),
  );

  @override
  Stream<Incidente?> observar(int msgId) => _t.observar(() => _t.datos[msgId]);
}

/// Pública para usarla en las pruebas sin Isar.
class AcuseRepositoryMemoria implements AcuseRepository {
  final _t = _Tabla<Acuse>();

  Iterable<Acuse> get _propios =>
      _t.datos.values.where((a) => a.origen == Origen.propio);

  @override
  Future<void> guardar(Acuse a) async => _t.poner(a.msgId, a);

  @override
  Future<bool> insertarSiNuevo(Acuse a) async {
    if (_t.datos.containsKey(a.msgId)) return false;
    _t.poner(a.msgId, a);
    return true;
  }

  @override
  Future<void> actualizarEstadoEnvio(int msgId, EstadoEnvio estado) async {
    final a = _t.datos[msgId];
    if (a != null) _t.poner(msgId, a.copyWith(estadoEnvio: estado));
  }

  @override
  Future<List<Acuse>> pendientesPropios() async =>
      _propios.where((a) => a.estadoEnvio == EstadoEnvio.pendiente).toList();

  @override
  Future<int> propiosDesde(DateTime desde) async =>
      _propios.where((a) => a.horaRecepcionLocal.isAfter(desde)).length;

  @override
  Stream<List<Acuse>> observarDe(int refMsgId) => _t.observar(
    () => _t.datos.values.where((a) => a.refMsgId == refMsgId).toList(),
  );

  @override
  Stream<List<Acuse>> observarTodos() =>
      _t.observar(() => _t.datos.values.toList());
}

class _SafetyCheckRepositoryMemoria implements SafetyCheckRepository {
  final _t = _Tabla<ReporteSafetyCheck>();

  Iterable<ReporteSafetyCheck> get _propios =>
      _t.datos.values.where((r) => r.origen == Origen.propio);

  @override
  Future<void> guardar(ReporteSafetyCheck r) async => _t.poner(r.msgId, r);

  @override
  Future<bool> insertarSiNuevo(ReporteSafetyCheck r) async {
    if (_t.datos.containsKey(r.msgId)) return false;
    _t.poner(r.msgId, r);
    return true;
  }

  @override
  Future<void> actualizarEstadoEnvio(int msgId, EstadoEnvio estado) async {
    final r = _t.datos[msgId];
    if (r == null) return;
    _t.poner(
      msgId,
      ReporteSafetyCheck(
        msgId: r.msgId,
        senderId: r.senderId,
        estado: r.estado,
        horaEmisor: r.horaEmisor,
        horaRecepcionLocal: r.horaRecepcionLocal,
        origen: r.origen,
        estadoEnvio: estado,
      ),
    );
  }

  @override
  Future<List<ReporteSafetyCheck>> pendientesPropios() async =>
      _propios.where((r) => r.estadoEnvio == EstadoEnvio.pendiente).toList();

  @override
  Future<int> propiosDesde(DateTime desde) async =>
      _propios.where((r) => r.horaRecepcionLocal.isAfter(desde)).length;

  @override
  Stream<ReporteSafetyCheck?> observarUltimoPropio() => _t.observar(() {
    ReporteSafetyCheck? ultimo;
    for (final r in _propios) {
      if (ultimo == null ||
          r.horaRecepcionLocal.isAfter(ultimo.horaRecepcionLocal)) {
        ultimo = r;
      }
    }
    return ultimo;
  });
}

class _RecursoRepositoryMemoria implements RecursoRepository {
  List<RecursoMapa> _recursos = const [];

  @override
  Future<void> cargarSiVacio(AssetBundle bundle) async {
    if (_recursos.isEmpty) _recursos = await leerRecursosIncluidos(bundle);
  }

  @override
  Future<List<RecursoMapa>> todos() async => _recursos;
}
