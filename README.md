# Aplicación móvil — Sistema LoRa P2P de comunicación ante emergencias (MVP)

MVP de la app Flutter descrita en la SRS v1 y el SDS. Cubre los casos de uso:

| CU | Funcionalidad | Pantalla |
|----|---------------|----------|
| CU-01 | Redactar y emitir alerta | `lib/ui/nueva_alerta_screen.dart` |
| CU-02 | SOS de un toque | `lib/ui/inicio_screen.dart`, `lib/ui/sos_screen.dart` |
| CU-03 | Radar y mapa fuera de línea | `lib/ui/radar_screen.dart` |
| CU-04 | Guía de primeros auxilios | `lib/ui/primeros_auxilios_screen.dart` |
| CU-06 | Reportar "Estoy a salvo" | `lib/ui/safety_check_screen.dart` |
| CU-08 | Acusar "Voy en camino" / "Llegué" | `lib/ui/atencion_widgets.dart` (tarjeta del incidente en el radar) |
| CU-09 | Marcar un incidente como resuelto | `lib/ui/atencion_widgets.dart`, `lib/ui/sos_screen.dart` |
| CU-10 | Consolidar los acuses recibidos | `lib/domain/atencion.dart`, `lib/application/procesador_entrante.dart` |
| CU-11 | Consultar el estado de atención | Radar (lista, tarjeta y marcadores), SOS y pantalla principal |

**Acuses.** El estado de un incidente (Emitido, En asistencia o Resuelto) no viaja por radio: se calcula con `consolidarAtencion` a partir de los acuses conocidos, con las mismas reglas que el panel, así que todos los nodos convergen aunque los acuses lleguen en desorden o repetidos. Un acuse que llega antes que su incidente se guarda y se aplica al llegar este. Solo quien emitió el incidente o quien ya acusó "Llegué" puede resolverlo, y Resuelto es definitivo.

## Estructura (componentes del SDS, nivel 3)

- `lib/domain/` — modelos, catálogo de categorías y Haversine (Dart puro).
- `lib/protocol/` — **Manejo de protocolo**: tramas binarias de alerta (56 B) y Safety Check (17 B) con CRC-16.
- `lib/data/` — **Base de datos** Isar (`isar_community`) y repositorios.
- `lib/services/` — **Servicio de conexión** con el módem (BLE, simulado o por WebSocket) y acceso al GNSS. El contrato BLE con el firmware está en `gatt_modem.dart`.
- `lib/application/` — **Manejador de envío** y **Procesador de alertas entrantes**.
- `lib/ui/` — **User front end**.
- `assets/data/` — recursos del mapa y guía de primeros auxilios embebidos.

## Módem

La app elige cómo hablar con la red LoRa al arrancar:

| Cómo se ejecuta | Módem | Para qué |
|-----------------|-------|----------|
| `flutter run` en Android o iOS | **BLE** con un T-Beam en modo módem (`FirmwareTBeam`, `pio run -e modem`) | Uso real |
| `--dart-define=SIMULADOR=ws://…/ws` | WebSocket al simulador de radio o a un puente de radio | Pruebas sin BLE |
| `--dart-define=MODEM=simulado`, o en web y escritorio | Simulado local | Demostración sin hardware |

Con BLE, la app busca un módem que anuncie el servicio del contrato (`LoRa-XXXX`), prefiere el último al que se conectó y, si no lo encuentra, toma el primero que aparezca. Si pierde el enlace, reintenta cada 3 s. La primera vez, Android pide los permisos de Bluetooth.

## Ejecutar

```
flutter pub get
dart run build_runner build   # solo si cambian las entidades de Isar
flutter run
flutter test
```

## Simular la red de radio con Postman

`tool/simulador_radio.dart` hace de red LoRa: las apps se conectan a él por WebSocket y por HTTP se inyectan tramas o se consultan las que emitió la app.

```
dart run tool/simulador_radio.dart                                    # puerto 8080
flutter run -d chrome --dart-define=SIMULADOR=ws://localhost:8080/ws
```

En el emulador de Android usa `ws://10.0.2.2:8080/ws`; en un teléfono físico, la IP de la PC en la misma red Wi-Fi. Sin `SIMULADOR`, la app usa el módem BLE en el teléfono (o el simulado con `--dart-define=MODEM=simulado`).

Importa `tool/simulador_radio.postman_collection.json` en Postman. Endpoints:

| Método | Ruta | Uso |
|--------|------|-----|
| POST | `/alerta` | La app recibe una alerta: `{categoria: incendio\|medica\|estructural\|sos, texto, lat, lon, ttl, msgId, senderId, rssi, snr}` (todo opcional) |
| POST | `/safety-check` | La app recibe un "Estoy a salvo": `{estado, msgId, senderId}` |
| POST | `/trama` | Bytes crudos en hexadecimal: `{hex}` (p. ej. para probar CRC inválido) |
| GET | `/enviadas` | Tramas que transmitieron las apps, decodificadas |
| DELETE | `/enviadas` | Borra ese registro |
| GET | `/estado` | Apps conectadas |

Lo que transmite una app les llega a las demás conectadas, así que dos pestañas de Chrome se reciben alertas entre sí. Para apagar el "módem", usa el interruptor del engrane (⚙) o detén el simulador.

## Limitaciones del MVP

- **Módem BLE sin emparejamiento.** `ModemBle` se conecta sin emparejar mientras el firmware tenga `BLE_REQUIERE_CIFRADO 0`; la SRS (3.1.4) pide emparejamiento estándar antes de los simulacros. Se usa `flutter_blue_plus` 1.35 (licencia BSD-3): la serie 2.x cambió a una licencia propia con telemetría al compilar.
- **Selección del módem.** Con varios módems cerca, la app toma el último que usó o el primero que encuentra; aún no hay una pantalla para elegirlo.
- **Engrane (⚙).** Permite desconectar el módem y, con el módem simulado, simular alertas de otros nodos.
- **Web solo para demostración.** Isar no compila a JavaScript, así que en Chrome/Edge se usa un almacén en memoria (`lib/data/repositorios_memoria.dart`) y los datos se pierden al recargar. En Android/iOS se usa Isar (`lib/data/repositorios_isar.dart`).
- **Teselas de OpenStreetMap en línea.** El radar descarga las teselas de OSM y flutter_map las guarda en caché (Android/iOS), así que la zona ya vista sigue disponible sin internet. Donde no hay teselas se ve la cuadrícula de referencia. Para el despliegue se debe sustituir por un MBTiles del campus (SRS S6).
- **Datos de ejemplo.** Las coordenadas de `recursos.json` y el centro del campus en `lib/app_scope.dart` son de ejemplo. El contenido de primeros auxilios es un borrador que debe revisar personal capacitado (SRS S9).
- **CRC-16 con TTL = 0.** El CRC se calcula con el byte de TTL en cero para que los nodos intermedios puedan decrementarlo sin recalcular el CRC; el firmware debe seguir la misma regla.
