import 'package:flutter/foundation.dart';
import '../datos/repositorio_productos.dart';
import '../datos/repositorio_ventas.dart';
import '../dominio/carrito.dart';
import '../dominio/dinero.dart';
import '../dominio/producto.dart';
import '../dominio/venta.dart';

/// ViewModel: el "mesero" entre la pantalla y los repositorios.
/// Guarda el estado y avisa a la pantalla con notifyListeners().
class CajaViewModel extends ChangeNotifier {
  final RepositorioProductos productos;
  final RepositorioVentas ventas;

  Carrito carrito = Carrito();
  List<Producto> catalogo = [];
  String? mensaje;      // texto que se muestra al cajero (errores o cambio)
  Venta? ultimaVenta;

  CajaViewModel(this.productos, this.ventas);

  /// Carga el catálogo (con filtro opcional de búsqueda).
  Future<void> cargar({String filtro = ''}) async {
    catalogo = await productos.listar(filtro: filtro);
    notifyListeners(); // la pantalla se redibuja
  }

  /// Agrega un producto al carrito; si no hay existencias, muestra el error.
  void agregar(Producto p) {
    try {
      carrito.agregar(p);
      mensaje = null;
    } catch (e) {
      mensaje = e.toString();
    }
    notifyListeners();
  }

  /// Quita un renglón del carrito.
  void quitar(String codigo) {
    carrito.quitar(codigo);
    notifyListeners();
  }

  /// Cobra. Recibe TEXTO (lo que escribió el cajero) y lo convierte a centavos.
  /// Devuelve true si se cobró. Captura cualquier excepción para mostrarla
  /// como mensaje sin que la app se cierre.
  Future<bool> cobrar(String textoPago) async {
    try {
      final pago = pesosACentavos(textoPago);
      ultimaVenta = await ventas.cobrar(carrito, pago);
      mensaje = 'Cambio: ${formatearPesos(ultimaVenta!.cambioCentavos)}';
      carrito = Carrito(); // carrito nuevo para el siguiente cliente
      await cargar();      // refresca existencias en pantalla
      return true;
    } catch (e) {
      mensaje = e.toString();
      notifyListeners();
      return false;
    }
  }
}