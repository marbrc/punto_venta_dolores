import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'datos/base_datos.dart';
import 'datos/repositorio_productos.dart';
import 'datos/repositorio_ventas.dart';
import 'presentacion/caja_viewmodel.dart';
import 'presentacion/pantalla_caja.dart';

/// Composition root: el ÚNICO lugar donde se crean y conectan los objetos.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // SQLite en el navegador (WebAssembly). Los datos quedan en Chrome.
  databaseFactory = databaseFactoryFfiWebNoWebWorker;

  final db = await BaseDatos.abrir();
  final productos = RepositorioProductos(db);
  await productos.sembrarEjemplos();

  runApp(MaterialApp(
    title: 'Punto de Venta Dolores',
    theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
    home: PantallaCaja(vm: CajaViewModel(productos, RepositorioVentas(db))),
  ));
}