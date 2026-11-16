import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_scope.dart';
import '../application/envio_service.dart';
import '../domain/atencion.dart';
import '../domain/geo.dart';
import '../domain/modelos.dart';
import 'tema.dart';
import 'widgets.dart';

/// Línea de estado de atención: icono, color y texto (RNF-5.4: nunca solo color).
class EstadoAtencionLinea extends StatelessWidget {
  const EstadoAtencionLinea(this.atencion, {super.key});

  final AtencionIncidente atencion;

  @override
  Widget build(BuildContext context) {
    final (icono, color) = estiloAtencion(atencion.estado);
    return Row(
      children: [
        Icon(icono, size: 18, color: color),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            atencion.resumen,
            style: TextStyle(color: color, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

(IconData, Color) estiloAtencion(EstadoAtencion estado) => switch (estado) {
  EstadoAtencion.emitido => (
    Icons.hourglass_empty_rounded,
    const Color(0xFF7A5B00),
  ),
  EstadoAtencion.enAsistencia => (
    Icons.directions_run_rounded,
    const Color(0xFF1565C0),
  ),
  EstadoAtencion.resuelto => (Icons.check_circle_rounded, verdeApp),
};

/// Estado de atención de un incidente con las acciones de acuse (CU-08 a
/// CU-11) y el historial de acuses. Se actualiza solo al llegar un acuse.
///
/// - En un incidente ajeno: «Voy en camino», «Llegué» y, después de llegar,
///   «Resuelto».
/// - En un incidente propio: solo «Marcar como resuelto» (la persona
///   afectada puede cerrar su propio incidente).
class PanelAtencion extends StatefulWidget {
  const PanelAtencion({super.key, required this.incidente});

  final Incidente incidente;

  @override
  State<PanelAtencion> createState() => _PanelAtencionState();
}

class _PanelAtencionState extends State<PanelAtencion> {
  Stream<List<Acuse>>? _acuses;
  TipoAcuse? _enviando;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _acuses ??= AppScope.of(context).acuses.observarDe(widget.incidente.msgId);
  }

  Future<void> _acusar(TipoAcuse tipo) async {
    if (tipo == TipoAcuse.resuelto && !await _confirmarResolver()) return;
    if (!mounted) return;
    setState(() => _enviando = tipo);
    final r = await AppScope.of(
      context,
    ).envio.emitirAcuse(widget.incidente, tipo);
    HapticFeedback.mediumImpact();
    if (!mounted) return;
    setState(() => _enviando = null);
    mostrarMensaje(context, switch (r) {
      ResultadoAcuse.enviado => switch (tipo) {
        TipoAcuse.enCamino => 'Avisaste que vas en camino.',
        TipoAcuse.llegue => 'Avisaste que llegaste al sitio.',
        TipoAcuse.resuelto => 'Incidente marcado como resuelto.',
      },
      ResultadoAcuse.pendiente =>
        'Módem sin conexión. Tu aviso se enviará al reconectar.',
      ResultadoAcuse.errorBaseDatos =>
        'No se pudo guardar el aviso. Intenta de nuevo.',
      ResultadoAcuse.limiteExcedido =>
        'Demasiados avisos seguidos. Espera un minuto.',
      ResultadoAcuse.yaEmitido => 'Ya enviaste ese aviso.',
      ResultadoAcuse.incidenteResuelto => 'Este incidente ya está resuelto.',
      ResultadoAcuse.noPuedeResolver =>
        'Para marcarlo como resuelto, primero confirma que llegaste.',
    });
  }

  Future<bool> _confirmarResolver() async =>
      await showDialog<bool>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('¿Marcar como resuelto?'),
              content: const Text(
                'Se avisará a toda la red que este incidente ya no necesita ayuda. '
                'No se puede deshacer.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Marcar como resuelto'),
                ),
              ],
            ),
      ) ??
      false;

  @override
  Widget build(BuildContext context) {
    final yo = AppScope.of(context).senderId;
    final propio = widget.incidente.senderId == yo;
    return StreamBuilder<List<Acuse>>(
      stream: _acuses,
      builder: (context, snap) {
        final acuses = snap.data ?? const <Acuse>[];
        final atencion = consolidarAtencion(acuses);
        bool hecho(TipoAcuse t) =>
            yaAcuso(miSenderId: yo, tipo: t, acuses: acuses);
        final llegue = hecho(TipoAcuse.llegue);
        final puedeCerrar = puedeResolver(
          incidente: widget.incidente,
          miSenderId: yo,
          acuses: acuses,
        );

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            EstadoAtencionLinea(atencion),
            if (!atencion.resuelto) ...[
              const SizedBox(height: 10),
              if (propio)
                _BotonAcuse(
                  tipo: TipoAcuse.resuelto,
                  texto: 'Marcar como resuelto',
                  hecho: false,
                  enviando: _enviando,
                  onPressed: _acusar,
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _BotonAcuse(
                      tipo: TipoAcuse.enCamino,
                      texto: 'Voy en camino',
                      hecho: hecho(TipoAcuse.enCamino) || llegue,
                      enviando: _enviando,
                      onPressed: _acusar,
                    ),
                    _BotonAcuse(
                      tipo: TipoAcuse.llegue,
                      texto: 'Llegué',
                      hecho: llegue,
                      enviando: _enviando,
                      onPressed: _acusar,
                    ),
                    if (puedeCerrar)
                      _BotonAcuse(
                        tipo: TipoAcuse.resuelto,
                        texto: 'Resuelto',
                        hecho: false,
                        enviando: _enviando,
                        onPressed: _acusar,
                      ),
                  ],
                ),
            ],
            if (atencion.historial.isNotEmpty) ...[
              const SizedBox(height: 10),
              _Historial(acuses: atencion.historial, yo: yo),
            ],
          ],
        );
      },
    );
  }
}

class _BotonAcuse extends StatelessWidget {
  const _BotonAcuse({
    required this.tipo,
    required this.texto,
    required this.hecho,
    required this.enviando,
    required this.onPressed,
  });

  final TipoAcuse tipo;
  final String texto;
  final bool hecho;
  final TipoAcuse? enviando;
  final ValueChanged<TipoAcuse> onPressed;

  static IconData icono(TipoAcuse t) => switch (t) {
    TipoAcuse.enCamino => Icons.directions_run_rounded,
    TipoAcuse.llegue => Icons.place_rounded,
    TipoAcuse.resuelto => Icons.check_circle_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final ocupado = enviando != null;
    return ConstrainedBox(
      // Objetivo táctil de al menos 48 dp (RNF-5.3).
      constraints: const BoxConstraints(minHeight: 48),
      child: FilledButton.tonalIcon(
        icon: Icon(hecho ? Icons.check_rounded : icono(tipo)),
        label: Text(enviando == tipo ? 'Enviando…' : texto),
        onPressed: hecho || ocupado ? null : () => onPressed(tipo),
      ),
    );
  }
}

/// Historial de acuses (CU-11): quién, qué y hace cuánto.
class _Historial extends StatelessWidget {
  const _Historial({required this.acuses, required this.yo});

  static const maxVisibles = 4;

  final List<Acuse> acuses;
  final int yo;

  @override
  Widget build(BuildContext context) {
    final visibles = acuses.take(maxVisibles);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final a in visibles)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                Icon(
                  a.estadoEnvio == EstadoEnvio.pendiente
                      ? Icons.schedule_rounded
                      : _BotonAcuse.icono(a.tipo),
                  size: 16,
                  color: textoSecundario,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${_quien(a.senderId, yo)}: '
                    '${a.tipo.etiqueta.toLowerCase()} · '
                    '${formatearAntiguedad(a.horaRecepcionLocal)}'
                    '${a.estadoEnvio == EstadoEnvio.pendiente ? ' (pendiente)' : ''}',
                    style: const TextStyle(
                      color: textoSecundario,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        if (acuses.length > maxVisibles)
          Text(
            'y ${acuses.length - maxVisibles} avisos más',
            style: const TextStyle(color: textoSecundario, fontSize: 13),
          ),
      ],
    );
  }
}

String _quien(int senderId, int yo) {
  if (senderId == yo) return 'Tú';
  if (senderId == senderIdPanel) return 'Puesto de mando';
  return 'Nodo ${hex8(senderId)}';
}

/// Sender_ID en 8 dígitos hexadecimales, como lo muestra el panel.
String hex8(int valor) => valor.toRadixString(16).toUpperCase().padLeft(8, '0');
