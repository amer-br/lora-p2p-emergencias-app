import 'package:flutter/material.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../app_scope.dart';
import '../domain/modelos.dart';
import 'radar_screen.dart';
import 'tema.dart';
import 'widgets.dart';

/// CU-04: consultar la guía de primeros auxilios sin conexión.
class PrimerosAuxiliosScreen extends StatefulWidget {
  const PrimerosAuxiliosScreen({super.key});

  @override
  State<PrimerosAuxiliosScreen> createState() => _PrimerosAuxiliosScreenState();
}

class _PrimerosAuxiliosScreenState extends State<PrimerosAuxiliosScreen> {
  Future<List<ProtocoloAuxilio>>? _carga;
  String _busqueda = '';

  @override
  void initState() {
    super.initState();
    // La pantalla permanece encendida mientras la guía está abierta.
    _wakelock(true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _carga ??= AppScope.of(
      context,
    ).protocolos.cargar(DefaultAssetBundle.of(context));
  }

  @override
  void dispose() {
    _wakelock(false);
    super.dispose();
  }

  Future<void> _wakelock(bool activo) async {
    try {
      await WakelockPlus.toggle(enable: activo);
    } catch (_) {
      // Plataforma sin soporte: no es crítico.
    }
  }

  void _abrir(ProtocoloAuxilio p) {
    if (!p.valido) {
      mostrarMensaje(context, 'No se pudo abrir este protocolo.');
      return;
    }
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => ProtocoloScreen(protocolo: p)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Primeros auxilios')),
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Aviso('Esta guía no sustituye la atención profesional.'),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                onChanged: (v) => setState(() => _busqueda = v),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search_rounded),
                  hintText: 'Buscar tema…',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: const BorderSide(color: bordeSuave),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: const BorderSide(color: bordeSuave),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: const BorderSide(color: verdeApp, width: 2),
                  ),
                ),
              ),
            ),
            Expanded(
              child: FutureBuilder<List<ProtocoloAuxilio>>(
                future: _carga,
                builder: (context, snap) {
                  if (snap.hasError) {
                    return const Center(
                      child: Text('No se pudo cargar la guía.'),
                    );
                  }
                  if (!snap.hasData)
                    return const Center(child: CircularProgressIndicator());
                  final q = _normalizar(_busqueda);
                  final temas =
                      snap.data!
                          .where((p) => _normalizar(p.titulo).contains(q))
                          .toList();
                  if (temas.isEmpty)
                    return const Center(child: Text('Sin resultados'));
                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: temas.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final p = temas[i];
                      return Card(
                        child: ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          leading: IconoSuave(
                            iconoProtocolo(p.icono),
                            color: rojoSos,
                            tamano: 42,
                          ),
                          title: Text(
                            p.titulo,
                            style: const TextStyle(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            '${p.pasos.length} pasos',
                            style: const TextStyle(color: textoSecundario),
                          ),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: () => _abrir(p),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16),
              child: BotonDeaCercano(),
            ),
          ],
        ),
      ),
    );
  }

  static String _normalizar(String s) =>
      s
          .toLowerCase()
          .replaceAll(RegExp('[áä]'), 'a')
          .replaceAll(RegExp('[éë]'), 'e')
          .replaceAll(RegExp('[íï]'), 'i')
          .replaceAll(RegExp('[óö]'), 'o')
          .replaceAll(RegExp('[úü]'), 'u')
          .trim();
}

class BotonDeaCercano extends StatelessWidget {
  const BotonDeaCercano({super.key});

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: 54,
    child: OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        foregroundColor: colorRecurso(TipoRecurso.dea),
        side: BorderSide(
          color: colorRecurso(TipoRecurso.dea).withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      icon: Icon(iconoRecurso(TipoRecurso.dea)),
      label: const Text('DEA más cercano'),
      onPressed:
          () => Navigator.of(context).push(
            MaterialPageRoute(
              builder:
                  (_) => const RadarScreen(masCercanoInicial: TipoRecurso.dea),
            ),
          ),
    ),
  );
}

/// Protocolo paso a paso, con letra grande y advertencias resaltadas.
class ProtocoloScreen extends StatefulWidget {
  const ProtocoloScreen({super.key, required this.protocolo});

  final ProtocoloAuxilio protocolo;

  @override
  State<ProtocoloScreen> createState() => _ProtocoloScreenState();
}

class _ProtocoloScreenState extends State<ProtocoloScreen> {
  int _paso = 0;

  @override
  Widget build(BuildContext context) {
    final p = widget.protocolo;
    final total = p.pasos.length;
    final ultimo = _paso == total - 1;
    return Scaffold(
      appBar: AppBar(title: Text(p.titulo)),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (p.advertencias != null)
                    Aviso(
                      p.advertencias!,
                      icono: Icons.report,
                      color: const Color(0xFFB71C1C),
                      fondo: const Color(0xFFFFEBEE),
                    ),
                  const SizedBox(height: 16),
                  TituloSeccion('Paso ${_paso + 1} de $total'),
                  LinearProgressIndicator(
                    value: (_paso + 1) / total,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: sombraSuave,
                    ),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [Color(0xFF2E7D32), verdeApp],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '${_paso + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                p.pasos[_paso],
                                style: const TextStyle(
                                  fontSize: 23,
                                  height: 1.38,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ExpansionTile(
                    title: const Text('Ver todos los pasos'),
                    children: [
                      for (var i = 0; i < total; i++)
                        ListTile(
                          dense: true,
                          selected: i == _paso,
                          leading: Text(
                            '${i + 1}.',
                            style: const TextStyle(fontSize: 16),
                          ),
                          title: Text(
                            p.pasos[i],
                            style: const TextStyle(fontSize: 16),
                          ),
                          onTap: () => setState(() => _paso = i),
                        ),
                    ],
                  ),
                  if (p.id == 'rcp') ...[
                    const SizedBox(height: 8),
                    const BotonDeaCercano(),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 60,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.arrow_back),
                        label: const Text(
                          'Anterior',
                          style: TextStyle(fontSize: 18),
                        ),
                        onPressed:
                            _paso == 0 ? null : () => setState(() => _paso--),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 60,
                      child: FilledButton.icon(
                        icon: Icon(ultimo ? Icons.check : Icons.arrow_forward),
                        label: Text(
                          ultimo ? 'Terminar' : 'Siguiente',
                          style: const TextStyle(fontSize: 18),
                        ),
                        onPressed:
                            ultimo
                                ? () => Navigator.of(context).pop()
                                : () => setState(() => _paso++),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
