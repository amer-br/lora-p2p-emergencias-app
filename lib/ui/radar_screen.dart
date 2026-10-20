import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../app_scope.dart';
import '../domain/categoria.dart';
import '../domain/geo.dart';
import '../domain/modelos.dart';
import '../services/ubicacion_service.dart';
import 'primeros_auxilios_screen.dart';
import 'tema.dart';
import 'widgets.dart';

const _capaIncidentes = 'INCIDENTES';
const _prefCapas = 'radar_capas';

/// Área del campus: solo se dibujan teselas dentro de ella y el centro de la
/// cámara no puede salir de ella.
final _limites = LatLngBounds(
  LatLng(limitesCampus.sur, limitesCampus.oeste),
  LatLng(limitesCampus.norte, limitesCampus.este),
);

/// CU-03: radar y mapa fuera de línea con incidentes y recursos precargados.
///
/// Aún no hay teselas MBTiles del campus (SRS S6), así que el mapa dibuja una
/// cuadrícula local de referencia; al tenerlas se añade un TileLayer offline.
class RadarScreen extends StatefulWidget {
  const RadarScreen({super.key, this.masCercanoInicial});

  /// Si se indica, al abrir se selecciona el recurso más cercano de ese tipo
  /// (p. ej., "DEA más cercano" desde la guía, CU-04 paso 4).
  final TipoRecurso? masCercanoInicial;

  @override
  State<RadarScreen> createState() => _RadarScreenState();
}

class _RadarScreenState extends State<RadarScreen> {
  final _mapa = MapController();
  final _subs = <StreamSubscription<dynamic>>[];

  late Set<String> _capas;
  late LatLng _centroInicial;
  late List<Polyline> _cuadricula;
  bool _iniciado = false;
  bool _vistaLista = false;
  bool _mapaListo = false;

  List<Incidente> _incidentes = const [];
  List<RecursoMapa>? _recursos;
  bool _errorRecursos = false;

  Posicion? _posicion;
  bool _posicionAprox = true;
  bool _gpsAgotado = false;
  Timer? _esperaGps;

  Object? _seleccion;
  TipoRecurso? _pendienteMasCercano;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_iniciado) return;
    _iniciado = true;
    final deps = AppScope.of(context);

    _capas =
        deps.prefs.getStringList(_prefCapas)?.toSet() ??
        {_capaIncidentes, ...TipoRecurso.values.map((t) => t.codigo)};
    _pendienteMasCercano = widget.masCercanoInicial;
    if (_pendienteMasCercano != null) _capas.add(_pendienteMasCercano!.codigo);

    _posicion = deps.ubicacion.ultimaConocida;
    final base = _posicion;
    _centroInicial =
        base != null && _limites.contains(LatLng(base.lat, base.lon))
            ? LatLng(base.lat, base.lon)
            : LatLng(centroCampus.lat, centroCampus.lon);
    _cuadricula = _crearCuadricula(_limites);

    _cargarRecursos(deps);
    _subs.add(
      deps.incidentes.observarTodos().listen(
        (l) => setState(() => _incidentes = l),
      ),
    );
    _subs.add(deps.procesador.incidentesNuevos.listen(_alRecibirIncidente));
    _iniciarGps(deps.ubicacion);
  }

  @override
  void dispose() {
    for (final s in _subs) {
      s.cancel();
    }
    _esperaGps?.cancel();
    _mapa.dispose();
    super.dispose();
  }

  Future<void> _cargarRecursos(Dependencias deps) async {
    try {
      if (deps.errorRecursos) throw StateError('Recursos no cargados');
      final r = await deps.recursos.todos();
      if (!mounted) return;
      setState(() => _recursos = r);
    } catch (e) {
      debugPrint('Error al leer recursos: $e');
      if (!mounted) return;
      setState(() {
        _recursos = const [];
        _errorRecursos = true;
      });
    }
    _intentarSeleccionInicial();
  }

  Future<void> _iniciarGps(UbicacionService ubicacion) async {
    _esperaGps = Timer(const Duration(seconds: 3), () {
      _gpsAgotado = true;
      if (mounted) setState(() {});
      _intentarSeleccionInicial();
    });
    final permiso = await ubicacion.verificarPermiso(solicitar: true);
    if (!mounted) return;
    if (permiso != PermisoUbicacion.concedido) {
      setState(() => _gpsAgotado = true);
      _intentarSeleccionInicial();
      return;
    }
    _subs.add(
      ubicacion.seguir().listen(
        (p) {
          final primera = _posicion == null;
          setState(() {
            _posicion = p;
            _posicionAprox = false;
          });
          if (primera &&
              _mapaListo &&
              _seleccion == null &&
              _limites.contains(LatLng(p.lat, p.lon))) {
            _mapa.move(LatLng(p.lat, p.lon), _mapa.camera.zoom);
          }
          _intentarSeleccionInicial();
        },
        onError: (Object e) {
          debugPrint('GPS no disponible: $e');
          if (mounted) setState(() => _gpsAgotado = true);
          _intentarSeleccionInicial();
        },
      ),
    );
  }

  /// A4: incidente nuevo con el mapa abierto; si es Rojo, sonido y vibración.
  void _alRecibirIncidente(Incidente i) {
    if (!mounted) return;
    if (i.prioridad == Prioridad.rojo) {
      SystemSound.play(SystemSoundType.alert);
      HapticFeedback.vibrate();
    }
    mostrarMensaje(
      context,
      'Nuevo incidente: ${i.categoria?.nombre ?? 'Alerta'}',
    );
  }

  void _intentarSeleccionInicial() {
    final tipo = _pendienteMasCercano;
    if (tipo == null || !_mapaListo || _recursos == null) return;
    if (_posicion == null && !_gpsAgotado) return;
    _pendienteMasCercano = null;
    _masCercano(tipo);
  }

  double? _distancia(double? lat, double? lon) {
    final p = _posicion;
    if (p == null || lat == null || lon == null) return null;
    return distanciaHaversine(p.lat, p.lon, lat, lon);
  }

  String _textoDistancia(double? lat, double? lon) {
    final d = _distancia(lat, lon);
    if (d == null)
      return lat == null ? 'Sin ubicación' : 'Distancia no disponible';
    return '${formatearDistancia(d)}${_posicionAprox && _gpsAgotado ? ' (aprox.)' : ''}';
  }

  void _masCercano(TipoRecurso tipo) {
    final candidatos =
        (_recursos ?? const <RecursoMapa>[])
            .where((r) => r.tipo == tipo)
            .toList();
    if (candidatos.isEmpty) {
      mostrarMensaje(context, 'No hay marcadores de este tipo.');
      return;
    }
    if (_posicion == null) {
      mostrarMensaje(
        context,
        'Sin señal de GPS. No se puede calcular el más cercano.',
      );
      return;
    }
    candidatos.sort(
      (a, b) => _distancia(a.lat, a.lon)!.compareTo(_distancia(b.lat, b.lon)!),
    );
    final r = candidatos.first;
    setState(() {
      _capas.add(tipo.codigo);
      _vistaLista = false;
    });
    _seleccionar(r, LatLng(r.lat, r.lon));
    mostrarMensaje(context, '${r.nombre}: ${_textoDistancia(r.lat, r.lon)}');
  }

  void _seleccionar(Object elemento, LatLng? punto) {
    setState(() {
      _seleccion = elemento;
      if (punto != null) _vistaLista = false;
    });
    if (punto != null && _mapaListo)
      _mapa.move(punto, _mapa.camera.zoom < 17 ? 17 : _mapa.camera.zoom);
    if (punto == null) _mostrarDetalleSinMapa(elemento);
  }

  void _mostrarDetalleSinMapa(Object elemento) {
    showModalBottomSheet(
      context: context,
      builder:
          (_) => SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: _tarjeta(elemento, flotante: false),
            ),
          ),
    );
  }

  void _guardarCapas() =>
      AppScope.of(context).prefs.setStringList(_prefCapas, _capas.toList());

  void _elegirCapas() {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setSheet) {
              Widget fila(
                String clave,
                String titulo,
                IconData icono,
                Color color,
              ) => CheckboxListTile(
                value: _capas.contains(clave),
                secondary: Icon(icono, color: color),
                title: Text(titulo),
                onChanged: (v) {
                  setState(
                    () => v == true ? _capas.add(clave) : _capas.remove(clave),
                  );
                  setSheet(() {});
                  _guardarCapas();
                },
              );
              return SafeArea(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    const ListTile(
                      title: Text(
                        'Capas visibles',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    fila(
                      _capaIncidentes,
                      'Incidentes',
                      Icons.report,
                      colorPrioridad(Prioridad.rojo),
                    ),
                    for (final t in TipoRecurso.values)
                      fila(
                        t.codigo,
                        t.nombre,
                        iconoRecurso(t),
                        colorRecurso(t),
                      ),
                  ],
                ),
              );
            },
          ),
    );
  }

  void _elegirMasCercano() {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => SafeArea(
            child: ListView(
              shrinkWrap: true,
              children: [
                const ListTile(
                  title: Text(
                    '¿Qué buscas?',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                for (final t in TipoRecurso.values)
                  ListTile(
                    leading: Icon(iconoRecurso(t), color: colorRecurso(t)),
                    title: Text(t.nombre),
                    onTap: () {
                      Navigator.pop(context);
                      _masCercano(t);
                    },
                  ),
              ],
            ),
          ),
    );
  }

  List<RecursoMapa> get _recursosVisibles =>
      (_recursos ?? const <RecursoMapa>[])
          .where((r) => _capas.contains(r.tipo.codigo))
          .toList();

  List<Incidente> get _incidentesVisibles =>
      _capas.contains(_capaIncidentes) ? _incidentes : const [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Radar'),
        actions: [
          IconButton(
            tooltip: 'Capas',
            icon: const Icon(Icons.layers),
            onPressed: _elegirCapas,
          ),
        ],
      ),
      body: Column(
        children: [
          ..._avisos(),
          Expanded(
            child: Stack(
              children: [
                _mapaWidget(),
                if (!_vistaLista) ...[
                  if (_seleccion == null)
                    const Positioned(left: 12, bottom: 12, child: _Leyenda())
                  else
                    Positioned(
                      left: 12,
                      right: 12,
                      bottom: 12,
                      child: _tarjeta(_seleccion!),
                    ),
                ],
                if (_vistaLista) Positioned.fill(child: _lista()),
              ],
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: bordeSuave)),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: Icon(
                          _vistaLista
                              ? Icons.map_rounded
                              : Icons.view_list_rounded,
                        ),
                        label: Text(_vistaLista ? 'Mapa' : 'Lista'),
                        onPressed:
                            () => setState(() => _vistaLista = !_vistaLista),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        icon: const Icon(Icons.near_me_rounded),
                        label: const Text('Más cercano'),
                        onPressed: _elegirMasCercano,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _avisos() {
    final avisos = <Widget>[];
    if (_posicion == null && _gpsAgotado) {
      avisos.add(
        const Aviso(
          'Sin señal de GPS. Las distancias no están disponibles.',
          icono: Icons.gps_off,
        ),
      );
    } else if (_posicion != null && _posicionAprox && _gpsAgotado) {
      avisos.add(
        Aviso(
          'Sin señal de GPS. Usando tu última posición conocida (${formatearAntiguedad(_posicion!.hora)}).',
          icono: Icons.gps_not_fixed,
        ),
      );
    }
    if (_errorRecursos) {
      avisos.add(
        const Aviso(
          'No se pudieron cargar los recursos.',
          icono: Icons.error_outline,
        ),
      );
    }
    return [
      for (final a in avisos)
        Padding(padding: const EdgeInsets.fromLTRB(8, 8, 8, 0), child: a),
    ];
  }

  Widget _mapaWidget() => LayoutBuilder(
    builder: (context, c) => _flutterMap(_zoomMinimo(c.biggest)),
  );

  /// Zoom mínimo con el que el campus cubre toda la vista, para que al alejarse
  /// nunca se vea nada fuera de él.
  static double _zoomMinimo(Size vista) {
    const crs = Epsg3857();
    final no = crs.latLngToOffset(_limites.northWest, 0);
    final se = crs.latLngToOffset(_limites.southEast, 0);
    final ancho = se.dx - no.dx;
    final alto = se.dy - no.dy;
    if (vista.isEmpty || !vista.isFinite) return 15;
    final escala = math.max(vista.width / ancho, vista.height / alto);
    // Margen pequeño para que el redondeo no deje la vista fuera del límite.
    return math.log(escala) / math.ln2 + 0.01;
  }

  Widget _flutterMap(double zoomMinimo) {
    final pos = _posicion;
    return FlutterMap(
      mapController: _mapa,
      options: MapOptions(
        initialCenter: _centroInicial,
        initialZoom: zoomMinimo,
        minZoom: zoomMinimo,
        maxZoom: 20,
        // La vista completa queda siempre dentro del campus.
        cameraConstraint: CameraConstraint.contain(bounds: _limites),
        backgroundColor: const Color(0xFFD7EBD5),
        onTap: (_, __) => setState(() => _seleccion = null),
        onMapReady: () {
          _mapaListo = true;
          _intentarSeleccionInicial();
        },
      ),
      children: [
        // La cuadrícula queda debajo: se ve donde no hay teselas (sin red ni caché).
        PolylineLayer(polylines: _cuadricula),
        // Teselas de OpenStreetMap; flutter_map las guarda en caché al verlas
        // (Android/iOS), así que la zona ya visitada sigue visible sin internet.
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.tesis.aplicacion',
          maxNativeZoom: 19,
          tileBounds: _limites,
        ),
        MarkerLayer(
          markers: [
            for (final r in _recursosVisibles)
              Marker(
                point: LatLng(r.lat, r.lon),
                width: 44,
                height: 44,
                child: _MarcadorRecurso(
                  recurso: r,
                  seleccionado: identical(_seleccion, r),
                  onTap: () => _seleccionar(r, LatLng(r.lat, r.lon)),
                ),
              ),
            for (final i in _incidentesVisibles.where((i) => i.tieneUbicacion))
              Marker(
                point: LatLng(i.lat!, i.lon!),
                width: 56,
                height: 56,
                child: _MarcadorIncidente(
                  incidente: i,
                  seleccionado:
                      _seleccion is Incidente &&
                      (_seleccion as Incidente).msgId == i.msgId,
                  onTap: () => _seleccionar(i, LatLng(i.lat!, i.lon!)),
                ),
              ),
            if (pos != null)
              Marker(
                point: LatLng(pos.lat, pos.lon),
                width: 40,
                height: 40,
                child: _MarcadorPropio(aprox: _posicionAprox && _gpsAgotado),
              ),
          ],
        ),
        // Atribución obligatoria según la política de uso de OSM.
        const SimpleAttributionWidget(
          source: Text('OpenStreetMap contributors'),
          alignment: Alignment.topRight,
        ),
      ],
    );
  }

  Widget _lista() {
    final incidentes = [..._incidentesVisibles]..sort((a, b) {
      final p = a.prioridad.orden.compareTo(b.prioridad.orden);
      if (p != 0) return p;
      // "Sin atención" primero; en el MVP todos están en estado Emitido.
      final e = a.estadoAtencion.index.compareTo(b.estadoAtencion.index);
      if (e != 0) return e;
      return (_distancia(a.lat, a.lon) ?? double.infinity).compareTo(
        _distancia(b.lat, b.lon) ?? double.infinity,
      );
    });
    final recursos =
        _recursosVisibles..sort(
          (a, b) => (_distancia(a.lat, a.lon) ?? 0).compareTo(
            _distancia(b.lat, b.lon) ?? 0,
          ),
        );

    return ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          if (_capas.contains(_capaIncidentes)) ...[
            const _Encabezado('Incidentes'),
            if (incidentes.isEmpty)
              const Padding(
                padding: EdgeInsets.all(12),
                child: Text('No hay incidentes activos'),
              ),
            for (final i in incidentes)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Card(
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    leading: IconoSuave(
                      iconoCategoria(i.categoria),
                      color: colorPrioridad(i.prioridad),
                      tamano: 42,
                    ),
                    title: Text(
                      _tituloIncidente(i),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      '${_textoDistancia(i.lat, i.lon)} · ${formatearAntiguedad(i.horaRecepcionLocal)} · Sin atención',
                    ),
                    trailing: PrioridadChip(i.prioridad),
                    onTap:
                        () => _seleccionar(
                          i,
                          i.tieneUbicacion ? LatLng(i.lat!, i.lon!) : null,
                        ),
                  ),
                ),
              ),
          ],
          if (recursos.isNotEmpty) ...[
            const _Encabezado('Recursos'),
            for (final r in recursos)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Card(
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    leading: IconoSuave(
                      iconoRecurso(r.tipo),
                      color: colorRecurso(r.tipo),
                      tamano: 42,
                    ),
                    title: Text(
                      r.nombre,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      '${r.tipo.nombre} · ${_textoDistancia(r.lat, r.lon)}',
                    ),
                    onTap: () => _seleccionar(r, LatLng(r.lat, r.lon)),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  String _tituloIncidente(Incidente i) {
    final nombre = i.categoria?.nombre ?? 'Alerta';
    return i.origen == Origen.propio ? '$nombre (tu alerta)' : nombre;
  }

  Widget _tarjeta(Object elemento, {bool flotante = true}) {
    final contenido = switch (elemento) {
      Incidente i => _contenidoIncidente(i),
      RecursoMapa r => _contenidoRecurso(r),
      _ => const SizedBox.shrink(),
    };
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow:
            flotante
                ? const [
                  BoxShadow(
                    color: Color(0x29000000),
                    blurRadius: 20,
                    offset: Offset(0, 8),
                  ),
                ]
                : null,
      ),
      child: Card(
        child: Padding(padding: const EdgeInsets.all(16), child: contenido),
      ),
    );
  }

  Widget _contenidoIncidente(Incidente i) {
    final texto =
        i.esSos
            ? 'SOS de un toque'
            : (i.texto.isEmpty ? '(sin mensaje)' : '«${i.texto}»');
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconoSuave(
              iconoCategoria(i.categoria),
              color: colorPrioridad(i.prioridad),
              tamano: 42,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _tituloIncidente(i),
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            PrioridadChip(i.prioridad),
          ],
        ),
        const SizedBox(height: 8),
        Text(texto, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 6),
        Text(
          '${_textoDistancia(i.lat, i.lon)} · ${formatearAntiguedad(i.horaRecepcionLocal)}',
        ),
        const SizedBox(height: 4),
        const Row(
          children: [
            Icon(Icons.hourglass_empty, size: 16),
            SizedBox(width: 4),
            Text('Emitido · Sin atención'),
          ],
        ),
        if (i.categoria == Categorias.medica) ...[
          const SizedBox(height: 8),
          OutlinedButton.icon(
            icon: const Icon(Icons.healing),
            label: const Text('Guía de primeros auxilios'),
            onPressed:
                () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const PrimerosAuxiliosScreen(),
                  ),
                ),
          ),
        ],
      ],
    );
  }

  Widget _contenidoRecurso(RecursoMapa r) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconoSuave(
              iconoRecurso(r.tipo),
              color: colorRecurso(r.tipo),
              tamano: 42,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                r.nombre,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          r.tipo.nombre,
          style: TextStyle(
            color: colorRecurso(r.tipo),
            fontWeight: FontWeight.w600,
          ),
        ),
        if (r.descripcion != null) ...[
          const SizedBox(height: 4),
          Text(r.descripcion!),
        ],
        const SizedBox(height: 4),
        Text('Distancia: ${_textoDistancia(r.lat, r.lon)}'),
      ],
    );
  }

  /// Cuadrícula de referencia (~110 m) dentro del área del campus, con su contorno.
  static List<Polyline> _crearCuadricula(LatLngBounds b) {
    const paso = 0.001;
    const color = Color(0xFFA5D6A7);
    final latIni = (b.south / paso).ceil();
    final latFin = (b.north / paso).floor();
    final lonIni = (b.west / paso).ceil();
    final lonFin = (b.east / paso).floor();
    return [
      for (var k = latIni; k <= latFin; k++)
        Polyline(
          points: [LatLng(k * paso, b.west), LatLng(k * paso, b.east)],
          color: color,
          strokeWidth: 1,
        ),
      for (var k = lonIni; k <= lonFin; k++)
        Polyline(
          points: [LatLng(b.south, k * paso), LatLng(b.north, k * paso)],
          color: color,
          strokeWidth: 1,
        ),
      Polyline(
        points: [
          b.southWest,
          b.northWest,
          b.northEast,
          b.southEast,
          b.southWest,
        ],
        color: verdeApp,
        strokeWidth: 2,
      ),
    ];
  }
}

class _Encabezado extends StatelessWidget {
  const _Encabezado(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 12, 4, 4),
    child: Text(
      texto,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
    ),
  );
}

class _MarcadorIncidente extends StatelessWidget {
  const _MarcadorIncidente({
    required this.incidente,
    required this.seleccionado,
    required this.onTap,
  });

  final Incidente incidente;
  final bool seleccionado;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = colorPrioridad(incidente.prioridad);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: fondoPrioridad(incidente.prioridad),
          border: Border.all(color: color, width: seleccionado ? 5 : 3),
          boxShadow: const [
            BoxShadow(
              color: Color(0x40000000),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: CircleAvatar(
            radius: 16,
            backgroundColor: color,
            child: Icon(
              iconoCategoria(incidente.categoria),
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}

class _MarcadorRecurso extends StatelessWidget {
  const _MarcadorRecurso({
    required this.recurso,
    required this.seleccionado,
    required this.onTap,
  });

  final RecursoMapa recurso;
  final bool seleccionado;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Center(
      child: Container(
        width: seleccionado ? 40 : 32,
        height: seleccionado ? 40 : 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colorRecurso(recurso.tipo),
          border: Border.all(color: Colors.white, width: seleccionado ? 3 : 2),
          boxShadow: const [
            BoxShadow(
              color: Color(0x40000000),
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Icon(iconoRecurso(recurso.tipo), color: Colors.white, size: 18),
      ),
    ),
  );
}

class _MarcadorPropio extends StatelessWidget {
  const _MarcadorPropio({required this.aprox});

  final bool aprox;

  @override
  Widget build(BuildContext context) {
    final color = aprox ? Colors.grey : const Color(0xFF1976D2);
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.25),
      ),
      child: Center(
        child: Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            border: Border.all(color: Colors.white, width: 3),
          ),
        ),
      ),
    );
  }
}

/// Leyenda plegable de capas (SRS 3.1.1, layout del mapa).
class _Leyenda extends StatefulWidget {
  const _Leyenda();

  @override
  State<_Leyenda> createState() => _LeyendaState();
}

class _LeyendaState extends State<_Leyenda> {
  bool _abierta = false;

  @override
  Widget build(BuildContext context) {
    Widget item(IconData icono, Color color, String texto) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 18, color: color),
          const SizedBox(width: 6),
          Text(texto),
        ],
      ),
    );
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: sombraSuave,
      ),
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => setState(() => _abierta = !_abierta),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child:
                _abierta
                    ? Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final p in Prioridad.values)
                          item(
                            Icons.flag,
                            colorPrioridad(p),
                            'Prioridad ${p.etiqueta.toLowerCase()}',
                          ),
                        for (final t in TipoRecurso.values)
                          item(iconoRecurso(t), colorRecurso(t), t.nombre),
                        item(
                          Icons.circle,
                          const Color(0xFF1976D2),
                          'Tu posición',
                        ),
                      ],
                    )
                    : const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 18,
                          color: verdeApp,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Leyenda',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
          ),
        ),
      ),
    );
  }
}
