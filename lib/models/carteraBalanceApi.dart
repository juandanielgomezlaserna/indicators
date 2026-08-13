import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:indicator/Global.dart';

// Instancia de almacenamiento seguro para recuperar el token JWT
const _storage = FlutterSecureStorage();

/**
 * Obtiene el resumen de balance financiero para el usuario autenticado
 */
Future<Map<String, dynamic>?> getResumenBalanceApi() async {
  try {
    // 1. Lectura del token JWT desde Storage
    final String? token = await _storage.read(key: 'jwt_token');

    if (token == null) {
      print("Error: No existe un token activo en storage.");
      return null;
    }

    // Ruta neutra: el backend identifica al usuario decodificando el JWT
    final url = Uri.parse('${Global.baseUrl}cartera-balance/resumen');

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
        return decodedData['data'];
      }
    }
    print("⚠️ Error Server Balance [${response.statusCode}]: ${response.body}");
    return null;
  } catch (e) {
    print("❌ Excepción en getResumenBalanceApi: $e");
    return null;
  }
}