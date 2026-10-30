<img width="975" height="259" alt="image" src="https://github.com/user-attachments/assets/f1de4121-5fde-4fd2-9123-a7cd35b4272a" /><img width="975" height="259" alt="image" src="https://github.com/user-attachments/assets/060e1748-5d02-4c17-9b7c-daa12bfeb954" /># punto_venta_dolores

Punto de venta que guarda productos y ventas en SQLite, calcula total, IVA y cambio con centavos enteros, descuenta el inventario con una transacción y hace el corte del día.



 Ronda 0: preparar el taller

Creé el proyecto con `flutter create`, configuré el `pubspec.yaml` con `sqflite`, `path` y `sqflite_common_ffi`, y creé las carpetas `dominio`, `datos` y `presentacion`.
<img width="975" height="398" alt="image" src="https://github.com/user-attachments/assets/6beb28f0-a43a-49c2-930b-f637399bf07f" />


Ronda 1: el dinero

El dinero se guarda en **centavos enteros** porque con `double` pasa que `0.1 + 0.2 = 0.30000000000000004`.

 Rojo: formatear pesos
Al quitar `dinero.dart`, la prueba falla con "Target of URI doesn't exist".
 <img width="540" height="352" alt="image" src="https://github.com/user-attachments/assets/e2fb8862-06f0-4289-9829-86297aec0ecc" />

Verde: formatear pesos
Creé `formatearPesos`, que usa `~/` y `%` para separar pesos y centavos.

 <img width="975" height="258" alt="image" src="https://github.com/user-attachments/assets/514e0705-6c40-43b1-8a2b-1f92d4b026d9" />


Rojo: texto a centavos
Sin `pesosACentavos`, la prueba falla porque la función no está definida.
 <img width="975" height="523" alt="image" src="https://github.com/user-attachments/assets/2ffdf82a-18a4-43b8-849f-5f2c0bb6ade6" />


 Verde: texto a centavos
Agregué `pesosACentavos`, con `padRight` para que "12.5" sea 1250 centavos.
<img width="975" height="252" alt="image" src="https://github.com/user-attachments/assets/e1659777-3fe3-490f-a4e7-5732219a3246" />

 Ronda 2: el Producto

Rojo
La prueba de ida y vuelta a mapa falla porque `producto.dart` no existe.
 <img width="975" height="605" alt="image" src="https://github.com/user-attachments/assets/a1940636-c27b-4e8c-9f15-b23444a44c80" />

 Verde
Creé la clase `Producto` inmutable con `copiarCon`, `aMapa` y `desdeMapa`.
 <img width="975" height="247" alt="image" src="https://github.com/user-attachments/assets/211b3abc-236e-42cb-922c-c1f425824325" />



Ronda 3: el Carrito

Ciclo 3.1: sumar cantidades
Rojo
  <img width="975" height="427" alt="image" src="https://github.com/user-attachments/assets/b25e5fca-e3cc-4dc2-9ae4-22fa1d85d8b7" />

Verde 

 <img width="975" height="253" alt="image" src="https://github.com/user-attachments/assets/d481f415-d287-4fe4-847f-9d0e2918b988" />

Dos nieves son un solo renglón con cantidad 2.

Ciclo 3.2: no vender lo que no hay
Rojo
 <img width="570" height="291" alt="image" src="https://github.com/user-attachments/assets/4ca6f206-4d7f-4763-8e6e-8227223c8137" />

Verde
 <img width="975" height="254" alt="image" src="https://github.com/user-attachments/assets/3dd0eca5-415c-4d84-b34d-7ead3212ff13" />

Se valida antes de modificar el carrito y se lanza `ExistenciasInsuficientesException`.

Ciclo 3.3: IVA incluido con enteros
Rojo 
 <img width="586" height="391" alt="image" src="https://github.com/user-attachments/assets/0b38eaea-60e1-4675-a70c-377efafdf262" />


Verde 
 

IVA = total × 16 / 116, y subtotal = total − IVA, así no se pierde ningún centavo.

### Ciclo 3.4: cambio, pago corto y carrito vacío
Rojo

<img width="660" height="372" alt="image" src="https://github.com/user-attachments/assets/99b12ad8-65a7-4537-8141-cb03b2f36545" />

 

Verde
<img width="975" height="259" alt="image" src="https://github.com/user-attachments/assets/6d9809fb-6c18-4004-bb9e-4c9315820282" />


Ronda 4: base de datos SQLite

Tres tablas: `productos`, `ventas` y `lineas_venta`. Las pruebas usan una base en memoria.

Rojo: guardar y buscar
 <img width="975" height="262" alt="image" src="https://github.com/user-attachments/assets/d255eb66-483d-4633-9ced-52932a1d94be" />


Verde: guardar y buscar
 <img width="975" height="249" alt="image" src="https://github.com/user-attachments/assets/fc321570-af6b-4ee5-a658-2f19c066dad4" />

Rojo: código duplicado
 <img width="975" height="423" alt="image" src="https://github.com/user-attachments/assets/253302ab-8a3a-4bbf-952a-b8b6614fb48b" />

Verde: código duplicado
<img width="975" height="162" alt="image" src="https://github.com/user-attachments/assets/a40b9647-99c3-4be2-aa21-1559680a66fe" />

 
El error UNIQUE de SQL se traduce a `CodigoDuplicadoException`.


Ronda 5: cobrar con transacción

Rojo: cobrar descuenta inventario
 <img width="975" height="469" alt="image" src="https://github.com/user-attachments/assets/7c6adc8f-8e17-4a9f-86ba-c3df42a6c1d7" />

Verde: cobrar descuenta inventario
 <img width="975" height="198" alt="image" src="https://github.com/user-attachments/assets/7ed02cf0-e39e-4ba4-94cb-56a7e876ead6" />



5.2 Si falla el cobro no cambia el inventario
Rojo
 <img width="635" height="300" alt="image" src="https://github.com/user-attachments/assets/83c1faf0-2475-403a-9f65-121cb47bdb89" />

Verde
 <img width="975" height="196" alt="image" src="https://github.com/user-attachments/assets/22c1c84e-1d8f-4988-a172-ca739a518a61" />

 


Ronda 6: ViewModel y pantalla

PANTALLAS
<img width="739" height="1600" alt="image" src="https://github.com/user-attachments/assets/91e090b5-3ca7-42b5-8bd7-345eae08b93c" />
<img width="739" height="1600" alt="image" src="https://github.com/user-attachments/assets/fe6c59e2-c60c-4d85-92e3-13d01c860d37" />

<img width="739" height="1600" alt="image" src="https://github.com/user-attachments/assets/34c5a669-8e0b-4867-b280-2d7641342e31" />
<img width="739" height="1600" alt="image" src="https://github.com/user-attachments/assets/d6647cc1-de33-4611-8196-607db3ada240" />

<img width="739" height="1600" alt="image" src="https://github.com/user-attachments/assets/75a7b377-b28b-4b4a-b591-24e55d117fcf" />
<img width="739" height="1600" alt="image" src="https://github.com/user-attachments/assets/5f60affb-15d5-4d7e-8015-9aef68cf6c3e" />
<img width="739" height="1600" alt="image" src="https://github.com/user-attachments/assets/9a023113-2792-48e3-a020-ff508bd2a99d" />

<img width="739" height="1600" alt="image" src="https://github.com/user-attachments/assets/0a7097d5-1b4b-4503-bccc-63e0afeb246e" />
<img width="739" height="1600" alt="image" src="https://github.com/user-attachments/assets/7de51ab7-4b80-437b-9d09-6293dcd637cb" />
<img width="739" height="1600" alt="image" src="https://github.com/user-attachments/assets/e0ca863e-4b6d-4873-9cb2-43f550f53dee" />
<img width="739" height="1600" alt="image" src="https://github.com/user-attachments/assets/29766552-2348-49b9-b50d-fbfdbcfadd03" />


 Resultado final

Todas las pruebas en verde
<img width="975" height="488" alt="image" src="https://github.com/user-attachments/assets/b5cc2ff2-b7dd-42d2-8d5c-11e0803dcceb" />

 


