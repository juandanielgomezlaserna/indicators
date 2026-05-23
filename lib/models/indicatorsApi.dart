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