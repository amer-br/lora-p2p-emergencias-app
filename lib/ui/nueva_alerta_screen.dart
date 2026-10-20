import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_scope.dart';
import '../application/envio_service.dart';
import '../domain/categoria.dart';
import '../domain/modelos.dart';
import '../protocol/tramas.dart';
import '../services/ubicacion_service.dart';
import 'tema.dart';
import 'widgets.dart';

/// CU-01: redactar y emitir un mensaje de alerta.
class NuevaAlertaScreen extends StatefulWidget {
  const NuevaAlertaScreen({super.key});

  @override
  State<NuevaAlertaScreen> createState() => _NuevaAlertaScreenState();
}

class _NuevaAlertaScreenState extends State<NuevaAlertaScreen> {
  static const frasesRapidas = ['Herido', 'Atrapado', 'Necesito ayuda'];

  final _texto = TextEditingController();
  Categoria? _categoria;
  bool _enviando = false;

  // Estado del GPS mostrado antes de enviar.
  PermisoUbicacion? _permiso;
  Posicion? _posicion;
  bool _buscandoGps = true;

  @override
  void initState() {
    super.initState();
    _texto.addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) => _leerGps());
  }

  @override
  void dispose() {
    _texto.dispose();
    super.dispose();
  }

  Future<void> _leerGps() async {
    final ubicacion = AppScope.of(context).ubicacion;
    final permiso = await ubicacion.verificarPermiso();
    final pos =
        permiso == PermisoUbicacion.concedido
            ? await ubicacion.posicionParaEnvio()
            : null;
    if (!mounted) return;
    setState(() {
      _permiso = permiso;
      _posicion = pos;
      _buscandoGps = false;
    });
  }

  void _usarFrase(String frase) {
    if (bytesUtf8(frase) > maxBytesTexto) return;
    _texto.text = frase;
    _texto.selection = TextSelection.collapsed(offset: frase.length);
  }

  /// E3: si el permiso está denegado, se explica y se solicita; si se rechaza,
  /// el usuario puede confirmar el envío sin ubicación. Null = cancelar.
  Future<bool?> _resolverPermiso() async {
    final ubicacion = AppScope.of(context).ubicacion;
    if (await ubicacion.verificarPermiso() == PermisoUbicacion.concedido)
      return true;
    if (!mounted) return null;
    final solicitar = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Permitir ubicación'),
            content: const Text(
              'Tu ubicación ayuda a que otras personas te encuentren. ¿Deseas permitir el acceso?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('No'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Permitir'),
              ),
            ],
          ),
    );
    if (solicitar == true &&
        await ubicacion.verificarPermiso(solicitar: true) ==
            PermisoUbicacion.concedido) {
      return true;
    }
    if (!mounted) return null;
    final sinUbicacion = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Enviar sin ubicación'),
            content: const Text(
              'La alerta se enviará sin tu posición. ¿Continuar?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Enviar'),
              ),
            ],
          ),
    );
    return sinUbicacion == true ? false : null;
  }

  Future<void> _enviar() async {
    final categoria = _categoria;
    if (categoria == null || _enviando) return;
    final usarUbicacion = await _resolverPermiso();
    if (usarUbicacion == null || !mounted) return;
    setState(() => _enviando = true);
    final envio = AppScope.of(context).envio;
    final r = await envio.emitirAlerta(
      categoria,
      _texto.text,
      usarUbicacion: usarUbicacion,
    );
    if (!mounted) return;
    setState(() => _enviando = false);
    final mensaje = switch (r.resultado) {
      ResultadoEnvio.enviado when r.sinUbicacion =>
        'Enviada sin ubicación: no hay señal de GPS.',
      ResultadoEnvio.enviado => 'Alerta enviada a la red.',
      ResultadoEnvio.pendiente =>
        'Módem sin conexión. Tus envíos se harán al reconectar.',
      ResultadoEnvio.errorBaseDatos =>
        'No se pudo guardar la alerta. Intenta de nuevo.',
      ResultadoEnvio.limiteExcedido =>
        'Espera un momento antes de volver a enviar.',
    };
    mostrarMensaje(context, mensaje);
    if (r.resultado != ResultadoEnvio.errorBaseDatos)
      Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bytes = bytesUtf8(_texto.text);
    final lleno = bytes / maxBytesTexto;
    return Scaffold(
      appBar: AppBar(title: const Text('Nueva alerta')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                children: [
                  const TituloSeccion('Categoría'),
                  Row(
                    children: [
                      for (final c in Categorias.seleccionables) ...[
                        if (c != Categorias.seleccionables.first)
                          const SizedBox(width: 10),
                        Expanded(child: _tarjetaCategoria(c)),
                      ],
                    ],
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 200),
                    child:
                        _categoria == null
                            ? const SizedBox(width: double.infinity)
                            : Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Row(
                                children: [
                                  const Text(
                                    'Prioridad asociada',
                                    style: TextStyle(
                                      color: textoSecundario,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  PrioridadChip(_categoria!.prioridad),
                                ],
                              ),
                            ),
                  ),
                  const SizedBox(height: 24),
                  TituloSeccion(
                    'Mensaje',
                    trailing: Text(
                      '$bytes/$maxBytesTexto bytes',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: lleno >= 1 ? rojoSos : textoSecundario,
                      ),
                    ),
                  ),
                  TextField(
                    controller: _texto,
                    maxLines: 3,
                    inputFormatters: [_LimiteBytesUtf8(maxBytesTexto)],
                    decoration: const InputDecoration(
                      hintText: 'Escribe un mensaje breve (opcional)…',
                    ),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: lleno,
                      minHeight: 4,
                      color: lleno >= 1 ? rojoSos : verdeApp,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const TituloSeccion('Frases rápidas'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final f in frasesRapidas)
                        ActionChip(
                          avatar: const Icon(
                            Icons.bolt_rounded,
                            size: 18,
                            color: verdeApp,
                          ),
                          label: Text(f),
                          onPressed: () => _usarFrase(f),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _estadoGps(),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: bordeSuave)),
              ),
              child: BotonGrande(
                color: rojoSos,
                icono: _categoria == null ? null : Icons.send_rounded,
                texto:
                    _enviando
                        ? 'ENVIANDO…'
                        : _categoria == null
                        ? 'ELIGE UNA CATEGORÍA'
                        : 'ENVIAR ALERTA',
                onPressed: _categoria == null || _enviando ? null : _enviar,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tarjetaCategoria(Categoria c) {
    final seleccionada = _categoria == c;
    final color = colorPrioridad(c.prioridad);
    return Semantics(
      selected: seleccionada,
      button: true,
      label: '${c.nombre}, prioridad ${c.prioridad.etiqueta}',
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: seleccionada ? fondoPrioridad(c.prioridad) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: seleccionada ? color : bordeSuave,
            width: seleccionada ? 2 : 1,
          ),
          boxShadow: seleccionada ? null : sombraSuave,
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => setState(() => _categoria = c),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
              child: Column(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: seleccionada ? color : fondoPrioridad(c.prioridad),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      iconoCategoria(c),
                      color: seleccionada ? Colors.white : color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    c.nombre,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: seleccionada ? color : textoPrincipal,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _estadoGps() {
    if (_buscandoGps) {
      return const Aviso('Buscando señal de GPS…', icono: Icons.gps_not_fixed);
    }
    if (_permiso != PermisoUbicacion.concedido) {
      return const Aviso(
        'Sin permiso de ubicación. Se pedirá al enviar.',
        icono: Icons.location_disabled,
      );
    }
    final pos = _posicion;
    if (pos == null) {
      return const Aviso(
        'Sin señal de GPS. La alerta se enviará sin ubicación.',
        icono: Icons.gps_off,
      );
    }
    final precision =
        pos.precisionM == null ? '' : ' (±${pos.precisionM!.round()} m)';
    return Aviso.ok('GPS listo$precision', icono: Icons.location_on);
  }
}

/// Impide superar el límite en bytes UTF-8 (las letras con acento cuentan 2).
class _LimiteBytesUtf8 extends TextInputFormatter {
  _LimiteBytesUtf8(this.max);

  final int max;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue anterior,
    TextEditingValue nuevo,
  ) => bytesUtf8(nuevo.text) > max ? anterior : nuevo;
}
