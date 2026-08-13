import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:indicator/Global.dart';
import 'package:indicator/main.dart';

// Instancia para acceder al token guardado de forma segura en el dispositivo
const _storage = FlutterSecureStorage();

/**
 * Obtiene la lista de indicadores pertenecientes al usuario autenticado
 */
Future<void> getIndicators() async {
  try {
    final String? token = await _storage.read(key: 'jwt_token');

    if (token == null) {
      print("Error: No existe un token activo en storage.");
      return;
    }

    final url = Uri.parse("${Global.baseUrl}indicator");

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'ngrok-skip-browser-warning': 'true',
      },
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);

      if (result['status'] == 'success' || result['data'] != null) {
        controller.setIndicators(result["data"]);
      }
    } else {
      print("Error al obtener los indicadores: [${response.statusCode}] ${response.body}");
    }
  } catch (e) {
    print("Error de conexión en getIndicators: $e");
  }
}

/**
 * Registra un nuevo indicador para el usuario autenticado
 */
Future<void> newIndicator(String nombre, int valor, String tipo) async {
  try {
    final String? token = await _storage.read(key: 'jwt_token');

    if (token == null) {
      print("Error: No existe un token activo en storage.");
      return;
    }

    final url = Uri.parse("${Global.baseUrl}indicator");

    // No enviamos 'usuario': el ID del usuario se extrae del JWT en el backend
    final body = jsonEncode({
      "nombre": nombre,
      "valor": valor,
      "tipo": tipo,
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
      // Al crearse correctamente, refrescamos la lista general de indicadores
      await getIndicators();
    } else {
      print("Error al crear el indicador: [${response.statusCode}] ${response.body}");
    }
  } catch (e) {
    print("Error de conexión en newIndicator: $e");
  }
}

/**
 * Obtiene los detalles y registros formateados de un indicador específico por ID
 */
Future<void> getIndicatorById(int id) async {
  try {
    final String? token = await _storage.read(key: 'jwt_token');

    if (token == null) {
      print("Error: No existe un token activo en storage.");
      return;
    }

    final url = Uri.parse("${Global.baseUrl}indicator/$id");

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'ngrok-skip-browser-warning': 'true',
      },
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      controller.setIndicator(result["data"]);
    } else {
      print("Error al obtener el indicador detallado: [${response.statusCode}] ${response.body}");
    }
  } catch (e) {
    print("Error de conexión en getIndicatorById: $e");
  }
}