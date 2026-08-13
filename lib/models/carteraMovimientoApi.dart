import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:indicator/Global.dart';
import 'package:indicator/main.dart'; // Para acceder a 'controller'
import 'package:indicator/models/carteraBolsilloApi.dart'; // Para refrescar bolsillos

// Instancia de almacenamiento seguro para recuperar el token JWT
const _storage = FlutterSecureStorage();

/**
 * Obtiene el historial de movimientos del usuario autenticado
 */
Future<void> getMovimientosApi() async {
  try {
    // 1. Recuperamos el token JWT desde Storage
    final String? token = await _storage.read(key: 'jwt_token');

    if (token == null) {
      print("Error: No existe token en el storage.");
      return;
    }

    // Ruta neutra: la identidad se determina mediante el JWT en la API
    final url = Uri.parse('${Global.baseUrl}cartera-movimientos');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'ngrok-skip-browser-warning': 'true',
      },
    );

    if (response.statusCode == 200) {
      final decodedData = json.decode(response.body);

      if (decodedData['status'] == 'success') {
        controller.setMovimientos(decodedData['data']);
      }
    } else {
      print("Error al obtener movimientos: ${response.statusCode} - ${response.body}");
    }
  } catch (e) {
    print("Error de conexión al servidor en getMovimientosApi: $e");
  }
}

/**
 * Registra un nuevo gasto o ingreso para el usuario autenticado
 */
Future<bool> createMovimientoApi({
  required int bolsilloId,
  required String tipo, // 'gasto' o 'ingreso'
  required double monto,
  required String categoria,
  String? descripcion,
}) async {
  try {
    final String? token = await _storage.read(key: 'jwt_token');

    if (token == null) {
      print("Error: No existe token en el storage.");
      return false;
    }

    final url = Uri.parse('${Global.baseUrl}cartera-movimientos');

    // No enviamos 'usuario': el ID proviene del token firmado en el backend
    final body = json.encode({
      'bolsillo_id': bolsilloId,
      'tipo': tipo,
      'monto': monto,
      'categoria': categoria,
      'descripcion': descripcion,
    });

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'ngrok-skip-browser-warning': 'true',
      },
      body: body,
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final decodedData = json.decode(response.body);

      if (decodedData['status'] == 'success') {
        // Sincronizamos nuevamente los bolsillos (saldos actualizados) y el historial
        await getBolsillos();
        await getMovimientosApi();
        return true;
      }
    } else {
      print("Error al registrar movimiento: ${response.body}");
    }
    return false;
  } catch (e) {
    print("Error de conexión al servidor en createMovimientoApi: $e");
    return false;
  }
}