import 'package:flutter/material.dart';

import 'app_scope.dart';
import 'ui/inicio_screen.dart';
import 'ui/tema.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final deps = await Dependencias.inicializar();
  runApp(AppScope(deps: deps, child: const LoraApp()));
}

class LoraApp extends StatelessWidget {
  const LoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LoRa P2P Emergencias',
      debugShowCheckedModeBanner: false,
      theme: crearTema(),
      locale: const Locale('es', 'MX'),
      home: const InicioScreen(),
    );
  }
}
