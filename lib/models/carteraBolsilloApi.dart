import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:indicator/Global.dart';
import 'package:indicator/main.dart'; // Para poder usar la instancia global de 'controller'

/**
 * Obtiene todos los bolsillos del usuario logueado en la base de datos
 */
Future<void> getBolsillos() async {
  try {
    // Leemos dinámicamente el usuario activo del controlador global
    final String usuarioActivo = controller.User;

    final url = Uri.parse('${Global.baseUrl}cartera-bolsillos/$usuarioActivo');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'ngrok-skip-browser-warning': 'true', // Evita el bloqueo de Ngrok
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
    final String usuarioActivo = controller.User; // Extraemos el usuario logueado

    final url = Uri.parse('${Global.baseUrl}cartera-bolsillos');

    final body = json.encode({
      'usuario': usuarioActivo,
      'nombre': nombre,
      'tipo': tipo,
      'balance': balance,
    });

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'ngrok-skip-browser-warning': 'true', // Clave para que pase por Ngrok
      },
      body: body,
    );

    if (response.statusCode == 201) {
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