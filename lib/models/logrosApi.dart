import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:indicator/Global.dart';
import 'package:indicator/main.dart';

// Instancia segura para recuperar el token JWT del usuario
const _storage = FlutterSecureStorage();

/**
 * Obtiene el catálogo general de logros
 */
Future<void> getLogros() async {
  try {
    final String? token = await _storage.read(key: 'jwt_token');

    if (token == null) {
      print("Error: No existe un token activo en storage.");
      return;
    }

    final response = await http.get(
      Uri.parse("${Global.baseUrl}logro"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'ngrok-skip-browser-warning': 'true',
      },
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      controller.setLogros(result["data"]);
    } else {
      print("Error al obtener los logros: [${response.statusCode}] ${response.body}");
    }
  } catch (e) {
    print("Excepción en getLogros: $e");
  }
}

/**
 * Obtiene los logros pendientes asignados al usuario autenticado
 */
Future<void> getLogrosPendientes() async {
  try {
    final String? token = await _storage.read(key: 'jwt_token');

    if (token == null) {
      print("Error: No existe un token activo en storage.");
      return;
    }

    final response = await http.get(
      Uri.parse("${Global.baseUrl}logro/pendiente"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'ngrok-skip-browser-warning': 'true',
      },
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      controller.setLogros(result["data"]);
    } else {
      print("Error al obtener logros pendientes: [${response.statusCode}] ${response.body}");
    }
  } catch (e) {
    print("Excepción en getLogrosPendientes: $e");
  }
}

/**
 * Obtiene el resumen de logros agrupados por semanas para el usuario autenticado
 */
Future<List> getLogrosSemanas() async {
  try {
    final String? token = await _storage.read(key: 'jwt_token');

    if (token == null) {
      print("Error: No existe un token activo en storage.");
      return [];
    }

    final response = await http.get(
      Uri.parse("${Global.baseUrl}logro/weeks"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'ngrok-skip-browser-warning': 'true',
      },
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      return result["data"] ?? [];
    } else {
      print("Error al obtener logros por semanas: [${response.statusCode}] ${response.body}");
      return [];
    }
  } catch (e) {
    print("Excepción en getLogrosSemanas: $e");
    return [];
  }
}

/**
 * Registra un nuevo logro o meta vinculada a un indicador
 */
Future<bool> newLogroApi(String nombre, int puntos, int idIndicador) async {
  try {
    final String? token = await _storage.read(key: 'jwt_token');

    if (token == null) {
      print("Error: No existe un token activo en storage.");
      return false;
    }

    final response = await http.post(
      Uri.parse("${Global.baseUrl}logro"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'ngrok-skip-browser-warning': 'true',
      },
      body: jsonEncode({
        "nombre": nombre,
        "puntos": puntos,
        "idIndicador": idIndicador,
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return true;
    } else {
      print("Error al crear logro: [${response.statusCode}] ${response.body}");
      return false;
    }
  } catch (e) {
    print("Excepción en newLogroApi: $e");
    return false;
  }
}

/**
 * Marca como completado/verificado un logro específico
 */
Future<bool> updateCheckLogro(int id) async {
  try {
    final String? token = await _storage.read(key: 'jwt_token');

    if (token == null) {
      print("Error: No existe un token activo en storage.");
      return false;
    }

    final response = await http.patch(
      Uri.parse("${Global.baseUrl}logro/check/$id"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'ngrok-skip-browser-warning': 'true',
      },
    );

    return response.statusCode == 200;
  } catch (e) {
    print("Excepción en updateCheckLogro: $e");
    return false;
  }
}

Future<bool> updateLogroApi(int id, String nombre, int puntos, int idIndicador) async {
  try {
    final String? token = await _storage.read(key: 'jwt_token');

    if (token == null) {
      print("Error: No existe un token activo en storage.");
      return false;
    }

    final response = await http.put(
      Uri.parse("${Global.baseUrl}logro/$id"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'ngrok-skip-browser-warning': 'true',
      },
      body: jsonEncode({
        "nombre": nombre,
        "puntos": puntos,
        "idIndicador": idIndicador,
      }),
    );

    if (response.statusCode == 200) {
      getLogrosPendientes();
      return true;
    } else {
      print("Error al actualizar logro: [${response.statusCode}] ${response.body}");
      return false;
    }
  } catch (e) {
    print("Excepción en updateLogroApi: $e");
    return false;
  }
}