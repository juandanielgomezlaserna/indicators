import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:indicator/models/authService.dart';
import 'package:indicator/models/indicatorsApi.dart';
import 'package:indicator/models/logrosApi.dart';
import 'package:indicator/models/wishApi.dart';
import 'package:indicator/views/HomePrincipal.dart';
import 'package:indicator/views/finance/Homefinance.dart';
import 'package:indicator/views/home/Homehome.dart';
import 'package:indicator/views/indicator/HomeIndicator.dart';
import 'package:indicator/views/login/login.dart';
import 'package:indicator/views/user/Homeuser.dart';
import 'package:indicator/views/wish/HomeWish.dart';

class MyController extends GetxController{
  Timer? timer;
  final indicators = [].obs;
  final indicatorsWishes = [].obs;
  final logros = [].obs;
  final logrosWeeks = [].obs;
  final user = {}.obs;
  final indicator = {}.obs;
  final page = "".obs;
  final pages = {
    "indicator" : Homeindicator(),
    "wish" : Homewish(),
    "finance" : Homefinance(),
    "user" : Homeuser(),
    "home" : Homehome(),
  }.obs;
  final bolsillos = [].obs;
  final movimientos = [].obs;
  final deudas = [].obs;
  final metas = [].obs;
  final recurrentes = [].obs;

  Future<void> setSplash() async {
    // 1. Espera 2 segundos para mostrar la pantalla de carga/splash
    await Future.delayed(const Duration(seconds: 2));

    try {
      final authService = AuthService();

      // 2. Valida el token con el servidor y carga el usuario en UserController
      bool isAuthenticated = await authService.checkAuth();

      // 3. Redirige de forma única y absoluta según el resultado
      if (isAuthenticated) {
        // Usamos Get.offAll para limpiar el splash y asegurar una sola navegación al Home
        Get.offAll(() => const Homeprincipal());
      } else {
        Get.offAll(() => const LoginPage());
      }
    } catch (e) {
      print('Error verificando sesión en Splash: $e');
      Get.offAll(() => const LoginPage());
    }
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

  void setUser (Map item) {
    user.value = item;
  }

  void clearUser (){
    user.value.clear();
  }

  void setIndicator (Map item) {
    indicator.value = item;
  }

  void setIndicatorsWishes (List item) {
    indicatorsWishes.value = item;
  }

  void setBolsillos(List list) {
    bolsillos.value = list;
  }

  double get totalBalance {
    double total = 0.0;
    for (var b in bolsillos) {
      double bal = double.tryParse(b['balance']?.toString() ?? '0') ?? 0.0;
      total += bal;
    }
    return total;
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

  void setMovimientos(List list) {
    movimientos.value = list;
  }

  void setDeudas (List list) {
    deudas.value = list;
  }

  void setMetas (List list) {
    metas.value = list;
  }

  void setRecurrentes (List list) {
    recurrentes.value = list;
  }

  List get Indicators => indicators.value;
  List get Logros => logros.value;
  List get LogrosWeeks => logrosWeeks.value;
  Map get User => user.value;
  Map get Indicator => indicator.value;
  Map get Pages => pages.value;
  String get Page => page.value;
  List get IndicatorsWishes => indicatorsWishes.value;

  @override
  void onInit() async {
    // TODO: implement onInit
    super.onInit();
    await setSplash();
    setPage("home");
  }
}