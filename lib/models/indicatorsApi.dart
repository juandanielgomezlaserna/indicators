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
Future<void> newIndicator(String nombre, int valor, String icono) async {
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
      "icono": icono,
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

/**
 * Actualiza un indicador existente enviando los campos modificados
 */
Future<bool> updateIndicator(int id, {String? nombre, int? valor, String? icono}) async {
  try {
    final String? token = await _storage.read(key: 'jwt_token');

    if (token == null) {
      print("Error: No existe un token activo en storage.");
      return false;
    }

    final url = Uri.parse("${Global.baseUrl}indicator/$id");

    // Construimos el mapa dinámicamente para enviar solo los campos que se deseen actualizar
    final Map<String, dynamic> dataToUpdate = {};
    if (nombre != null) dataToUpdate["nombre"] = nombre;
    if (valor != null) dataToUpdate["valor"] = valor;
    if (icono != null) dataToUpdate["icono"] = icono;

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'ngrok-skip-browser-warning': 'true',
      },
      body: jsonEncode(dataToUpdate),
    );

    if (response.statusCode == 200) {
      // Si se actualizó correctamente, refrescamos la lista general de indicadores
      await getIndicators();
      return true;
    } else {
      print("Error al actualizar el indicador: [${response.statusCode}] ${response.body}");
      return false;
    }
  } catch (e) {
    print("Error de conexión en updateIndicator: $e");
    return false;
  }
}

Future<bool> deleteIndicator(int id) async {
  try {
    final String? token = await _storage.read(key: 'jwt_token');

    if (token == null) {
      print("Error: No existe un token activo en storage.");
      return false;
    }

    final url = Uri.parse("${Global.baseUrl}indicator/$id");

    final response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'ngrok-skip-browser-warning': 'true',
      },
    );

    if (response.statusCode == 200) {
      // Si se eliminó correctamente, refrescamos la lista general de indicadores
      await getIndicators();
      return true;
    } else {
      print("Error al eliminar el indicador: [${response.statusCode}] ${response.body}");
      return false;
    }
  } catch (e) {
    print("Error de conexión en deleteIndicator: $e");
    return false;
  }
}