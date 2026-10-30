import 'package:sqflite/sqflite.dart';
import '../dominio/carrito.dart';
import '../dominio/excepciones.dart';
import '../dominio/venta.dart';

/// Guarda ventas, hace el corte del día y los reportes.
class RepositorioVentas {
  final Database db;
  RepositorioVentas(this.db);

  /// Cobra: valida pago, guarda venta + renglones y descuenta inventario.
  /// Todo en UNA transacción: o se guarda todo o no se guarda nada.
  Future<Venta> cobrar(Carrito carrito, int pagoCentavos,
      {DateTime? fecha}) async {
    // 1) Validación de dominio: lanza error si carrito vacío o pago corto.
    //    Si falla aquí, NO se toca la base.
    carrito.cambio(pagoCentavos);

    final momento = fecha ?? DateTime.now();
    late int ventaId;

    // 2) Transacción "todo o nada". Si algo lanza excepción dentro,
    //    SQLite revierte automáticamente TODO lo que se hizo.
    await db.transaction((txn) async {
      // Revalidamos existencias contra la base: otro cajero pudo vender
      // mientras tú llenabas el carrito.
      for (final l in carrito.lineas) {
        final f = await txn.query('productos',
            columns: ['existencias'],
            where: 'codigo = ?',
            whereArgs: [l.producto.codigo]);
        final disp = f.isEmpty ? 0 : f.first['existencias'] as int;
        if (disp < l.cantidad) {
          throw ExistenciasInsuficientesException(l.producto.nombre, disp);
        }
      }

      // Guardamos la venta y obtenemos su id.
      ventaId = await txn.insert('ventas', {
        'fecha': momento.toIso8601String(),
        'total_centavos': carrito.totalCentavos,
        'iva_centavos': carrito.ivaCentavos,
        'pago_centavos': pagoCentavos,
      });

      // Por cada renglón: lo guardamos y descontamos inventario.
      for (final l in carrito.lineas) {
        await txn.insert('lineas_venta', {
          'venta_id': ventaId,
          'codigo': l.producto.codigo,
          'nombre': l.producto.nombre,
          'cantidad': l.cantidad,
          'precio_centavos': l.producto.precioCentavos,
        });
        // "existencias = existencias - ?" lo resta la propia base (seguro si
        // dos cajeros cobran a la vez). NO leas, restes en Dart y guardes.
        await txn.rawUpdate(
            'UPDATE productos SET existencias = existencias - ? WHERE codigo = ?',
            [l.cantidad, l.producto.codigo]);
      }
    });

    // 3) Devolvemos la venta ya guardada (para mostrar el cambio / ticket).
    return Venta(
      id: ventaId,
      fecha: momento,
      totalCentavos: carrito.totalCentavos,
      ivaCentavos: carrito.ivaCentavos,
      pagoCentavos: pagoCentavos,
      lineas: carrito.lineas
          .map((l) => LineaVenta(l.producto.codigo, l.producto.nombre,
              l.cantidad, l.producto.precioCentavos))
          .toList(),
    );
  }

  /// Corte del día: cuenta y suma las ventas de la fecha dada.
  Future<ResumenDia> corteDelDia(DateTime dia) async {
    final inicio = DateTime(dia.year, dia.month, dia.day); // hoy 00:00
    final fin = inicio.add(const Duration(days: 1));        // mañana 00:00
    final r = await db.rawQuery('''
      SELECT COUNT(*) AS n,
             COALESCE(SUM(total_centavos),0) AS total,
             COALESCE(SUM(iva_centavos),0) AS iva
      FROM ventas WHERE fecha >= ? AND fecha < ?''',
        [inicio.toIso8601String(), fin.toIso8601String()]);
    final f = r.first;
    // COALESCE evita nulos cuando no hubo ventas (devuelve 0).
    return ResumenDia(f['n'] as int, f['total'] as int, f['iva'] as int);
  }

  /// Ranking de productos más vendidos (para decidir qué resurtir).
  Future<List<Map<String, Object?>>> masVendidos({int limite = 5}) =>
      db.rawQuery('''
        SELECT nombre, SUM(cantidad) AS unidades
        FROM lineas_venta GROUP BY codigo
        ORDER BY unidades DESC LIMIT ?''', [limite]);
}