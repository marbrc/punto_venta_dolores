
/// un renglón de una venta ya guardada
/// guarda nombre y precio no solo una referencia al producto porque mañana
/// el precio puede cambiar y el ticket de hoy debe mostrar lo que se cobró hoy
class LineaVenta {
  final String codigo;
  final String nombre;
  final int cantidad;
  final int precioCentavos;
  const LineaVenta(this.codigo, this.nombre, this.cantidad, this.precioCentavos);

  int get importeCentavos => cantidad * precioCentavos;
}

/// una venta guardada es una tipo foto de lo que pasó en caja
class Venta {
  final int? id;
  final DateTime fecha;
  final int totalCentavos;
  final int ivaCentavos;
  final int pagoCentavos;
  final List<LineaVenta> lineas;

  const Venta({
    this.id,
    required this.fecha,
    required this.totalCentavos,
    required this.ivaCentavos,
    required this.pagoCentavos,
    required this.lineas,
  });

  /// lo que se le regresa al cliente
  int get cambioCentavos => pagoCentavos - totalCentavos;
}

/// resultado del corte del día
class ResumenDia {
  final int numeroVentas;
  final int totalCentavos;
  final int ivaCentavos;
  const ResumenDia(this.numeroVentas, this.totalCentavos, this.ivaCentavos);
}