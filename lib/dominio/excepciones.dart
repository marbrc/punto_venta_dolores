/// errores de negocio con nombre propio
/// Dart solo se prueban sin flutter ni base de datos
import 'dinero.dart';
/// cuando intenta registrar un producto con un código que ya existe
class CodigoDuplicadoException implements Exception {
  final String codigo;
  CodigoDuplicadoException(this.codigo);

  @override
  String toString() => 'Ya existe un producto con el código $codigo';
}

///  cuando piden más piezas de las que hay en inventario
class ExistenciasInsuficientesException implements Exception {
  final String producto;
  final int disponibles;
  ExistenciasInsuficientesException(this.producto, this.disponibles);

  @override
  String toString() => 'Solo quedan $disponibles de $producto';
}

/// cuando el cliente paga menos que el total
class PagoInsuficienteException implements Exception {
  final int faltanCentavos;
  PagoInsuficienteException(this.faltanCentavos);

  @override
String toString() => 'Faltan ${formatearPesos(faltanCentavos)} para cubrir la cuenta';}

/// cuando intentan cobrar un carrito sin productos
class CarritoVacioException implements Exception {
  @override
  String toString() => 'No hay productos en el carrito';
}