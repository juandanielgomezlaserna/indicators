import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:indicator/Global.dart';

class Wapp{
  static InputDecoration globalInput({required String hint, required String label, IconData? icon}) {
    return InputDecoration(
      // Textos y placeholders
      labelText: label,
      hintText: hint,
      labelStyle: GoogleFonts.inter(color: Global.text, fontWeight: FontWeight.w500),
      hintStyle: GoogleFonts.inter(color: Global.sutil.withOpacity(0.5)),

      // Icono (Opcional, ágil para formularios)
      prefixIcon: icon != null ? Icon(icon, color: Global.action) : null,

      // Fondo del Input
      filled: true,
      fillColor: Global.card,

      // Espaciado interno compacto y limpio para evitar desbordamientos en emuladores
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),

      // Bordes: Optimizados y listos
      border: _buildBorder(Global.sutil),
      enabledBorder: _buildBorder(Global.sutil),
      focusedBorder: _buildBorder(Global.action, width: 2.0), // Resalta al enfocar
      errorBorder: _buildBorder(Colors.redAccent),
      focusedErrorBorder: _buildBorder(Colors.redAccent, width: 2.0),
    );
  }

  // 2. Función privada para no repetir código de bordes (DRY - Don't Repeat Yourself)
  static OutlineInputBorder _buildBorder(Color color, {double width = 1.0}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12), // Mismo radio que tu tarjeta
      borderSide: BorderSide(color: color, width: width),
    );
  }
}