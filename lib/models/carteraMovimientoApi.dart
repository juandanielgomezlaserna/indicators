import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:indicator/Global.dart';
import 'package:indicator/main.dart'; // Para acceder a 'controller'
import 'package:indicator/models/carteraBolsilloApi.dart'; // Para refrescar bolsillos

/**
 * Obtiene el historial de movimientos del usuario activo
 */
Future<void> getMovimientosApi() async {
  try {
    final String usuarioActivo = controller.User;

    final url = Uri.parse('${Global.baseUrl}cartera-movimientos/$usuarioActivo');

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
        // Asumiendo que agregaremos 'movimientos' al controlador
        controller.setMovimientos(decodedData['data']);
      }
    } else {
      print("Error al obtener movimientos: ${response.statusCode} - ${response.body}");
    }
  } catch (e) {
    print("Error de conexión al servidor en getMovimientos: $e");
  }
}

/**
 * Registra un nuevo gasto o ingreso
 */
Future<bool> createMovimientoApi({
  required int bolsilloId,
  required String tipo, // 'gasto' o 'ingreso'
  required double monto,
  required String categoria,
  String? descripcion,
}) async {
  try {
    final String usuarioActivo = controller.User;

    final url = Uri.parse('${Global.baseUrl}cartera-movimientos');

    final body = json.encode({
      'bolsillo_id': bolsilloId,
      'tipo': tipo,
      'monto': monto,
      'categoria': categoria,
      'descripcion': descripcion,
      'usuario': usuarioActivo,
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
        // Sincronizamos nuevamente los bolsillos (por los saldos actualizados) y los movimientos
        await getBolsillos();
        await getMovimientosApi();
        return true;
      }
    } else {
      print("Error al registrar movimiento: ${response.body}");
    }
    return false;
  } catch (e) {
    print("Error de conexión al servidor en createMovimiento: $e");
    return false;
  }
}