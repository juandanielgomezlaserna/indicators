import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:indicator/Global.dart';
import 'package:indicator/main.dart';

Future<void> getIndicators () async {
  final response = await http.get(
    // Concatenamos directo porque tu baseUrl ya incluye la barra '/' al final
      Uri.parse("${Global.baseUrl}indicator"),
      headers: {
        'ngrok-skip-browser-warning': 'true',
        "usuario" : controller.User // Esto alimenta perfectamente tu req.headers['usuario']
      }
  );

  if(response.statusCode == 200){
    final result = jsonDecode(response.body);
    // Mantenemos result["data"] porque tu Express devuelve { status: 'success', data: [...] }
    controller.setIndicators(result["data"]);
  }else{
    print("Error al obtener los indicadores: ${response.body}");
  }
}

Future<void> newIndicator (String nombre, int valor, String tipo) async {
  final response = await http.post(
    Uri.parse("${Global.baseUrl}indicator"),
    headers: {
      'ngrok-skip-browser-warning': 'true',
      "Content-Type": "application/json",
    },
    body: jsonEncode({
      "nombre": nombre,
      "valor": valor,
      "tipo": tipo,
      "usuario" : controller.User
    }),
  );

  if(response.statusCode == 201){
    // Al crearse correctamente, refrescamos la lista
    await getIndicators();
  }else{
    print("Error al crear el indicador: ${response.body}");
  }
}

Future<void> getIndicatorById(int id) async {
  final response = await http.get(
      Uri.parse("${Global.baseUrl}indicator/$id"),
      headers: {
        'ngrok-skip-browser-warning': 'true',
        "usuario": controller.User // Tu controlador exige este header también para el getById
      }
  );

  if (response.statusCode == 200) {
    final result = jsonDecode(response.body);
    // Recibe el objeto mapeado y formateado por semanas que armaste en Node.js
    controller.setIndicator(result["data"]);
  } else {
    print("Error al obtener el indicador detallado: ${response.body}");
  }
}