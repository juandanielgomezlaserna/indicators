import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:indicator/Global.dart';
import 'package:indicator/main.dart';
import 'package:indicator/models/iaApi.dart';
import 'package:indicator/models/indicatorsApi.dart';
import 'package:indicator/models/logrosApi.dart';
import 'package:indicator/views/indicator/ViewLogrosIndicator.dart';
import 'package:indicator/views/indicator/newIndicador.dart';
import 'package:indicator/views/indicator/newLogro.dart';
import 'package:indicator/views/indicator/viewLogrosWeeks.dart';
// Importa tu archivo HTTP o servicio donde esté alojada la función de la IA
// import 'path/to/tu_archivo_api.dart';

class Homehome extends StatefulWidget {
  const Homehome({super.key});

  @override
  State<Homehome> createState() => _HomehomeState();
}

class _HomehomeState extends State<Homehome> {
  // Variables de estado para almacenar la tarjeta diaria de IA
  bool _isLoadingIa = true;
  Map<String, dynamic>? _tarjetaDiaria;

  @override
  void initState() {
    super.initState();
    getIndicators();
    getLogrosPendientes();
    _cargarTarjetaDiariaIa();
  }

  // Método para consumir la API de la tarjeta inteligente de IA
  Future<void> _cargarTarjetaDiariaIa() async {
    setState(() {
      _isLoadingIa = true;
    });

    // Llamada a la función HTTP que creamos previamente
    final resultado = await obtenerTarjetaDiariaIaApi();

    if (mounted) {
      setState(() {
        _tarjetaDiaria = resultado;
        _isLoadingIa = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Padding(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ==========================================
            // SECCIÓN: TARJETAS DIARIAS DE INTELIGENCIA ARTIFICIAL
            // ==========================================
            Text("Mentor Diario", style: GoogleFonts.poppins(color: Global.text, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            _isLoadingIa
                ? Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Global.card,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: CircularProgressIndicator(color: Global.action),
              ),
            )
                : Column(
              children: [
                // Tarjeta 1: Frase Motivacional
                Card(
                  color: Global.card,
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.auto_awesome, color: Global.action, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Inspiración del Día",
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Global.sutil),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _tarjetaDiaria?['frase_motivacional'] ?? 'El éxito es la suma de pequeños esfuerzos repetidos día tras día.',
                                style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: Global.text),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Tarjeta 2: Consejo de Crecimiento / Vida
                Card(
                  color: Global.card,
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.lightbulb_outline, color: Global.action, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Enfoque y Orden",
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Global.sutil),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _tarjetaDiaria?['consejo_financiero'] ?? 'Revisa tus prioridades de hoy y enfócate en avanzar en tu meta principal.',
                                style: TextStyle(fontSize: 14, color: Global.text),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ==========================================
            // SECCIÓN: LOGROS DE LA SEMANA
            // ==========================================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Logros", style: GoogleFonts.poppins(color: Global.text, fontSize: 18, fontWeight: FontWeight.bold)),
                InkWell(
                  onTap: () async {
                    final logrosWeeks = await getLogrosSemanas();
                    controller.setLogrosWeeks(logrosWeeks);
                    viewLogrosWeeks(context);
                  },
                  borderRadius: BorderRadius.circular(15),
                  child: Icon(Icons.navigate_next, color: Global.text),
                )
              ],
            ),
            const SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              itemCount: controller.Logros.length,
              itemBuilder: (context, i) {
                final logro = controller.Logros[i];
                bool completado = logro["completado"] ?? false;

                return Card(
                  color: Global.card,
                  child: ListTile(
                    title: Text(
                      "${logro["nombre"]} (${logro["puntos"]}pts)",
                      style: TextStyle(
                        decoration: completado
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        color: Global.text,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      "${logro["nombre_indicador"]}",
                      style: TextStyle(color: Global.text.withOpacity(0.8)),
                    ),
                    trailing: Checkbox(
                      value: completado,
                      checkColor: Global.action,
                      focusColor: Global.action,
                      onChanged: (value) async {
                        controller.toggleLogro(logro["id"]);
                      },
                      side: BorderSide(color: Global.sutil, width: 2.0),
                    ),
                  ),
                );
              },
            )
          ],
        ),
      ),
    ));
  }
}