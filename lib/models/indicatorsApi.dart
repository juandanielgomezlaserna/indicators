import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:indicator/Global.dart';
import 'package:indicator/main.dart';

Future<void> getIndicators () async {
  final response = await http.get(
      Uri.parse("${Global.baseUrl}indicator"),
    headers: {
      'ngrok-skip-browser-warning': 'true',
      "usuario" : controller.User
    }
  );

  if(response.statusCode == 200){
    final result = jsonDecode(response.body);
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
    final result = jsonDecode(response.body);
    await getIndicators();
  }else{
    print("Error al crear el indicador: ${response.body}");
  }
}

Future<void> getIndicatorById(int id) async {
  final response = await http.get(
      Uri.parse("${Global.baseUrl}indicator/$id"), // Pasamos el ID por la URL
      headers: {
        'ngrok-skip-browser-warning': 'true',
        "usuario": controller.User
      }
  );

  if (response.statusCode == 200) {
    final result = jsonDecode(response.body);

    // Le pasamos el mapa completo de "data" a tu controlador (que incluye indicador y logros)
    controller.setIndicator(result["data"]);
  } else {
    print("Error al obtener el indicador detallado: ${response.body}");
  }
}