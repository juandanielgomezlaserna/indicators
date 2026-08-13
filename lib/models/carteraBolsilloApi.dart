import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:indicator/Global.dart';
import 'package:indicator/main.dart'; // Para usar 'controller'

// Instancia de almacenamiento seguro
const _storage = FlutterSecureStorage();

/**
 * Obtiene todos los bolsillos del usuario logueado en la base de datos
 */
Future<void> getBolsillos() async {
  try {
    // 1. Recuperamos el token directamente desde el Storage
    final String? token = await _storage.read(key: 'jwt_token');

    if (token == null) {
      print("Error: No existe token en el storage.");
      return;
    }

    final url = Uri.parse('${Global.baseUrl}cartera-bolsillos');

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
        controller.setBolsillos(decodedData['data']);
      }
    } else {
      print("Error al obtener bolsillos: ${response.statusCode} - ${response.body}");
    }
  } catch (e) {
    print("Error de conexión al servidor en getBolsillos: $e");
  }
}

/**
 * Crea un nuevo bolsillo asociándolo al usuario activo
 */
Future<bool> createBolsillo({
  required String nombre,
  required String tipo,
  required double balance,
}) async {
  try {
    // 1. Recuperamos el token directamente desde el Storage
    final String? token = await _storage.read(key: 'jwt_token');

    if (token == null) {
      print("Error: No existe token en el storage.");
      return false;
    }

    final url = Uri.parse('${Global.baseUrl}cartera-bolsillos');

    final body = json.encode({
      'nombre': nombre,
      'tipo': tipo,
      'balance': balance,
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
        // Refrescamos la lista de inmediato de forma reactiva
        await getBolsillos();
        return true;
      }
    } else {
      print("Error en base de datos al crear bolsillo: ${response.body}");
    }
    return false;
  } catch (e) {
    print("Error de conexión al servidor en createBolsillo: $e");
    return false;
  }
}