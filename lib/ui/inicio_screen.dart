import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_scope.dart';
import 'dart:async';

import '../domain/atencion.dart';
import '../domain/modelos.dart';
import '../services/modem_service.dart';
import 'nueva_alerta_screen.dart';
import 'primeros_auxilios_screen.dart';
import 'radar_screen.dart';
import 'safety_check_screen.dart';
import 'sos_screen.dart';
import 'tema.dart';
import 'widgets.dart';

/// Pantalla principal: SOS siempre visible y accesos a CU-01, 03, 04 y 06.
class InicioScreen extends StatefulWidget {
  const InicioScreen({super.key});

  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
  bool _enviandoSos = false;
  StreamSubscription<Acuse>? _acusesNuevos;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _acusesNuevos ??= AppScope.of(
      context,
    ).procesador.acusesNuevos.listen(_alRecibirAcuse);
  }

  @override
  void dispose() {
    _acusesNuevos?.cancel();
    super.dispose();
  }

  /// CU-11: avisa a la persona afectada cuando alguien responde a su alerta.
  Future<void> _alRecibirAcuse(Acuse a) async {
    final deps = AppScope.of(context);
    final incidente = await deps.incidentes.observar(a.refMsgId).first;
    if (!mounted || incidente == null || incidente.origen != Origen.propio) {
      return;
    }
    HapticFeedback.vibrate();
    mostrarMensaje(context, switch (a.tipo) {
      TipoAcuse.enCamino => 'Alguien va en camino a tu alerta.',
      TipoAcuse.llegue => 'Alguien llegó al lugar de tu alerta.',
      TipoAcuse.resuelto => 'Tu alerta se marcó como resuelta.',
    });
  }

  Future<void> _sos() async {
    if (_enviandoSos) return;
    setState(() => _enviandoSos = true);
    final resultado = await AppScope.of(context).envio.emitirSos();
    HapticFeedback.heavyImpact();
    if (!mounted) return;
    setState(() => _enviandoSos = false);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (_) => SosScreen(
              incidente: resultado.incidente!,
              resultadoInicial: resultado.resultado,
            ),
      ),
    );
  }

  void _abrir(Widget pantalla) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => pantalla));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cell_tower, size: 22),
            SizedBox(width: 8),
            Text('LoRa P2P'),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Ajustes',
            icon: const Icon(Icons.settings_outlined),
            onPressed:
                () => showModalBottomSheet(
                  context: context,
                  builder: (_) => const _PanelDemo(),
                ),
          ),
        ],
      ),
      body: Column(
        children: [
          const BannerModem(),
          _SosActivo(onAbrir: (i) => _abrir(SosScreen(incidente: i))),
          Expanded(
            child: Center(
              child: _BotonSos(onPressed: _sos, enviando: _enviandoSos),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: Column(
              children: [
                Row(
                  children: [
                    _Acceso(
                      icono: Icons.edit_note_rounded,
                      color: const Color(0xFFC62828),
                      texto: 'Nueva alerta',
                      detalle: 'Mensaje con categoría',
                      onTap: () => _abrir(const NuevaAlertaScreen()),
                    ),
                    const SizedBox(width: 12),
                    _Acceso(
                      icono: Icons.verified_user_rounded,
                      color: const Color(0xFF2E7D32),
                      texto: 'Estoy a salvo',
                      detalle: 'Safety Check',
                      onTap: () => _abrir(const SafetyCheckScreen()),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _Acceso(
                      icono: Icons.radar_rounded,
                      color: const Color(0xFF1565C0),
                      texto: 'Radar',
                      detalle: 'Mapa sin conexión',
                      onTap: () => _abrir(const RadarScreen()),
                    ),
                    const SizedBox(width: 12),
                    _Acceso(
                      icono: Icons.medical_services_rounded,
                      color: const Color(0xFFE65100),
                      texto: 'Primeros auxilios',
                      detalle: 'Guía paso a paso',
                      onTap: () => _abrir(const PrimerosAuxiliosScreen()),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BotonSos extends StatelessWidget {
  const _BotonSos({required this.onPressed, required this.enviando});

  final VoidCallback onPressed;
  final bool enviando;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        // El botón y sus dos anillos caben en el espacio disponible.
        final total = (c.biggest.shortestSide * 0.92).clamp(190.0, 300.0);
        final lado = total * 0.78;
        return Semantics(
          button: true,
          label: 'SOS. Presiona para emergencia',
          child: SizedBox(
            width: total,
            height: total,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Anillos de halo: solo decorativos.
                _Anillo(diametro: total, alfa: 0.07),
                _Anillo(diametro: total * 0.89, alfa: 0.12),
                Container(
                  width: lado,
                  height: lado,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: rojoSos.withValues(alpha: 0.45),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Material(
                    shape: const CircleBorder(),
                    clipBehavior: Clip.antiAlias,
                    child: Ink(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          center: Alignment(-0.3, -0.4),
                          radius: 1.0,
                          colors: [Color(0xFFEF5350), rojoSos, rojoSosOscuro],
                          stops: [0.0, 0.55, 1.0],
                        ),
                      ),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: enviando ? null : onPressed,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'SOS',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: lado * 0.27,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2,
                                height: 1.0,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Text(
                                enviando
                                    ? 'Enviando…'
                                    : 'Presiona para emergencia',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.92),
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Anillo extends StatelessWidget {
  const _Anillo({required this.diametro, required this.alfa});

  final double diametro;
  final double alfa;

  @override
  Widget build(BuildContext context) => Container(
    width: diametro,
    height: diametro,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: rojoSos.withValues(alpha: alfa),
    ),
  );
}

class _Acceso extends StatelessWidget {
  const _Acceso({
    required this.icono,
    required this.texto,
    required this.detalle,
    required this.onTap,
    required this.color,
  });

  final IconData icono;
  final String texto;
  final String detalle;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: sombraSuave,
      ),
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconoSuave(icono, color: color, tamano: 42),
                const SizedBox(height: 12),
                Text(
                  texto,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  detalle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: textoSecundario,
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

/// Acceso rápido al último SOS propio de la última hora.
class _SosActivo extends StatefulWidget {
  const _SosActivo({required this.onAbrir});

  final ValueChanged<Incidente> onAbrir;

  @override
  State<_SosActivo> createState() => _SosActivoState();
}

class _SosActivoState extends State<_SosActivo> {
  Stream<List<Incidente>>? _incidentes;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _incidentes ??= AppScope.of(context).incidentes.observarTodos();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Incidente>>(
      stream: _incidentes,
      builder: (context, snap) {
        final limite = DateTime.now().subtract(const Duration(hours: 1));
        final sos = snap.data?.where(
          (i) =>
              i.esSos &&
              i.origen == Origen.propio &&
              i.horaRecepcionLocal.isAfter(limite),
        );
        if (sos == null || sos.isEmpty) return const SizedBox.shrink();
        final ultimo = sos.first;
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Material(
            color: const Color(0xFFFFEBEE),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: rojoSos.withValues(alpha: 0.25)),
            ),
            child: ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              leading: const IconoSuave(Icons.sos, color: rojoSos, tamano: 38),
              title: Text(
                ultimo.estadoEnvio == EstadoEnvio.pendiente
                    ? 'Tu SOS está pendiente de envío'
                    : 'Tu SOS fue enviado',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: rojoSosOscuro,
                ),
              ),
              subtitle: StreamBuilder<List<Acuse>>(
                stream: AppScope.of(context).acuses.observarDe(ultimo.msgId),
                builder: (context, snap) {
                  final atencion = consolidarAtencion(
                    snap.data ?? const <Acuse>[],
                  );
                  return Text(
                    atencion.estado == EstadoAtencion.emitido
                        ? 'Toca para ver el detalle'
                        : atencion.resumen,
                  );
                },
              ),
              trailing: const Icon(Icons.chevron_right, color: rojoSosOscuro),
              onTap: () => widget.onAbrir(ultimo),
            ),
          ),
        );
      },
    );
  }
}

/// Controles del modo demostración (módem simulado, sin hardware).
class _PanelDemo extends StatelessWidget {
  const _PanelDemo();

  @override
  Widget build(BuildContext context) {
    final deps = AppScope.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const IconoSuave(
                  Icons.science_outlined,
                  color: verdeApp,
                  tamano: 40,
                ),
                const SizedBox(width: 12),
                Text(
                  'Modo demostración',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '${urlSimulador.isEmpty ? 'Módem simulado' : 'Simulador $urlSimulador'} · Tu ID: ${deps.senderId.toRadixString(16).toUpperCase().padLeft(8, '0')}',
              style: const TextStyle(color: textoSecundario),
            ),
            const SizedBox(height: 8),
            ValueListenableBuilder<EstadoModem>(
              valueListenable: deps.modem.estado,
              builder:
                  (context, estado, _) => SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Módem conectado'),
                    value: estado.conexion != ConexionModem.desconectado,
                    onChanged:
                        (v) =>
                            v
                                ? deps.modem.conectar()
                                : deps.modem.desconectar(),
                  ),
            ),
            if (deps.modem is ModemSimulado)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.cell_tower),
                  label: const Text('Simular alerta de otro nodo'),
                  onPressed: () {
                    deps.simularAlertaEntrante();
                    mostrarMensaje(
                      context,
                      deps.modem.estado.value.conectado
                          ? 'Alerta simulada recibida por radio.'
                          : 'Conecta el módem para recibir alertas.',
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
