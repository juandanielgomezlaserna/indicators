import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:indicator/Global.dart';
import 'package:indicator/main.dart';

Future<void> getIndicators () async {
  final response = await http.get(
      Uri.parse("${Global.baseUrl}indicator"),
    headers: {
      'ngrok-skip-browser-warning': 'true',
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
      "tipo": tipo
    }),
  );

  if(response.statusCode == 201){
    final result = jsonDecode(response.body);
    await getIndicators();
  }else{
    print("Error al crear el indicador: ${response.body}");
  }
}