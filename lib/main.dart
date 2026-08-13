import 'package:animate_do/animate_do.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:indicator/Global.dart';
import 'package:indicator/controllers/MyController.dart';
import 'package:indicator/models/authService.dart';
import 'package:indicator/views/HomePrincipal.dart';
import 'package:indicator/views/login/login.dart'; // O la ruta correcta de tu home principal

void main(){
  // Registramos el controlador globalmente al iniciar la app
  Get.put(MyController());

  runApp(
      GetMaterialApp(
        title: "Indicator",
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          textTheme: GoogleFonts.openSansTextTheme(),
        ),
        themeMode: ThemeMode.dark,
        darkTheme: ThemeData(
            scaffoldBackgroundColor: Global.bg,
            iconTheme: IconThemeData(color: Global.action),
            cardColor: Global.card,
            appBarTheme: AppBarTheme(backgroundColor: Global.bg, centerTitle: false,)
        ),
        // La home raíz siempre es el Splash, el cual evaluará la sesión
        home: const Splash(),
      )
  );
}

// Instancia global accesible desde los servicios o vistas si es necesario
MyController controller = Get.find();

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    // Usamos addPostFrameCallback para asegurar que el contexto y GetMaterialApp
    // estén completamente listos antes de ejecutar la lógica de navegación y red.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkSessionAndNavigate();
    });
  }

  Future<void> _checkSessionAndNavigate() async {
    // Mantiene el splash visible al menos 2 segundos por estética
    await Future.delayed(const Duration(seconds: 2));

    try {
      final authService = AuthService();

      // Valida el token con el servidor y carga el usuario en el UserController
      bool isAuthenticated = await authService.checkAuth();

      if (isAuthenticated) {
        // Redirige al Home Principal eliminando el Splash del historial
        Get.offAll(() => const Homeprincipal());
      } else {
        // Redirige al Login si no hay sesión válida
        Get.offAll(() => const LoginPage());
      }
    } catch (e) {
      print('Error verificando sesión en Splash: $e');
      Get.offAll(() => const LoginPage());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Center(
          child: FadeIn(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite, size: 60, color: Global.action),
                const SizedBox(height: 20),
                CircularProgressIndicator(color: Global.action),
              ],
            ),
          ),
        ),
      ),
    );
  }
}