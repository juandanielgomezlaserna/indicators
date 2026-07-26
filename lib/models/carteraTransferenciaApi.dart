import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:indicator/Global.dart';
import 'package:indicator/main.dart'; // Para acceder a 'controller'
import 'package:indicator/models/carteraBolsilloApi.dart'; // Refresca bolsillos
import 'package:indicator/models/carteraMovimientoApi.dart'; // Refresca historial

/**
 * Realiza una transferencia entre dos bolsillos propios
 */
Future<bool> realizarTransferenciaApi({
  required int bolsilloOrigenId,
  required int bolsilloDestinoId,
  required double monto,
  String? descripcion,
}) async {
  try {
    final String usuarioActivo = controller.User;

    final url = Uri.parse('${Global.baseUrl}cartera-transferencias');

    final body = json.encode({
      'usuario': usuarioActivo,
      'bolsillo_origen_id': bolsilloOrigenId,
      'bolsillo_destino_id': bolsilloDestinoId,
      'monto': monto,
      'descripcion': descripcion,
    });

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      },
      body: body,
    );

    if (response.statusCode == 201) {
      final decodedData = json.decode(response.body);

      if (decodedData['status'] == 'success') {
        // Refrescamos bolsillos (saldos actualizados) y movimientos
        await getBolsillos();
        await getMovimientosApi();
        return true;
      }
    } else {
      print("Error al realizar transferencia: ${response.body}");
    }
    return false;
  } catch (e) {
    print("Error de conexión en realizarTransferenciaApi: $e");
    return false;
  }
}