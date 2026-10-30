/// tdo el dinero se maneja en centavos itn

/// conviertir centavos intt a texto con formato de pesos
String formatearPesos(int centavos) {
  final negativo = centavos < 0;          // guarda el signo aparte
  final abs = centavos.abs();             // trabaj con el valor positivo
  final pesos = (abs ~/ 100).toString();  // división
  final cents = (abs % 100).toString().padLeft(2, '0'); 

  // la expresion regular inserta una coma cada 3 dígitos
  final conComas = pesos.replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ',',
  );

  return '${negativo ? '-' : ''}\$$conComas.$cents';
}

/// convierte texto 12.5 o 12.50 a 1250 centavos
/// lo que escribe el cajero llega como texto y aquí lo pasamos a int sin usar double
int pesosACentavos(String texto) {
  final limpio = texto.replaceAll(RegExp(r'[\$,\s]'), '');
  // Separamos pesos y centavos por el punto: "12.5" -> ["12", "5"]
  final partes = limpio.split('.');

  // inválido si hay mas de un punto"1.2.3") o si no hay nada ("" o ".")
  if (partes.length > 2 ||
      partes[0].isEmpty && (partes.length < 2 || partes[1].isEmpty)) {
    throw FormatException('Monto inválido: $texto');
  }
 
  final pesos = partes[0].isEmpty ? 0 : int.parse(partes[0]);
  var cents = 0;
  if (partes.length == 2 && partes[1].isNotEmpty) {
    // padRight: "5" -> "50" (12.5 son 50 centavos, no 5). Solo tomamos 2 dígitos.
    cents = int.parse(partes[1].padRight(2, '0').substring(0, 2));
  }
  return pesos * 100 + cents;
}
