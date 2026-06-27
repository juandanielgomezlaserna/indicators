import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:indicator/models/indicatorsApi.dart';
import 'package:indicator/models/logrosApi.dart';
import 'package:indicator/models/wishApi.dart';
import 'package:indicator/views/indicator/HomeIndicator.dart';
import 'package:indicator/views/selectUser.dart';
import 'package:indicator/views/wish/HomeWish.dart';

class MyController extends GetxController{
  Timer? timer;
  final indicators = [].obs;
  final indicatorsWishes = [].obs;
  final logros = [].obs;
  final logrosWeeks = [].obs;
  final user = "".obs;
  final indicator = {}.obs;
  final page = "".obs;
  final pages = {
    "indicator" : Homeindicator(),
    "wish" : Homewish(),
  }.obs;

  void setSplash (){
    timer?.cancel();
    int seconds = 2;
    timer = Timer.periodic(Duration(seconds: 1), (timer){
      if(seconds > 0){
        seconds--;
      }else{
        Get.off(() => Selectuser());
        timer.cancel();
      }
    });
  }

  void setPage (String item){
    page.value = item;
  }

  void setIndicators (List item) {
    indicators.value = item;
  }

  void setLogros (List item) {
    logros.value = item;
  }

  void setLogrosWeeks (List item) {
    logrosWeeks.value = item;
  }

  void setUser (String item) {
    user.value = item;
  }

  void setIndicator (Map item) {
    indicator.value = item;
  }

  void setIndicatorsWishes (List item) {
    indicatorsWishes.value = item;
  }

  Future<void> newLogroController(String name, String puntosString, int idIndicador) async {
    int puntos = int.parse(puntosString);

    // Llamamos a la API
    bool success = await newLogroApi(name, puntos, idIndicador);
    if (success) {
      Get.back();
      Get.snackbar(
        "¡Logro Creado!",
        "Los datos se guardaron correctamente.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF4CAF50), // Verde de éxito
        colorText: const Color(0xFFFFFFFF),
      );
      await getLogrosPendientes(); // Refrescamos la vista reactiva
    } else {
      // ⚡ MANEJO DE ERRORES NIVEL EXPERTO
      Get.snackbar(
        "Error del Servidor",
        "La API rechazó los datos o está caída. Intenta de nuevo.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFF44336), // Rojo de alerta
        colorText: const Color(0xFFFFFFFF),
        duration: const Duration(seconds: 4),
      );
    }
  }

  Future<void> newWishController (String name, int idIndicador) async {
    // Llamamos a la API
    bool success = await newWishApi(idIndicador, name);
    if (success) {
      Get.back();
      Get.snackbar(
        "¡Deseo Creado!",
        "Los datos se guardaron correctamente.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF4CAF50), // Verde de éxito
        colorText: const Color(0xFFFFFFFF),
      );
      await getWishesByIndicator(indicator["indicator"]["id"]);
    } else {
      // ⚡ MANEJO DE ERRORES NIVEL EXPERTO
      Get.snackbar(
        "Error del Servidor",
        "La API rechazó los datos o está caída. Intenta de nuevo.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFF44336), // Rojo de alerta
        colorText: const Color(0xFFFFFFFF),
        duration: const Duration(seconds: 4),
      );
    }
  }

  void toggleLogro(int index) async {
    // 2. Sincronización con el servidor
    bool exito = await updateCheckLogro(index);
    getLogrosPendientes();

    // 3. Reversión si el servidor falla (Blindaje)
    if (!exito) {
      Get.snackbar("Error", "No se pudo sincronizar el cambio",);
    }
  }

  Future<void> newIndicadorController (nombre, valorString, tipo) async {
    int valor = int.parse(valorString);
    await newIndicator(nombre, valor, tipo);
  }


  List get Indicators => indicators.value;
  List get Logros => logros.value;
  List get LogrosWeeks => logrosWeeks.value;
  String get User => user.value;
  Map get Indicator => indicator.value;
  Map get Pages => pages.value;
  String get Page => page.value;
  List get IndicatorsWishes => indicatorsWishes.value;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    setSplash();
    setPage("indicator");
  }
}