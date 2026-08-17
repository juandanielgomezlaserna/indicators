import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:indicator/Global.dart';
import 'package:indicator/main.dart';
import 'package:indicator/models/indicatorsApi.dart';
import 'package:indicator/models/logrosApi.dart';

class Homeprincipal extends StatefulWidget {
  const Homeprincipal({super.key});

  @override
  State<Homeprincipal> createState() => _HomeprincipalState();
}

class _HomeprincipalState extends State<Homeprincipal> {
  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
      // appBar: AppBar(
      //   title: Text("Indicadores de vida V3.0", style: GoogleFonts.poppins()),
      //   foregroundColor: Global.action,
      //   leading: const Icon(Icons.favorite),
      //   actions: [
      //     InkWell(
      //       borderRadius: BorderRadius.circular(15),
      //       onTap: () async {
      //         if(controller.Page == "indicator"){
      //           await getIndicators();
      //           await getLogrosPendientes();
      //         }
      //       },
      //       child: const Icon(CupertinoIcons.refresh),
      //     ),
      //     const SizedBox(width: 10),
      //   ],
      // ),
      // Usamos un Stack para colocar el contenido detrás y la barra flotante encima de forma elegante
      body: Stack(
        children: [
          // 1. Vista principal que cambia dinámicamente según el controlador
          Positioned.fill(
            child: controller.Pages[controller.Page]!,
          ),

          // 2. Barra de navegación flotante estilo isla/píldora
          Positioned(
            left: 20,
            right: 20,
            bottom: 20, // Distancia flotante desde el borde inferior
            child: SafeArea(
              child: Container(
                height: 70,
                decoration: BoxDecoration(
                  color: Global.menu,
                  borderRadius: BorderRadius.circular(35), // Esquinas totalmente redondeadas
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.18), // Sombra sutil para dar el efecto flotante
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Botón 1: Indicador (Favorito)
                    IconButton(
                      onPressed: () {
                        controller.setPage("indicator");
                      },
                      icon: Icon(
                        controller.Page == "indicator" ?
                          Icons.bubble_chart
                          : Icons.bubble_chart_outlined, size: 30),
                    ),

                    // Botón 2: Deseos / Libro
                    IconButton(
                      onPressed: () {
                        controller.setPage("wish");
                      },
                      icon: Icon(
                          controller.Page == "wish" ?
                          CupertinoIcons.book_fill
                          : CupertinoIcons.book, size: 30),
                    ),

                    // Botón 3 (CENTRO): Logo personalizado en lugar de la casa
                    GestureDetector(
                      onTap: () {
                        controller.setPage("home");
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        child: Image.asset(
                          controller.Page == "home" ?
                          'lib/assets/logo.png'
                          : 'lib/assets/logo_outlined.png',
                          height: 36, // Tamaño controlado para que encaje perfecto en la barra
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                    // Botón 4: Finanzas / Cartera
                    IconButton(
                      onPressed: () {
                        controller.setPage("finance");
                      },
                      icon: Icon(
                          controller.Page == "finance" ?
                          Icons.account_balance_wallet
                          : Icons.account_balance_wallet_outlined, size: 30),
                    ),

                    // Botón 5: Perfil de Usuario
                    IconButton(
                      onPressed: () {
                        controller.setPage("user");
                      },
                      icon: Icon(
                          controller.Page == "user" ?
                          Icons.person
                          : Icons.person_outline, size: 30),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ));
  }
}