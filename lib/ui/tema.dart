import 'package:flutter/material.dart';

import '../domain/categoria.dart';
import '../domain/modelos.dart';

const verdeApp = Color(0xFF1B5E20);
const verdeOscuro = Color(0xFF103D14);
const rojoSos = Color(0xFFD32F2F);
const rojoSosOscuro = Color(0xFF9A1B1B);

// Neutros de la interfaz.
const fondoApp = Color(0xFFF3F5F2);
const bordeSuave = Color(0xFFE2E6E0);
const textoPrincipal = Color(0xFF1C2421);
const textoSecundario = Color(0xFF5B6660);

/// Sombra suave para tarjetas y botones flotantes.
const sombraSuave = [
  BoxShadow(color: Color(0x14000000), blurRadius: 12, offset: Offset(0, 4)),
];

ThemeData crearTema() {
  final esquema = ColorScheme.fromSeed(
    seedColor: verdeApp,
    primary: verdeApp,
    surface: Colors.white,
  );
  final base = ThemeData(colorScheme: esquema, useMaterial3: true);
  final texto = base.textTheme.apply(
    bodyColor: textoPrincipal,
    displayColor: textoPrincipal,
  );
  return base.copyWith(
    scaffoldBackgroundColor: fondoApp,
    textTheme: texto.copyWith(
      titleLarge: texto.titleLarge?.copyWith(fontWeight: FontWeight.w700),
      titleMedium: texto.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      labelLarge: texto.labelLarge?.copyWith(fontWeight: FontWeight.w600),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: verdeApp,
      foregroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        letterSpacing: 0.2,
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: bordeSuave),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(48, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(48, 52),
        foregroundColor: verdeApp,
        side: const BorderSide(color: bordeSuave, width: 1.5),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: const TextStyle(color: textoSecundario),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: bordeSuave),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: bordeSuave),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: verdeApp, width: 2),
      ),
    ),
    chipTheme: base.chipTheme.copyWith(
      backgroundColor: Colors.white,
      side: const BorderSide(color: bordeSuave),
      shape: const StadiumBorder(),
      labelStyle: const TextStyle(
        fontWeight: FontWeight.w600,
        color: textoPrincipal,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: textoPrincipal,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Colors.white,
      showDragHandle: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
    ),
    listTileTheme: const ListTileThemeData(iconColor: textoSecundario),
    dividerTheme: const DividerThemeData(color: bordeSuave, space: 1),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: verdeApp,
      linearTrackColor: Color(0xFFE3EBE2),
    ),
  );
}

// Colores de prioridad con contraste de texto ≥ 4.5:1 sobre su fondo.
Color colorPrioridad(Prioridad p) => switch (p) {
  Prioridad.rojo => const Color(0xFFB71C1C),
  Prioridad.amarillo => const Color(0xFF8D6E00),
  Prioridad.verde => const Color(0xFF1B5E20),
};

Color fondoPrioridad(Prioridad p) => switch (p) {
  Prioridad.rojo => const Color(0xFFFFE1E1),
  Prioridad.amarillo => const Color(0xFFFFF3C4),
  Prioridad.verde => const Color(0xFFDCEFDC),
};

IconData iconoCategoria(Categoria? c) => switch (c?.clave) {
  'sos' => Icons.sos,
  'incendio' => Icons.local_fire_department,
  'medica' => Icons.medical_services,
  'estructural' => Icons.domain_disabled,
  _ => Icons.report,
};

IconData iconoRecurso(TipoRecurso t) => switch (t) {
  TipoRecurso.puntoReunion => Icons.groups,
  TipoRecurso.refugio => Icons.house,
  TipoRecurso.salidaEvacuacion => Icons.exit_to_app,
  TipoRecurso.botiquin => Icons.healing,
  TipoRecurso.dea => Icons.bolt,
};

Color colorRecurso(TipoRecurso t) => switch (t) {
  TipoRecurso.puntoReunion => const Color(0xFF1565C0),
  TipoRecurso.refugio => const Color(0xFF2E7D32),
  TipoRecurso.salidaEvacuacion => const Color(0xFF5D4037),
  TipoRecurso.botiquin => const Color(0xFFE65100),
  TipoRecurso.dea => const Color(0xFF6A1B9A),
};

IconData iconoProtocolo(String clave) => switch (clave) {
  'rcp' => Icons.favorite,
  'atragantamiento' => Icons.air,
  'hemorragias' => Icons.water_drop,
  'quemaduras' => Icons.local_fire_department,
  'fracturas' => Icons.accessibility_new,
  'perdida_conciencia' => Icons.airline_seat_flat,
  'choque' => Icons.warning_amber,
  _ => Icons.medical_information,
};
