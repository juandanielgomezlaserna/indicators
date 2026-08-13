import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:indicator/Global.dart';
import 'package:indicator/main.dart';
import 'package:indicator/models/authService.dart';
// Asegúrate de importar tu controlador principal o de autenticación según corresponda
// import 'package:indicator/controllers/auth_controller.dart';

class Homeuser extends StatelessWidget {
  const Homeuser({super.key});

  @override
  Widget build(BuildContext context) {
    // Si manejas un controlador específico de usuario/auth, puedes instanciarlo así:
    // final authController = Get.find<AuthController>();

    return Obx(() {
      // Obtenemos los datos del usuario de forma segura desde el controlador global
      // (Asumiendo que controller.User es un RxMap o un objeto reactivo)
      final user = controller.User;

      final String nombreCompleto = user['nombre_completo'] ?? 'Usuario';
      final String username = user['usuario'] ?? 'username';
      final String email = user['email'] ?? 'correo@ejemplo.com';
      final String createdAt = user['created_at']?.toString().split('T')[0] ?? 'N/A';

      final AuthService _authService = AuthService();

      return Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              // Avatar o Icono de Perfil
              CircleAvatar(
                radius: 50,
                backgroundColor: Global.action.withOpacity(0.2),
                child: Icon(
                  Icons.person,
                  size: 60,
                  color: Global.action,
                ),
              ),
              const SizedBox(height: 16),

              // Nombre Completo
              Text(
                nombreCompleto,
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Global.text,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),

              // Username (@usuario)
              Text(
                '@$username',
                style: TextStyle(
                  fontSize: 14,
                  color: Global.sutil,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 30),

              // Tarjeta con información detallada
              Card(
                color: Global.card,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildInfoRow(Icons.email, 'Correo Electrónico', email),
                      const Divider(height: 24),
                      _buildInfoRow(Icons.calendar_today, 'Miembro desde', createdAt),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Botón de Cerrar Sesión
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await _authService.logout();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent.withOpacity(0.15),
                    foregroundColor: Colors.redAccent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.logout),
                  label: Text(
                    'Cerrar Sesión',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  // Widget auxiliar para construir las filas de información limpiamente
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Global.action, size: 22),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Global.sutil,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: Global.text,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}