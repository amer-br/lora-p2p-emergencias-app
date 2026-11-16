import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_scope.dart';
import '../application/envio_service.dart';
import '../domain/geo.dart';
import '../domain/atencion.dart';
import '../domain/modelos.dart';
import 'atencion_widgets.dart';
import 'tema.dart';
import 'widgets.dart';

/// CU-02: confirmación del SOS enviado, con opción de reenviarlo.
class SosScreen extends StatefulWidget {
  const SosScreen({super.key, required this.incidente, this.resultadoInicial});

  final Incidente incidente;
  final ResultadoEnvio? resultadoInicial;

  @override
  State<SosScreen> createState() => _SosScreenState();
}

class _SosScreenState extends State<SosScreen> {
  bool _reenviando = false;

  Future<void> _reenviar(Incidente i) async {
    setState(() => _reenviando = true);
    final r = await AppScope.of(context).envio.reenviar(i);
    HapticFeedback.mediumImpact();
    if (!mounted) return;
    setState(() => _reenviando = false);
    mostrarMensaje(
      context,
      r == ResultadoEnvio.enviado
          ? 'SOS reenviado a la red.'
          : 'Módem sin conexión. Tus envíos se harán al reconectar.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final deps = AppScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('SOS'), backgroundColor: rojoSos),
      body: StreamBuilder<Incidente?>(
        stream: deps.incidentes.observar(widget.incidente.msgId),
        initialData: widget.incidente,
        builder: (context, snap) {
          final i = snap.data ?? widget.incidente;
          final enviado = i.estadoEnvio != EstadoEnvio.pendiente;
          final hora = TimeOfDay.fromDateTime(
            i.horaRecepcionLocal,
          ).format(context);
          final colorEstado = enviado ? rojoSos : const Color(0xFF7A5B00);
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: sombraSuave,
                ),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
                    child: Column(
                      children: [
                        Container(
                          width: 92,
                          height: 92,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colorEstado.withValues(alpha: 0.10),
                          ),
                          child: Icon(
                            enviado
                                ? Icons.check_circle_rounded
                                : Icons.schedule_send_rounded,
                            size: 56,
                            color: colorEstado,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          !enviado
                              ? 'SOS pendiente de envío'
                              : i.tieneUbicacion
                              ? 'SOS enviado'
                              : 'SOS enviado sin ubicación',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 18),
                        _Dato(
                          icono: Icons.schedule_rounded,
                          etiqueta: 'Hora',
                          valor:
                              '$hora (${formatearAntiguedad(i.horaRecepcionLocal)})',
                        ),
                        const Divider(height: 20),
                        _Dato(
                          icono:
                              i.tieneUbicacion
                                  ? Icons.location_on_rounded
                                  : Icons.location_off_rounded,
                          etiqueta: 'Ubicación',
                          valor:
                              i.tieneUbicacion
                                  ? '${i.lat!.toStringAsFixed(5)}, ${i.lon!.toStringAsFixed(5)}'
                                  : 'No disponible (sin señal de GPS)',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (!enviado)
                const Aviso(
                  'Módem sin conexión. Tu SOS se enviará al reconectar.',
                )
              else
                StreamBuilder<List<Acuse>>(
                  stream: deps.acuses.observarDe(i.msgId),
                  builder: (context, snap) {
                    final atencion = consolidarAtencion(
                      snap.data ?? const <Acuse>[],
                    );
                    return switch (atencion.estado) {
                      EstadoAtencion.emitido => const Aviso(
                        'Aún no hay respuesta de otros nodos. Si no llega ayuda, reenvía el SOS.',
                        icono: Icons.info_outline,
                      ),
                      EstadoAtencion.enAsistencia => Aviso.ok(
                        'Viene ayuda: ${atencion.resumen.replaceFirst('En asistencia · ', '')}.',
                        icono: Icons.directions_run_rounded,
                      ),
                      EstadoAtencion.resuelto => const Aviso.ok(
                        'Tu SOS se marcó como resuelto.',
                      ),
                    };
                  },
                ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: PanelAtencion(incidente: i),
                ),
              ),
              const SizedBox(height: 24),
              BotonGrande(
                color: rojoSos,
                icono: Icons.replay_rounded,
                texto: _reenviando ? 'Reenviando…' : 'Reenviar SOS',
                onPressed: _reenviando ? null : () => _reenviar(i),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Dato extends StatelessWidget {
  const _Dato({
    required this.icono,
    required this.etiqueta,
    required this.valor,
  });

  final IconData icono;
  final String etiqueta;
  final String valor;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icono, size: 20, color: textoSecundario),
      const SizedBox(width: 10),
      Text(etiqueta, style: const TextStyle(color: textoSecundario)),
      const SizedBox(width: 12),
      Expanded(
        child: Text(
          valor,
          textAlign: TextAlign.end,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    ],
  );
}
