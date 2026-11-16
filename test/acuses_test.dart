import 'dart:math';
import 'dart:typed_data';

import 'package:aplicacion/application/envio_service.dart';
import 'package:aplicacion/application/procesador_entrante.dart';
import 'package:aplicacion/data/repositorios.dart';
import 'package:aplicacion/data/repositorios_memoria.dart';
import 'package:aplicacion/domain/atencion.dart';
import 'package:aplicacion/domain/modelos.dart';
import 'package:aplicacion/protocol/tramas.dart';
import 'package:aplicacion/services/modem_service.dart';
import 'package:aplicacion/services/ubicacion_service.dart';
import 'package:flutter_test/flutter_test.dart';

const yo = 0x11111111;
const otro = 0x22222222;
const panel = 0x0000CA0A;

Acuse acuse(
  int msgId,
  int sender,
  TipoAcuse tipo, {
  int ref = 1,
  int seg = 0,
}) => Acuse(
  msgId: msgId,
  senderId: sender,
  tipo: tipo,
  refMsgId: ref,
  horaEmisor: 0,
  horaRecepcionLocal: DateTime(2026, 11, 16, 12, 0, seg),
  origen: Origen.recibido,
);

Incidente incidente({int msgId = 1, int sender = otro}) => Incidente(
  msgId: msgId,
  senderId: sender,
  tipo: 0x12,
  texto: 'Herido',
  horaEmisor: 0,
  horaRecepcionLocal: DateTime(2026, 11, 16, 12),
  origen: sender == yo ? Origen.propio : Origen.recibido,
);

Uint8List deHex(String h) => Uint8List.fromList([
  for (var i = 0; i < h.length; i += 2)
    int.parse(h.substring(i, i + 2), radix: 16),
]);

String aHex(Uint8List b) =>
    b.map((x) => x.toRadixString(16).padLeft(2, '0')).join().toUpperCase();

void main() {
  group('Trama de acuse (20 B)', () {
    // Trama emitida por el panel (Python) en la prueba de extremo a extremo
    // del puente: acuse «en camino» del panel para el incidente 0x0BADCAFE.
    const delPanel = 'B2A534250000CA0A05020BADCAFE6AF3FE9B91D9';

    test('decodifica la trama del panel y la vuelve a codificar igual', () {
      final t = CodecTramas.decodificar(deHex(delPanel)) as TramaAcuse;
      expect(t.senderId, panel);
      expect(t.tipo, TipoTrama.ackEnCamino);
      expect(t.refMsgId, 0x0BADCAFE);
      expect(t.ttl, ttlMax);
      expect(aHex(CodecTramas.codificar(t)), delPanel);
    });

    test('un nodo intermedio puede decrementar el TTL sin romper el CRC', () {
      final b = deHex(delPanel)..[8] = 2;
      expect(CodecTramas.decodificar(b), isA<TramaAcuse>());
    });

    test('se descarta con CRC o longitud incorrectos', () {
      final corrupta = deHex(delPanel)..[12] ^= 0x01;
      expect(CodecTramas.decodificar(corrupta), isNull);
      expect(CodecTramas.decodificar(deHex(delPanel).sublist(0, 19)), isNull);
    });
  });

  group('Consolidación del estado (RNF-2.2)', () {
    test('sin acuses: Emitido', () {
      expect(consolidarAtencion(const []).estado, EstadoAtencion.emitido);
    });

    test('cada persona cuenta una vez, por su acuse más avanzado', () {
      final a = consolidarAtencion([
        acuse(1, yo, TipoAcuse.enCamino),
        acuse(2, yo, TipoAcuse.llegue),
        acuse(3, otro, TipoAcuse.enCamino),
        acuse(4, otro, TipoAcuse.enCamino), // repetido con otro Msg_ID
      ]);
      expect(a.estado, EstadoAtencion.enAsistencia);
      expect(a.enCamino, 1);
      expect(a.enSitio, 1);
      expect(a.resumen, 'En asistencia · 1 en camino · 1 en el sitio');
    });

    test('Resuelto es terminal aunque llegue un acuse tardío', () {
      final a = consolidarAtencion([
        acuse(1, yo, TipoAcuse.llegue, seg: 1),
        acuse(2, yo, TipoAcuse.resuelto, seg: 2),
        acuse(3, otro, TipoAcuse.enCamino, seg: 3),
      ]);
      expect(a.estado, EstadoAtencion.resuelto);
      expect(a.historial.first.msgId, 3, reason: 'el historial no se borra');
    });

    test('mismo resultado con cualquier orden y duplicados', () {
      final base = [
        acuse(1, yo, TipoAcuse.enCamino, seg: 1),
        acuse(2, otro, TipoAcuse.llegue, seg: 2),
        acuse(3, panel, TipoAcuse.enCamino, seg: 3),
        acuse(4, panel, TipoAcuse.llegue, seg: 4),
      ];
      final esperado = consolidarAtencion(base);
      final rnd = Random(7);
      for (var i = 0; i < 1000; i++) {
        final mezcla = [...base, ...base.take(rnd.nextInt(base.length))]
          ..shuffle(rnd);
        final a = consolidarAtencion(mezcla);
        expect(
          (a.estado, a.enCamino, a.enSitio),
          (esperado.estado, esperado.enCamino, esperado.enSitio),
        );
      }
    });

    test('agrupa por incidente, incluidos los huérfanos', () {
      final mapa = atencionPorIncidente([
        acuse(1, yo, TipoAcuse.enCamino, ref: 10),
        acuse(2, otro, TipoAcuse.resuelto, ref: 20),
      ]);
      expect(mapa[10]!.estado, EstadoAtencion.enAsistencia);
      expect(mapa[20]!.estado, EstadoAtencion.resuelto);
    });
  });

  group('Servicio de envío de acuses', () {
    late Almacen almacen;
    late ModemSimulado modem;
    late EnvioService envio;
    late ProcesadorEntrante procesador;

    setUp(() async {
      almacen = await abrirAlmacen();
      modem = ModemSimulado();
      envio = EnvioService(
        senderId: yo,
        incidentes: almacen.incidentes,
        acuses: almacen.acuses,
        safetyChecks: almacen.safetyChecks,
        modem: modem,
        ubicacion: UbicacionService(),
      );
      procesador = ProcesadorEntrante(
        modem: modem,
        incidentes: almacen.incidentes,
        acuses: almacen.acuses,
        safetyChecks: almacen.safetyChecks,
      );
    });

    tearDown(() {
      envio.dispose();
      procesador.dispose();
    });

    Future<List<Acuse>> acusesDe(int ref) =>
        almacen.acuses.observarDe(ref).first;

    test('flujo completo: en camino, llegué y resuelto', () async {
      await modem.conectar();
      final i = incidente();
      expect(
        await envio.emitirAcuse(i, TipoAcuse.resuelto),
        ResultadoAcuse.noPuedeResolver,
        reason: 'sin haber llegado no se puede resolver',
      );
      expect(
        await envio.emitirAcuse(i, TipoAcuse.enCamino),
        ResultadoAcuse.enviado,
      );
      expect(
        await envio.emitirAcuse(i, TipoAcuse.enCamino),
        ResultadoAcuse.yaEmitido,
      );
      expect(
        await envio.emitirAcuse(i, TipoAcuse.llegue),
        ResultadoAcuse.enviado,
      );
      expect(
        await envio.emitirAcuse(i, TipoAcuse.resuelto),
        ResultadoAcuse.enviado,
      );
      expect(
        await envio.emitirAcuse(i, TipoAcuse.enCamino),
        ResultadoAcuse.incidenteResuelto,
      );
      expect(consolidarAtencion(await acusesDe(1)).resuelto, isTrue);
    });

    test('quien emitió el incidente puede resolverlo sin llegar', () async {
      await modem.conectar();
      final propio = incidente(sender: yo);
      expect(
        await envio.emitirAcuse(propio, TipoAcuse.resuelto),
        ResultadoAcuse.enviado,
      );
    });

    test('sin módem queda Pendiente y se envía al reconectar', () async {
      final i = incidente();
      expect(
        await envio.emitirAcuse(i, TipoAcuse.enCamino),
        ResultadoAcuse.pendiente,
      );
      expect((await almacen.acuses.pendientesPropios()).length, 1);
      // Al reconectar, el servicio reenvía los pendientes por sí solo.
      await modem.conectar();
      for (var i = 0; i < 40; i++) {
        if ((await almacen.acuses.pendientesPropios()).isEmpty) break;
        await Future<void>.delayed(const Duration(milliseconds: 50));
      }
      expect(await almacen.acuses.pendientesPropios(), isEmpty);
    });

    test('se recibe un acuse antes que su incidente (huérfano)', () async {
      await modem.conectar();
      final nuevos = <Acuse>[];
      final sub = procesador.acusesNuevos.listen(nuevos.add);
      final trama = CodecTramas.codificar(
        TramaAcuse(
          msgId: 99,
          senderId: panel,
          tipo: TipoTrama.ackLlegue,
          refMsgId: 1234,
          unixTime: 0,
        ),
      );
      modem.inyectar(trama);
      modem.inyectar(trama); // retransmisión: no se duplica
      await Future<void>.delayed(const Duration(milliseconds: 50));
      await sub.cancel();

      expect(nuevos.length, 1);
      final guardados = await acusesDe(1234);
      expect(guardados.single.senderId, panel);
      expect(guardados.single.rssi, isNotNull);
      expect(consolidarAtencion(guardados).enSitio, 1);
    });
  });
}
