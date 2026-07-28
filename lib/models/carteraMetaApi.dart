import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:indicator/Global.dart';
import 'package:indicator/main.dart'; // Para acceder a 'controller'
import 'package:indicator/models/carteraBolsilloApi.dart'; // Refresca bolsillos
import 'package:indicator/models/carteraMovimientoApi.dart'; // Refresca historial

/**
 * Obtiene la lista de metas de ahorro del usuario
 */
Future<void> getMetasApi() async {
  try {
    final String usuarioActivo = controller.User;

    final url = Uri.parse('${Global.baseUrl}cartera-metas/$usuarioActivo');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      },
    );

    if (response.statusCode == 200) {
      final decodedData = json.decode(response.body);

      if (decodedData['status'] == 'success') {
        controller.setMetas(decodedData['data']);
      }
    } else {
      print("Error al obtener metas: ${response.statusCode} - ${response.body}");
    }
  } catch (e) {
    print("Error de conexión en getMetasApi: $e");
  }
}

/**
 * Crear una nueva meta de ahorro
 */
Future<bool> createMetaApi({
  required String nombre,
  required double montoObjetivo,
  double montoActual = 0.0,
  int? bolsilloOrigenId,
}) async {
  try {
    final String usuarioActivo = controller.User;

    final url = Uri.parse('${Global.baseUrl}cartera-metas');

    final body = json.encode({
      'usuario': usuarioActivo,
      'nombre': nombre,
      'monto_objetivo': montoObjetivo,
      'monto_actual': montoActual,
      'bolsillo_origen_id': bolsilloOrigenId,
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
        await getMetasApi();
        return true;
      }
    } else {
      print("Error al crear meta: ${response.body}");
    }
    return false;
  } catch (e) {
    print("Error de conexión en createMetaApi: $e");
    return false;
  }
}

/**
 * Realiza un depósito a una meta de ahorro desde un bolsillo
 */
Future<bool> depositarAMetaApi({
  required int metaId,
  required int bolsilloId,
  required double monto,
  String? descripcion,
}) async {
  try {
    final String usuarioActivo = controller.User;

    final url = Uri.parse('${Global.baseUrl}cartera-metas/$metaId/depositar');

    final body = json.encode({
      'usuario': usuarioActivo,
      'bolsillo_id': bolsilloId,
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

    if (response.statusCode == 200) {
      final decodedData = json.decode(response.body);

      if (decodedData['status'] == 'success') {
        // Refrescamos metas, bolsillos y movimientos en cascada
        await getMetasApi();
        await getBolsillos();
        await getMovimientosApi();
        return true;
      }
    } else {
      print("Error al depositar a la meta: ${response.body}");
    }
    return false;
  } catch (e) {
    print("Error de conexión en depositarAMetaApi: $e");
    return false;
  }
}