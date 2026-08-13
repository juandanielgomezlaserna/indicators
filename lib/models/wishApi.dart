import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:indicator/Global.dart';
import 'package:indicator/main.dart';

// Instancia para el almacenamiento seguro del token JWT
const _storage = FlutterSecureStorage();

/**
 * Obtiene la lista de indicadores que tienen deseos asociados para el usuario autenticado
 */
Future<void> getIndicatorsWishes() async {
  try {
    final String? token = await _storage.read(key: 'jwt_token');

    if (token == null) {
      print("Error: No existe un token activo en storage.");
      return;
    }

    final response = await http.get(
      Uri.parse("${Global.baseUrl}wish/indicator"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'ngrok-skip-browser-warning': 'true',
      },
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      controller.setIndicatorsWishes(result["data"]);
    } else {
      print("Error al obtener indicadores con deseos: [${response.statusCode}] ${response.body}");
    }
  } catch (e) {
    print("Excepción en getIndicatorsWishes: $e");
  }
}

/**
 * Obtiene el detalle de un indicador y sus deseos asociados
 */
Future<void> getWishesByIndicator(int id) async {
  try {
    final String? token = await _storage.read(key: 'jwt_token');

    if (token == null) {
      print("Error: No existe un token activo en storage.");
      return;
    }

    final response = await http.get(
      Uri.parse("${Global.baseUrl}wish/indicator/$id"),
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
      print("Error al obtener el indicador con deseos: [${response.statusCode}] ${response.body}");
    }
  } catch (e) {
    print("Excepción en getWishesByIndicator: $e");
  }
}

/**
 * Crea un nuevo deseo o aspiración asociado a un indicador
 */
Future<bool> newWishApi(int idIndicator, String name) async {
  try {
    final String? token = await _storage.read(key: 'jwt_token');

    if (token == null) {
      print("Error: No existe un token activo en storage.");
      return false;
    }

    final response = await http.post(
      Uri.parse("${Global.baseUrl}wish"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'ngrok-skip-browser-warning': 'true',
      },
      body: jsonEncode({
        "indicador_id": idIndicator,
        "nombre": name,
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return true;
    } else {
      print("Error al crear el deseo: [${response.statusCode}] ${response.body}");
      return false;
    }
  } catch (e) {
    print("Excepción en newWishApi: $e");
    return false;
  }
}

/**
 * Elimina un deseo por su ID
 */
Future<bool> deleteWishApi(int idWish) async {
  try {
    final String? token = await _storage.read(key: 'jwt_token');

    if (token == null) {
      print("Error: No existe un token activo en storage.");
      return false;
    }

    final response = await http.delete(
      Uri.parse("${Global.baseUrl}wish/$idWish"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'ngrok-skip-browser-warning': 'true',
      },
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      return true;
    } else {
      print("Error al eliminar el deseo: [${response.statusCode}] ${response.body}");
      return false;
    }
  } catch (e) {
    print("Excepción en deleteWishApi: $e");
    return false;
  }
}