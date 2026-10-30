
/// si algo cambia se crea una copia nueva con copiarCon
class Producto {
  final int? id;            // null hasta que SQLite le asigna uno
  final String codigo;      // único, ej NV-001
  final String nombre;
  final int precioCentavos; // precio en centavos 2500 = $25.00
  final int existencias;    // piezas disponibles

  const Producto({
    this.id,
    required this.codigo,
    required this.nombre,
    required this.precioCentavos,
    required this.existencias,
  });

  /// devuelve una copia cambiando solo lo q indique
  Producto copiarCon({
    int? id,
    int? existencias,
    int? precioCentavos,
    String? nombre,
  }) =>
      Producto(
        id: id ?? this.id,
        codigo: codigo,
        nombre: nombre ?? this.nombre,
        precioCentavos: precioCentavos ?? this.precioCentavos,
        existencias: existencias ?? this.existencias,
      );

  ///SQLite Las llaves usan guion bajo porque así se llaman las columnas
  Map<String, Object?> aMapa() => {
        if (id != null) 'id': id,
        'codigo': codigo,
        'nombre': nombre,
        'precio_centavos': precioCentavos,
        'existencias': existencias,
      };

  /// es el camino inverso de aMapa
  factory Producto.desdeMapa(Map<String, Object?> m) => Producto(
        id: m['id'] as int?,
        codigo: m['codigo'] as String,
        nombre: m['nombre'] as String,
        precioCentavos: m['precio_centavos'] as int,
        existencias: m['existencias'] as int,
      );
}