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