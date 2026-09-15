import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:indicator/Global.dart';

// Instancia de almacenamiento seguro para recuperar el token JWT
const _storage = FlutterSecureStorage();

/**
 * Consulta si el usuario autenticado debe iniciar el Ritual de Cierre Semanal
 * enviando la fecha/hora local del dispositivo.
 */
Future<Map<String, dynamic>?> getEstadoRitualCierreApi() async {
  try {
    // 1. Lectura del token JWT desde Storage
    final String? token = await _storage.read(key: 'jwt_token');

    if (token == null) {
      print("Error: No existe un token activo en storage.");
      return null;
    }

    // Ruta hacia el endpoint de evaluación del ritual
    final url = Uri.parse('${Global.baseUrl}ritual-cierre/estado');

    // Petición POST enviando la marca de tiempo local ISO 8601 del cliente
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'ngrok-skip-browser-warning': 'true',
      },
      body: jsonEncode({
        'fecha_cliente': DateTime.now().toIso8601String(),
      }),
    );

    if (response.statusCode == 200) {
      final decodedData = json.decode(response.body);
      if (decodedData['status'] == 'success') {
        return decodedData['data'];
      }
    }
    print("⚠️ Error Server Ritual Cierre [${response.statusCode}]: ${response.body}");
    return null;
  } catch (e) {
    print("❌ Excepción en getEstadoRitualCierreApi: $e");
    return null;
  }
}
