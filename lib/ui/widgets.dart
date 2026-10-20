import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../domain/categoria.dart';
import '../services/modem_service.dart';
import 'tema.dart';

/// Insignia de prioridad: color, icono y texto, nunca solo color.
class PrioridadChip extends StatelessWidget {
  const PrioridadChip(this.prioridad, {super.key});

  final Prioridad prioridad;

  @override
  Widget build(BuildContext context) {
    final color = colorPrioridad(prioridad);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: fondoPrioridad(prioridad),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.flag_rounded, size: 15, color: color),
          const SizedBox(width: 4),
          Text(
            prioridad.etiqueta,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

/// Aviso no bloqueante con icono y texto (SRS 3.1.1).
class Aviso extends StatelessWidget {
  const Aviso(
    this.texto, {
    super.key,
    this.icono = Icons.warning_amber_rounded,
    this.color = const Color(0xFF7A5B00),
    this.fondo = const Color(0xFFFFF8E1),
  });

  const Aviso.ok(this.texto, {super.key, this.icono = Icons.check_circle})
    : color = verdeApp,
      fondo = const Color(0xFFE8F5E9);

  final String texto;
  final IconData icono;
  final Color color;
  final Color fondo;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(12, 12, 14, 12),
    decoration: BoxDecoration(
      color: fondo,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: color.withValues(alpha: 0.18)),
    ),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icono, color: color, size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            texto,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w500,
              height: 1.3,
            ),
          ),
        ),
      ],
    ),
  );
}

/// Título de sección en mayúsculas pequeñas, como en los mockups.
class TituloSeccion extends StatelessWidget {
  const TituloSeccion(this.texto, {super.key, this.trailing});

  final String texto;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 2, bottom: 10),
    child: Row(
      children: [
        Expanded(
          child: Text(
            texto.toUpperCase(),
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.9,
              color: textoSecundario,
            ),
          ),
        ),
        if (trailing != null) trailing!,
      ],
    ),
  );
}

/// Icono dentro de un contenedor redondeado de color suave.
class IconoSuave extends StatelessWidget {
  const IconoSuave(
    this.icono, {
    super.key,
    required this.color,
    this.tamano = 44,
  });

  final IconData icono;
  final Color color;
  final double tamano;

  @override
  Widget build(BuildContext context) => Container(
    width: tamano,
    height: tamano,
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(tamano * 0.32),
    ),
    child: Icon(icono, color: color, size: tamano * 0.55),
  );
}

/// Barra de estado del módem, visible en la pantalla principal.
class BannerModem extends StatelessWidget {
  const BannerModem({super.key});

  static const umbralBateriaBaja = 20;

  @override
  Widget build(BuildContext context) {
    final modem = AppScope.of(context).modem;
    return ValueListenableBuilder<EstadoModem>(
      valueListenable: modem.estado,
      builder: (context, estado, _) {
        final (texto, icono, color, fondo) = switch (estado.conexion) {
          ConexionModem.conectado
              when (estado.bateria ?? 100) <= umbralBateriaBaja =>
            (
              'Batería del módem al ${estado.bateria} %. Cárgalo pronto.',
              Icons.battery_alert,
              const Color(0xFF7A5B00),
              const Color(0xFFFFF8E1),
            ),
          ConexionModem.conectado => (
            'Módem conectado · Batería ${estado.bateria ?? '--'} %',
            Icons.bluetooth_connected,
            verdeApp,
            const Color(0xFFE8F5E9),
          ),
          ConexionModem.conectando => (
            'Conectando con el módem…',
            Icons.bluetooth_searching,
            const Color(0xFF7A5B00),
            const Color(0xFFFFF8E1),
          ),
          ConexionModem.desconectado => (
            'Módem sin conexión. Tus envíos se harán al reconectar.',
            Icons.bluetooth_disabled,
            const Color(0xFFB71C1C),
            const Color(0xFFFFEBEE),
          ),
        };
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          color: verdeApp,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: fondo,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(icono, size: 18, color: color),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    texto,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w600,
                      fontSize: 13.5,
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

/// Botón principal grande y redondeado de las acciones críticas.
class BotonGrande extends StatelessWidget {
  const BotonGrande({
    super.key,
    required this.texto,
    required this.onPressed,
    this.icono,
    this.color = verdeApp,
    this.alto = 60,
  });

  final String texto;
  final VoidCallback? onPressed;
  final IconData? icono;
  final Color color;
  final double alto;

  @override
  Widget build(BuildContext context) {
    final habilitado = onPressed != null;
    return Container(
      height: alto,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(alto / 2),
        boxShadow:
            habilitado
                ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
                : null,
      ),
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: color,
          disabledBackgroundColor: const Color(0xFFD9DED8),
          disabledForegroundColor: textoSecundario,
          shape: const StadiumBorder(),
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.6,
          ),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icono != null) ...[
              Icon(icono, size: 24),
              const SizedBox(width: 10),
            ],
            Flexible(child: Text(texto, overflow: TextOverflow.ellipsis)),
          ],
        ),
      ),
    );
  }
}

void mostrarMensaje(BuildContext context, String texto) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(texto)));
}
