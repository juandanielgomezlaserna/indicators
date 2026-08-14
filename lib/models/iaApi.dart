import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:indicator/Global.dart';

const _storage = FlutterSecureStorage();

Future<Map<String, dynamic>?> obtenerTarjetaDiariaIaApi() async {
  try {
    // 1. Obtener el token de autenticación del storage seguro
    final String? token = await _storage.read(key: 'jwt_token');

    if (token == null) {
      print("Error: No existe un token activo en storage.");
      return null;
    }

    // 2. Construir la URL apuntando al nuevo endpoint general de IA
    final url = Uri.parse('${Global.baseUrl}ia/tarjeta-diaria');

    // 3. Realizar la petición GET al servidor
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        'ngrok-skip-browser-warning': 'true',
      },
    );

    // 4. Validar si la respuesta fue exitosa (200 OK)
    if (response.statusCode == 200) {
      final decodedData = jsonDecode(response.body);

      // Extraer la propiedad 'data' que contiene el JSON estructurado por Gemini
      if (decodedData is Map && decodedData.containsKey('data')) {
        return Map<String, dynamic>.from(decodedData['data']);
      }

      return null;
    }

    print("⚠️ Error Server [${response.statusCode}]: ${response.body}");
    return null;
  } catch (e) {
    print("❌ Excepción en obtenerTarjetaDiariaIaApi: $e");
    return null;
  }
}