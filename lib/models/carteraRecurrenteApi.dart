import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:indicator/Global.dart';
import 'package:indicator/main.dart';
import 'package:indicator/models/carteraBolsilloApi.dart';
import 'package:indicator/models/carteraMovimientoApi.dart'; // Controlador global de GetX

/**
 * Obtiene la lista de transacciones recurrentes del usuario
 */
Future<void> getRecurrentesApi() async {
  try {
    final String usuarioActivo = controller.User;
    final url = Uri.parse('${Global.baseUrl}cartera-recurrentes/$usuarioActivo');

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
        controller.setRecurrentes(decodedData['data']);
      }
    } else {
      print("Error al obtener recurrentes: ${response.statusCode} - ${response.body}");
    }
  } catch (e) {
    print("Error de conexión en getRecurrentesApi: $e");
  }
}

/**
 * Crear una nueva transacción recurrente
 */
Future<bool> createRecurrenteApi({
  required String descripcion,
  required double monto,
  required String tipo,
  required String categoria,
  required String frecuencia,
  required int bolsilloId,
  required String proximaEjecucion,
  int? diaPago,
}) async {
  try {
    final String usuarioActivo = controller.User;
    final url = Uri.parse('${Global.baseUrl}cartera-recurrentes');

    final body = json.encode({
      'usuario': usuarioActivo,
      'descripcion': descripcion,
      'monto': monto,
      'tipo': tipo,
      'categoria': categoria,
      'frecuencia': frecuencia,
      'dia_pago': diaPago,
      'proxima_ejecucion': proximaEjecucion,
      'bolsillo_id': bolsilloId,
      'activo': true
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
        await getRecurrentesApi();
        return true;
      }
    } else {
      print("Error al crear recurrente: ${response.body}");
    }
    return false;
  } catch (e) {
    print("Error de conexión en createRecurrenteApi: $e");
    return false;
  }
}

/**
 * Ejecuta manualmente el cobro/ingreso de una transacción recurrente
 */
Future<bool> ejecutarRecurrenteApi(int id) async {
  try {
    final String usuarioActivo = controller.User;
    final url = Uri.parse('${Global.baseUrl}cartera-recurrentes/$id/ejecutar');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      },
      body: json.encode({'usuario': usuarioActivo}),
    );

    if (response.statusCode == 200) {
      final decodedData = json.decode(response.body);

      if (decodedData['status'] == 'success') {
        // Refrescar bolsillos, movimientos y recurrentes
        await getBolsillos();
        await getMovimientosApi();
        await getRecurrentesApi();
        return true;
      }
    }
    return false;
  } catch (e) {
    print("Error al ejecutar recurrente: $e");
    return false;
  }
}