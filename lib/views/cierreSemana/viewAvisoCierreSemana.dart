import 'package:flutter/material.dart';

class RitualCierreModal extends StatelessWidget {
  final VoidCallback onComenzar;
  final VoidCallback? onOmitir;

  const RitualCierreModal({
    super.key,
    required this.onComenzar,
    this.onOmitir,
  });

  /// Método estático para invocar el modal fácilmente desde cualquier pantalla
  static Future<void> mostrar(
      BuildContext context, {
        required VoidCallback onComenzar,
        VoidCallback? onOmitir,
      }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // Fuerza al usuario a presionar una opción
      builder: (BuildContext dialogContext) {
        return RitualCierreModal(
          onComenzar: () {
            Navigator.of(dialogContext).pop();
            onComenzar();
          },
          onOmitir: () {
            Navigator.of(dialogContext).pop();
            if (onOmitir != null) onOmitir();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1E1E1E), // Fondo oscuro minimalista
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      elevation: 10,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ícono decorativo con resplandor
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.deepPurple.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                size: 38,
                color: Colors.deepPurpleAccent,
              ),
            ),
            const SizedBox(height: 20),

            // Título
            const Text(
              "Ritual de Cierre Semanal",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),

            // Mensaje explicativo
            Text(
              "Llegó el momento de revisar tu balance financiero, evaluar tus logros de la semana y recibir tu diagnóstico de paz mental con Nyra.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 28),

            // Botones de Acción
            Row(
              children: [
                // Botón Omitir
                Expanded(
                  child: TextButton(
                    onPressed: onOmitir,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "Omitir",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Botón Comenzar
                Expanded(
                  child: ElevatedButton(
                    onPressed: onComenzar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurpleAccent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Comenzar",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}