import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:indicator/Global.dart';
import 'package:indicator/main.dart';
import 'package:indicator/views/HomeIndicator.dart';

class Selectuser extends StatelessWidget {
  const Selectuser({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Global.bg,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "¿Quién eres?",
              style: TextStyle(color: Global.text, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),

            // Botón para Jota
            _buildUserButton(context, "Jota", () {
              // TODO: Lógica para Jota
              controller.setUser("Jota");
              Get.to(() => Homeindicator());
            }),

            const SizedBox(height: 20),

            // Botón para Da
            _buildUserButton(context, "Da", () {
              // TODO: Lógica para Da
              controller.setUser("Da");
              Get.to(() => Homeindicator());
            }),
          ],
        ),
      ),
    );
  }

  // Widget auxiliar para mantener el código limpio
  Widget _buildUserButton(BuildContext context, String name, VoidCallback onTap) {
    return SizedBox(
      width: 200,
      height: 60,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Global.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        onPressed: onTap,
        child: Text(
          name,
          style: TextStyle(color: Global.text, fontSize: 18),
        ),
      ),
    );
  }
}