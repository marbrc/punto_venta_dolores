import 'package:flutter/material.dart';
import '../dominio/dinero.dart';
import 'caja_viewmodel.dart';

/// Pantalla de caja. Solo DIBUJA: no tiene reglas de negocio.
class PantallaCaja extends StatefulWidget {
  final CajaViewModel vm;
  const PantallaCaja({super.key, required this.vm});

  @override
  State<PantallaCaja> createState() => _PantallaCajaState();
}

class _PantallaCajaState extends State<PantallaCaja> {
  final _pago = TextEditingController(); // lo que escribe el cajero en "Paga con"

  @override
  void initState() {
    super.initState();
    widget.vm.cargar(); // carga el catálogo al abrir la pantalla
  }

  @override
  Widget build(BuildContext context) {
    final vm = widget.vm;
    // AnimatedBuilder escucha al ViewModel y redibuja cuando hay notifyListeners().
    return AnimatedBuilder(
      animation: vm,
      builder: (_, __) => Scaffold(
        appBar: AppBar(title: const Text('Caja · Dolores Hidalgo')),
        body: Column(children: [
          // Buscador de productos
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search), hintText: 'Buscar producto'),
              onChanged: (t) => vm.cargar(filtro: t),
            ),
          ),
          // Catálogo: tocar un producto lo agrega al carrito
          Expanded(
            child: ListView(children: [
              for (final p in vm.catalogo)
                ListTile(
                  title: Text(p.nombre),
                  subtitle: Text('${p.existencias} disponibles'),
                  trailing: Text(formatearPesos(p.precioCentavos)),
                  // onTap null = deshabilitado: no se vende lo que no existe
                  onTap: p.existencias == 0 ? null : () => vm.agregar(p),
                ),
            ]),
          ),
          const Divider(height: 1),
          // Renglones del carrito
          for (final l in vm.carrito.lineas)
            ListTile(
              dense: true,
              title: Text('${l.cantidad} × ${l.producto.nombre}'),
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                Text(formatearPesos(l.importeCentavos)),
                IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => vm.quitar(l.producto.codigo)),
              ]),
            ),
          // Totales, pago y botón de cobrar
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(children: [
              Text('IVA incluido: ${formatearPesos(vm.carrito.ivaCentavos)}'),
              Text('TOTAL ${formatearPesos(vm.carrito.totalCentavos)}',
                  style: Theme.of(context).textTheme.headlineSmall),
              Row(children: [
                Expanded(
                  child: TextField(
                    controller: _pago,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Paga con \$'),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: () async {
                    // Si el cobro salió bien, limpia el campo de pago
                    if (await vm.cobrar(_pago.text)) _pago.clear();
                  },
                  child: const Text('Cobrar'),
                ),
              ]),
              // Mensaje: cambio o error
              if (vm.mensaje != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(vm.mensaje!),
                ),
            ]),
          ),
        ]),
      ),
    );
  }
}