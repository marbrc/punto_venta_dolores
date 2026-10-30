
import 'excepciones.dart';
import 'producto.dart';

/// un producto y cuántas piezas lleva
class LineaCarrito {
  final Producto producto;
  int cantidad;
  LineaCarrito(this.producto, this.cantidad);

  /// precio unitario × cantidad en centavos
  int get importeCentavos => producto.precioCentavos * cantidad;
}

/// reglas del negocio
class Carrito {
  /// IVA en porcentaje entero
  final int tasaIva;

  /// código del producto.
  //si repite, solo sube el número
  final Map<String, LineaCarrito> _lineas = {};

  Carrito({this.tasaIva = 16});

  List<LineaCarrito> get lineas => _lineas.values.toList();
  bool get estaVacio => _lineas.isEmpty;

  /// agrega cantidad piezas del producto p
  /// valida antes de modificar nada, para no dejar el carrito con datos invalidos
  void agregar(Producto p, {int cantidad = 1}) {
    final actual = _lineas[p.codigo]?.cantidad ?? 0;
    if (actual + cantidad > p.existencias) {
      throw ExistenciasInsuficientesException(p.nombre, p.existencias);
    }
    if (_lineas.containsKey(p.codigo)) {
      _lineas[p.codigo]!.cantidad += cantidad; // suma
    } else {
      _lineas[p.codigo] = LineaCarrito(p, cantidad); // ssss
    }
  }

  /// quita todo el renglón de ese producto
  void quitar(String codigo) => _lineas.remove(codigo);

  /// deja el carrito vacío
  void vaciar() => _lineas.clear();

  /// total a cobrar, Los precios ya incluyen IVA
  int get totalCentavos =>
      _lineas.values.fold(0, (s, l) => s + l.importeCentavos);

  /// Subtotal igual al total - IVA y se calcula así para que no falten centavos
  int get subtotalCentavos => totalCentavos - ivaCentavos;

  /// iva = total × tasa / (100 + tasa)
  /// con enteros sumam la mitad del divisor antes de dividir para redondear
  int get ivaCentavos => 
      (totalCentavos * tasaIva + (100 + tasaIva) ~/ 2) ~/ (100 + tasaIva);

  /// calcula el cambio, lanza error si el carrito está vacío o el pago no alcanza
  int cambio(int pagoCentavos) {
    if (estaVacio) throw CarritoVacioException();
    if (pagoCentavos < totalCentavos) {
      throw PagoInsuficienteException(totalCentavos - pagoCentavos);
    }
    return pagoCentavos - totalCentavos;
  }
}