import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../application/envio_service.dart';
import '../domain/geo.dart';
import '../domain/modelos.dart';
import 'tema.dart';
import 'widgets.dart';

/// CU-06: reportar "Estoy a salvo" (Safety Check).
class SafetyCheckScreen extends StatefulWidget {
  const SafetyCheckScreen({super.key});

  @override
  State<SafetyCheckScreen> createState() => _SafetyCheckScreenState();
}

class _SafetyCheckScreenState extends State<SafetyCheckScreen> {
  bool _enviando = false;
  Stream<ReporteSafetyCheck?>? _ultimoPropio;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _ultimoPropio ??= AppScope.of(context).safetyChecks.observarUltimoPropio();
  }

  Future<void> _reportar() async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('¿Estás a salvo?'),
            content: const Text(
              'Se avisará a la red que te encuentras a salvo.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Confirmo que estoy a salvo'),
              ),
            ],
          ),
    );
    if (confirmado != true || !mounted) return;
    setState(() => _enviando = true);
    final r = await AppScope.of(context).envio.reportarASalvo();
    if (!mounted) return;
    setState(() => _enviando = false);
    mostrarMensaje(context, switch (r) {
      ResultadoEnvio.enviado => 'Se avisó que estás a salvo.',
      ResultadoEnvio.pendiente =>
        'Módem sin conexión. Tus envíos se harán al reconectar.',
      ResultadoEnvio.errorBaseDatos =>
        'No se pudo guardar el reporte. Intenta de nuevo.',
      ResultadoEnvio.limiteExcedido =>
        'Ya enviaste varios reportes. Espera un minuto.',
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Safety Check')),
      body: StreamBuilder<ReporteSafetyCheck?>(
        stream: _ultimoPropio,
        builder: (context, snap) {
          final ultimo = snap.data;
          final reportado = ultimo != null;
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
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                    child: Column(
                      children: [
                        Container(
                          width: 84,
                          height: 84,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(
                              0xFF2E7D32,
                            ).withValues(alpha: 0.10),
                          ),
                          child: Icon(
                            reportado
                                ? Icons.verified_user_rounded
                                : Icons.health_and_safety_rounded,
                            size: 46,
                            color: const Color(0xFF2E7D32),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          reportado
                              ? 'Ya reportaste que estás a salvo'
                              : '¿Estás a salvo?',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          reportado
                              ? _descripcion(ultimo)
                              : 'Informa a la red con un toque',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: textoSecundario,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 24),
                        BotonGrande(
                          alto: 64,
                          color: const Color(0xFF2E7D32),
                          icono:
                              reportado
                                  ? Icons.replay_rounded
                                  : Icons.check_circle_rounded,
                          texto:
                              _enviando
                                  ? 'ENVIANDO…'
                                  : reportado
                                  ? 'REENVIAR'
                                  : 'ESTOY A SALVO',
                          onPressed: _enviando ? null : _reportar,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (ultimo?.estadoEnvio == EstadoEnvio.pendiente) ...[
                const SizedBox(height: 12),
                const Aviso(
                  'Módem sin conexión. Tu reporte se enviará al reconectar.',
                ),
              ],
              if (ultimo != null) ...[
                const SizedBox(height: 12),
                const Aviso(
                  'Reenvía si crees que tu reporte no llegó (por ejemplo, sin cobertura).',
                  icono: Icons.info_outline,
                  color: verdeApp,
                  fondo: Color(0xFFE8F5E9),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  String _descripcion(ReporteSafetyCheck r) {
    final estado =
        r.estadoEnvio == EstadoEnvio.pendiente
            ? 'pendiente de envío'
            : 'enviado';
    return 'Último reporte ${formatearAntiguedad(r.horaRecepcionLocal)} · $estado';
  }
}
