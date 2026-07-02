import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:indicator/Global.dart';
import 'package:indicator/main.dart';

Future<void> getIndicatorsWishes () async {
  final response = await http.get(
    // Concatenamos directo porque tu baseUrl ya incluye la barra '/' al final
      Uri.parse("${Global.baseUrl}wish/indicator"),
      headers: {
        'ngrok-skip-browser-warning': 'true',
        "usuario" : controller.User // Esto alimenta perfectamente tu req.headers['usuario']
      }
  );

  if(response.statusCode == 200){
    final result = jsonDecode(response.body);
    // Mantenemos result["data"] porque tu Express devuelve { status: 'success', data: [...] }
    controller.setIndicatorsWishes(result["data"]);
  }else{
    print("Error al obtener los indicadores: ${response.body}");
  }
}

Future<void> getWishesByIndicator (int id) async {
  final response = await http.get(
    // Concatenamos directo porque tu baseUrl ya incluye la barra '/' al final
      Uri.parse("${Global.baseUrl}wish/indicator/$id"),
      headers: {
        'ngrok-skip-browser-warning': 'true',
        "usuario" : controller.User // Esto alimenta perfectamente tu req.headers['usuario']
      }
  );

  if(response.statusCode == 200){
    final result = jsonDecode(response.body);
    // Mantenemos result["data"] porque tu Express devuelve { status: 'success', data: [...] }
    controller.setIndicator(result["data"]);
  }else{
    print("Error al obtener el indicador con los deseos: ${response.body}");
  }
}

Future<bool> newWishApi (int idIndicator, String name) async {
  try {
    final response = await http.post(
      Uri.parse("${Global.baseUrl}wish"),
      headers: {
        "Content-Type": "application/json",
        'ngrok-skip-browser-warning': 'true',
      },
      body: jsonEncode({
        "indicador_id": idIndicator,
        "nombre": name,
      }),
    );

    if (response.statusCode == 201) {
      return true;
    } else {
      print("Error de API: ${response.statusCode} - ${response.body}");
      return false;
    }
  } catch (e) {
    print("Excepción atrapada: $e");
    return false;
  }
}

Future<bool> deleteWishApi (int idWish) async {
  try {
    final response = await http.delete(
      // ✅ CORREGIDO: Pasamos el ID directamente en la URL como espera req.params
      Uri.parse("${Global.baseUrl}wish/$idWish"),
      headers: {
        "Content-Type": "application/json",
        'ngrok-skip-browser-warning': 'true',
      },
    );

    // ✅ CORREGIDO: El backend responde con un 200 OK al eliminar correctamente
    if (response.statusCode == 200) {
      return true;
    } else {
      print("Error de API: ${response.statusCode} - ${response.body}");
      return false;
    }
  } catch (e) {
    print("Excepción atrapada: $e");
    return false;
  }
}