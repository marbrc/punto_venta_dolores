import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// Abre (y crea si no existe) la base SQLite.
/// Para pruebas se le pasa [ruta] = inMemoryDatabasePath (base en RAM).
class BaseDatos {
  static Database? _db; // conexión única (singleton) para la app real

  static Future<Database> abrir({String? ruta}) async {
    // Si ya hay conexión y no pidieron una ruta especial, la reutiliza.
    if (_db != null && ruta == null) return _db!;

    // En producción: archivo "punto_venta_dolores.db" dentro del teléfono.
    final destino =
        ruta ?? p.join(await getDatabasesPath(), 'punto_venta_dolores.db');

    // onCreate solo corre la PRIMERA vez que se crea el archivo.
    final db = await openDatabase(destino, version: 1, onCreate: crearTablas);
    if (ruta == null) _db = db;
    return db;
  }

  /// Crea las 3 tablas. UNIQUE y NOT NULL son reglas que la base hace cumplir
  /// aunque el código de Dart falle.
  static Future<void> crearTablas(Database db, int version) async {
    // Productos que se venden.
    await db.execute('''
      CREATE TABLE productos(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        codigo TEXT NOT NULL UNIQUE,
        nombre TEXT NOT NULL,
        precio_centavos INTEGER NOT NULL,
        existencias INTEGER NOT NULL
      )''');

    // Una fila por cada cobro realizado.
    await db.execute('''
      CREATE TABLE ventas(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        fecha TEXT NOT NULL,
        total_centavos INTEGER NOT NULL,
        iva_centavos INTEGER NOT NULL,
        pago_centavos INTEGER NOT NULL
      )''');

    // Renglones de cada venta (relación uno a muchos con ventas por venta_id).
    await db.execute('''
      CREATE TABLE lineas_venta(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        venta_id INTEGER NOT NULL REFERENCES ventas(id),
        codigo TEXT NOT NULL,
        nombre TEXT NOT NULL,
        cantidad INTEGER NOT NULL,
        precio_centavos INTEGER NOT NULL
      )''');
  }
}