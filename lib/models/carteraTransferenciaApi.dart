import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:indicator/Global.dart';
import 'package:indicator/main.dart'; // Para acceder a 'controller'
import 'package:indicator/models/carteraBolsilloApi.dart'; // Refresca bolsillos
import 'package:indicator/models/carteraMovimientoApi.dart'; // Refresca historial

// Instancia de almacenamiento seguro para recuperar el token JWT
const _storage = FlutterSecureStorage();

/**
 * Realiza una transferencia entre dos bolsillos propios del usuario autenticado
 */
Future<bool> realizarTransferenciaApi({
  required int bolsilloOrigenId,
  required int bolsilloDestinoId,
  required double monto,
  String? descripcion,
}) async {
  try {
    // 1. Recuperamos el token JWT desde Storage
    final String? token = await _storage.read(key: 'jwt_token');

    if (token == null) {
      print("Error: No existe un token activo en storage.");
      return false;
    }

    final url = Uri.parse('${Global.baseUrl}cartera-transferencias');

    // La identidad del usuario la valida el servidor a partir del token JWT
    final body = json.encode({
      'bolsillo_origen_id': bolsilloOrigenId,
      'bolsillo_destino_id': bolsilloDestinoId,
      'monto': monto,
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
        // Refrescamos bolsillos (saldos actualizados) y el historial de movimientos
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