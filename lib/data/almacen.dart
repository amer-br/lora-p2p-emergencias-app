/// Elige la persistencia en tiempo de compilación: el código de Isar no se
/// compila en la web porque usa enteros de 64 bits que JavaScript no admite.
library;

export 'repositorios_isar.dart'
    if (dart.library.js_interop) 'repositorios_memoria.dart' show abrirAlmacen;
