/// Catálogo de categorías de emergencia (SRS S10).
///
/// La categoría y su prioridad viajan codificadas en el campo Type de la
/// trama de alerta. Los valores 0x01–0x0F se reservan para tramas de control
/// (SOS, acuses, Safety Check); las categorías usan 0x10 en adelante.
library;

enum Prioridad { rojo, amarillo, verde }

extension PrioridadTexto on Prioridad {
  String get etiqueta => switch (this) {
        Prioridad.rojo => 'ROJO',
        Prioridad.amarillo => 'AMARILLO',
        Prioridad.verde => 'VERDE',
      };

  /// Menor valor = más urgente; se usa para ordenar la bitácora.
  int get orden => index;
}

/// Type reservado para el SOS de un toque (CU-02).
const int tipoSos = 0x01;

class Categoria {
  const Categoria({
    required this.tipo,
    required this.clave,
    required this.nombre,
    required this.prioridad,
  });

  final int tipo;
  final String clave;
  final String nombre;
  final Prioridad prioridad;

  bool get esSos => tipo == tipoSos;
}

abstract final class Categorias {
  static const sos = Categoria(
      tipo: tipoSos, clave: 'sos', nombre: 'SOS', prioridad: Prioridad.rojo);
  static const incendio = Categoria(
      tipo: 0x11,
      clave: 'incendio',
      nombre: 'Incendio',
      prioridad: Prioridad.rojo);
  static const medica = Categoria(
      tipo: 0x12,
      clave: 'medica',
      nombre: 'Médica',
      prioridad: Prioridad.amarillo);
  static const estructural = Categoria(
      tipo: 0x13,
      clave: 'estructural',
      nombre: 'Estructural',
      prioridad: Prioridad.verde);

  /// Categorías que el usuario puede elegir en "Nueva alerta" (CU-01).
  static const seleccionables = [incendio, medica, estructural];

  static const _todas = [sos, ...seleccionables];

  static Categoria? porTipo(int tipo) {
    for (final c in _todas) {
      if (c.tipo == tipo) return c;
    }
    return null;
  }
}
