import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'application/envio_service.dart';
import 'application/procesador_entrante.dart';
import 'data/almacen.dart';
import 'data/repositorios.dart';
import 'domain/categoria.dart';
import 'protocol/tramas.dart';
import 'services/modem_ble.dart';
import 'services/modem_service.dart';
import 'services/ubicacion_service.dart';

/// Límites del campus (área de operación). El radar solo muestra esta zona.
const limitesCampus = (
  norte: 22.77481,
  sur: 22.76790,
  oeste: -102.64876,
  este: -102.63754,
);

/// URL del simulador de radio (`tool/simulador_radio.dart`) o de un puente de
/// radio. Si se define con `--dart-define=SIMULADOR=ws://localhost:8080/ws`,
/// la app usa [ModemPuente].
const urlSimulador = String.fromEnvironment('SIMULADOR');

/// `--dart-define=MODEM=simulado` fuerza el [ModemSimulado] local (demostración
/// sin hardware). Sin él, en Android e iOS se usa el módem real por BLE.
const modoModem = String.fromEnvironment('MODEM');

/// Elige la implementación del servicio de conexión (SDS, DD-08).
ModemService crearModem(SharedPreferences prefs) {
  if (urlSimulador.isNotEmpty) return ModemPuente(Uri.parse(urlSimulador));
  final hayBle =
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);
  if (modoModem == 'simulado' || !hayBle) return ModemSimulado();
  return ModemBle(prefs);
}

/// Centro del campus, usado para centrar el mapa y cuando no hay GPS.
final centroCampus = (
  lat: (limitesCampus.norte + limitesCampus.sur) / 2,
  lon: (limitesCampus.oeste + limitesCampus.este) / 2,
);

class Dependencias {
  Dependencias._({
    required this.senderId,
    required this.prefs,
    required this.incidentes,
    required this.safetyChecks,
    required this.recursos,
    required this.protocolos,
    required this.modem,
    required this.ubicacion,
    required this.envio,
    required this.procesador,
    required this.errorRecursos,
  });

  final int senderId;
  final SharedPreferences prefs;
  final IncidenteRepository incidentes;
  final SafetyCheckRepository safetyChecks;
  final RecursoRepository recursos;
  final ProtocoloRepository protocolos;
  final ModemService modem;
  final UbicacionService ubicacion;
  final EnvioService envio;
  final ProcesadorEntrante procesador;

  /// true si los recursos precargados no se pudieron cargar (CU-03 E1).
  final bool errorRecursos;

  static Future<Dependencias> inicializar() async {
    final prefs = await SharedPreferences.getInstance();
    final senderId = _senderId(prefs);

    final almacen = await abrirAlmacen();
    final incidentes = almacen.incidentes;
    final safetyChecks = almacen.safetyChecks;
    final recursos = almacen.recursos;
    var errorRecursos = false;
    try {
      await recursos.cargarSiVacio(rootBundle);
    } catch (e) {
      debugPrint('No se pudieron cargar los recursos: $e');
      errorRecursos = true;
    }

    final modem = crearModem(prefs);
    final ubicacion = UbicacionService();
    final deps = Dependencias._(
      senderId: senderId,
      prefs: prefs,
      incidentes: incidentes,
      safetyChecks: safetyChecks,
      recursos: recursos,
      protocolos: ProtocoloRepository(),
      modem: modem,
      ubicacion: ubicacion,
      envio: EnvioService(
        senderId: senderId,
        incidentes: incidentes,
        safetyChecks: safetyChecks,
        modem: modem,
        ubicacion: ubicacion,
      ),
      procesador: ProcesadorEntrante(
        modem: modem,
        incidentes: incidentes,
        safetyChecks: safetyChecks,
      ),
      errorRecursos: errorRecursos,
    );
    modem.conectar();
    return deps;
  }

  /// Sender_ID anónimo y persistente por instalación (SRS S8).
  static int _senderId(SharedPreferences prefs) {
    final guardado = prefs.getInt('sender_id');
    if (guardado != null) return guardado;
    final nuevo = generarId32();
    prefs.setInt('sender_id', nuevo);
    return nuevo;
  }

  /// Solo demostración: inyecta una alerta de otro nodo cerca de la posición
  /// actual (o del centro del campus).
  void simularAlertaEntrante() {
    final m = modem;
    if (m is! ModemSimulado) return;
    final rnd = Random();
    final base = ubicacion.ultimaConocida;
    final lat =
        (base?.lat ?? centroCampus.lat) + (rnd.nextDouble() - 0.5) * 0.004;
    final lon =
        (base?.lon ?? centroCampus.lon) + (rnd.nextDouble() - 0.5) * 0.004;
    final categorias = [...Categorias.seleccionables, Categorias.sos];
    final categoria = categorias[rnd.nextInt(categorias.length)];
    const frases = [
      'Hay humo en el edificio B',
      'Herido',
      'Atrapado',
      'Necesito ayuda',
    ];
    m.inyectar(
      CodecTramas.codificar(
        TramaAlerta(
          msgId: generarId32(),
          senderId: generarId32(),
          tipo: categoria.tipo,
          lat: lat,
          lon: lon,
          unixTime: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          texto: categoria.esSos ? '' : frases[rnd.nextInt(frases.length)],
          ttl: ttlMax - 1 - rnd.nextInt(3),
        ),
      ),
    );
  }
}

class AppScope extends InheritedWidget {
  const AppScope({super.key, required this.deps, required super.child});

  final Dependencias deps;

  static Dependencias of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.deps;

  @override
  bool updateShouldNotify(AppScope oldWidget) => deps != oldWidget.deps;
}
