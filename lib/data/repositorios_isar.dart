import 'package:flutter/services.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../domain/atencion.dart';
import '../domain/modelos.dart';
import 'entidades.dart';
import 'repositorios.dart';

/// Persistencia con Isar (SDS, Figura 4) para Android, iOS y escritorio.
Future<Almacen> abrirAlmacen() async {
  final dir = await getApplicationSupportDirectory();
  final isar = await Isar.open(
    [
      IncidenteEntitySchema,
      AcuseEntitySchema,
      SafetyCheckEntitySchema,
      RecursoEntitySchema,
    ],
    directory: dir.path,
    name: 'lora_emergencias',
  );
  return Almacen(
    incidentes: _IncidenteRepositoryIsar(isar),
    acuses: _AcuseRepositoryIsar(isar),
    safetyChecks: _SafetyCheckRepositoryIsar(isar),
    recursos: _RecursoRepositoryIsar(isar),
  );
}

class _IncidenteRepositoryIsar implements IncidenteRepository {
  _IncidenteRepositoryIsar(this._isar);

  final Isar _isar;

  IsarCollection<IncidenteEntity> get _col => _isar.incidenteEntitys;

  @override
  Future<void> guardar(Incidente i) =>
      _isar.writeTxn(() => _col.put(_aEntidad(i)));

  @override
  Future<bool> insertarSiNuevo(Incidente i) => _isar.writeTxn(() async {
    if (await _col.get(i.msgId) != null) return false;
    await _col.put(_aEntidad(i));
    return true;
  });

  @override
  Future<void> actualizarEstadoEnvio(int msgId, EstadoEnvio estado) =>
      _isar.writeTxn(() async {
        final e = await _col.get(msgId);
        if (e == null) return;
        e.estadoEnvio = estado;
        await _col.put(e);
      });

  @override
  Future<List<Incidente>> pendientesPropios() async {
    final lista =
        await _col
            .filter()
            .origenEqualTo(Origen.propio)
            .estadoEnvioEqualTo(EstadoEnvio.pendiente)
            .findAll();
    return lista.map(_aDominio).toList();
  }

  @override
  Stream<List<Incidente>> observarTodos() => _col
      .where()
      .sortByHoraRecepcionLocalDesc()
      .watch(fireImmediately: true)
      .map((l) => l.map(_aDominio).toList());

  @override
  Stream<Incidente?> observar(int msgId) => _col
      .watchObject(msgId, fireImmediately: true)
      .map((e) => e == null ? null : _aDominio(e));

  static IncidenteEntity _aEntidad(Incidente i) =>
      IncidenteEntity()
        ..msgId = i.msgId
        ..senderId = i.senderId
        ..tipo = i.tipo
        ..lat = i.lat
        ..lon = i.lon
        ..texto = i.texto
        ..horaEmisor = i.horaEmisor
        ..horaRecepcionLocal = i.horaRecepcionLocal
        ..origen = i.origen
        ..estadoEnvio = i.estadoEnvio;

  static Incidente _aDominio(IncidenteEntity e) => Incidente(
    msgId: e.msgId,
    senderId: e.senderId,
    tipo: e.tipo,
    lat: e.lat,
    lon: e.lon,
    texto: e.texto,
    horaEmisor: e.horaEmisor,
    horaRecepcionLocal: e.horaRecepcionLocal,
    origen: e.origen,
    estadoEnvio: e.estadoEnvio,
  );
}

class _AcuseRepositoryIsar implements AcuseRepository {
  _AcuseRepositoryIsar(this._isar);

  final Isar _isar;

  IsarCollection<AcuseEntity> get _col => _isar.acuseEntitys;

  @override
  Future<void> guardar(Acuse a) => _isar.writeTxn(() => _col.put(_aEntidad(a)));

  @override
  Future<bool> insertarSiNuevo(Acuse a) => _isar.writeTxn(() async {
    if (await _col.get(a.msgId) != null) return false;
    await _col.put(_aEntidad(a));
    return true;
  });

  @override
  Future<void> actualizarEstadoEnvio(int msgId, EstadoEnvio estado) =>
      _isar.writeTxn(() async {
        final e = await _col.get(msgId);
        if (e == null) return;
        e.estadoEnvio = estado;
        await _col.put(e);
      });

  @override
  Future<List<Acuse>> pendientesPropios() async {
    final lista =
        await _col
            .filter()
            .origenEqualTo(Origen.propio)
            .estadoEnvioEqualTo(EstadoEnvio.pendiente)
            .findAll();
    return lista.map(_aDominio).whereType<Acuse>().toList();
  }

  @override
  Future<int> propiosDesde(DateTime desde) =>
      _col
          .filter()
          .origenEqualTo(Origen.propio)
          .horaRecepcionLocalGreaterThan(desde)
          .count();

  @override
  Stream<List<Acuse>> observarDe(int refMsgId) => _col
      .filter()
      .refMsgIdEqualTo(refMsgId)
      .watch(fireImmediately: true)
      .map((l) => l.map(_aDominio).whereType<Acuse>().toList());

  @override
  Stream<List<Acuse>> observarTodos() => _col
      .where()
      .watch(fireImmediately: true)
      .map((l) => l.map(_aDominio).whereType<Acuse>().toList());

  static AcuseEntity _aEntidad(Acuse a) =>
      AcuseEntity()
        ..msgId = a.msgId
        ..senderId = a.senderId
        ..tipo = a.tipo.tipo
        ..refMsgId = a.refMsgId
        ..horaEmisor = a.horaEmisor
        ..horaRecepcionLocal = a.horaRecepcionLocal
        ..origen = a.origen
        ..estadoEnvio = a.estadoEnvio
        ..rssi = a.rssi
        ..snr = a.snr;

  /// null si el tipo guardado no es un acuse conocido.
  static Acuse? _aDominio(AcuseEntity e) {
    final tipo = TipoAcuse.porTipo(e.tipo);
    if (tipo == null) return null;
    return Acuse(
      msgId: e.msgId,
      senderId: e.senderId,
      tipo: tipo,
      refMsgId: e.refMsgId,
      horaEmisor: e.horaEmisor,
      horaRecepcionLocal: e.horaRecepcionLocal,
      origen: e.origen,
      estadoEnvio: e.estadoEnvio,
      rssi: e.rssi,
      snr: e.snr,
    );
  }
}

class _SafetyCheckRepositoryIsar implements SafetyCheckRepository {
  _SafetyCheckRepositoryIsar(this._isar);

  final Isar _isar;

  IsarCollection<SafetyCheckEntity> get _col => _isar.safetyCheckEntitys;

  @override
  Future<void> guardar(ReporteSafetyCheck r) =>
      _isar.writeTxn(() => _col.put(_aEntidad(r)));

  @override
  Future<bool> insertarSiNuevo(ReporteSafetyCheck r) =>
      _isar.writeTxn(() async {
        if (await _col.get(r.msgId) != null) return false;
        await _col.put(_aEntidad(r));
        return true;
      });

  @override
  Future<void> actualizarEstadoEnvio(int msgId, EstadoEnvio estado) =>
      _isar.writeTxn(() async {
        final e = await _col.get(msgId);
        if (e == null) return;
        e.estadoEnvio = estado;
        await _col.put(e);
      });

  @override
  Future<List<ReporteSafetyCheck>> pendientesPropios() async {
    final lista =
        await _col
            .filter()
            .origenEqualTo(Origen.propio)
            .estadoEnvioEqualTo(EstadoEnvio.pendiente)
            .findAll();
    return lista.map(_aDominio).toList();
  }

  @override
  Future<int> propiosDesde(DateTime desde) =>
      _col
          .filter()
          .origenEqualTo(Origen.propio)
          .horaRecepcionLocalGreaterThan(desde)
          .count();

  @override
  Stream<ReporteSafetyCheck?> observarUltimoPropio() => _col
      .filter()
      .origenEqualTo(Origen.propio)
      .sortByHoraRecepcionLocalDesc()
      .watch(fireImmediately: true)
      .map((l) => l.isEmpty ? null : _aDominio(l.first));

  static SafetyCheckEntity _aEntidad(ReporteSafetyCheck r) =>
      SafetyCheckEntity()
        ..msgId = r.msgId
        ..senderId = r.senderId
        ..estado = r.estado
        ..horaEmisor = r.horaEmisor
        ..horaRecepcionLocal = r.horaRecepcionLocal
        ..origen = r.origen
        ..estadoEnvio = r.estadoEnvio;

  static ReporteSafetyCheck _aDominio(SafetyCheckEntity e) =>
      ReporteSafetyCheck(
        msgId: e.msgId,
        senderId: e.senderId,
        estado: e.estado,
        horaEmisor: e.horaEmisor,
        horaRecepcionLocal: e.horaRecepcionLocal,
        origen: e.origen,
        estadoEnvio: e.estadoEnvio,
      );
}

/// Los recursos incluidos en la instalación se copian a Isar la primera vez.
class _RecursoRepositoryIsar implements RecursoRepository {
  _RecursoRepositoryIsar(this._isar);

  final Isar _isar;

  IsarCollection<RecursoEntity> get _col => _isar.recursoEntitys;

  @override
  Future<void> cargarSiVacio(AssetBundle bundle) async {
    if (await _col.count() > 0) return;
    final recursos = await leerRecursosIncluidos(bundle);
    final entidades = [
      for (final r in recursos)
        RecursoEntity()
          ..tipo = r.tipo
          ..nombre = r.nombre
          ..descripcion = r.descripcion
          ..lat = r.lat
          ..lon = r.lon
          ..fechaActualizacion = r.fechaActualizacion,
    ];
    await _isar.writeTxn(() => _col.putAll(entidades));
  }

  @override
  Future<List<RecursoMapa>> todos() async {
    final lista = await _col.where().findAll();
    return [
      for (final e in lista)
        RecursoMapa(
          id: e.id,
          tipo: e.tipo,
          nombre: e.nombre,
          descripcion: e.descripcion,
          lat: e.lat,
          lon: e.lon,
          fechaActualizacion: e.fechaActualizacion,
        ),
    ];
  }
}
