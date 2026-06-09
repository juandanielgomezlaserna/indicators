import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:indicator/Global.dart';
import 'package:indicator/main.dart';
import 'package:indicator/models/indicatorsApi.dart';
import 'package:indicator/models/logrosApi.dart';

class Viewlogrosindicator extends StatefulWidget {
  const Viewlogrosindicator({super.key});

  @override
  State<Viewlogrosindicator> createState() => _ViewlogrosindicatorState();
}

class _ViewlogrosindicatorState extends State<Viewlogrosindicator> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Extraemos las semanas de forma segura
      final List<dynamic> semanas = controller.Indicator["semanas"] ?? [];
      final int indicadorId = controller.Indicator["id"] ?? 0;

      return Scaffold(
        backgroundColor: Global.bg, // 🎨 Fondo Obscuro Cyberpunk
        appBar: AppBar(
          backgroundColor: Global.bg,
          elevation: 0,
          title: Text(
            controller.Indicator["nombre"] ?? "Indicador",
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Global.text
            ),
          ),
          foregroundColor: Global.action,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // --- TARJETA DEL INDICADOR ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Global.card, // 🎨 Tarjeta Gris Azulado
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: Global.sutil.withOpacity(0.2),
                      width: 1
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Progreso General",
                          style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Global.text.withOpacity(0.6), // Texto secundario
                              fontWeight: FontWeight.w500
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Global.action.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            controller.Indicator["tipo"] ?? "General",
                            style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Global.action, // 🎨 Cyan Neón
                                fontWeight: FontWeight.w600
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      textBaseline: TextBaseline.alphabetic,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      children: [
                        Text(
                          "${double.parse(controller.Indicator["valor"].toString()).toInt()}%",
                          style: GoogleFonts.poppins(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Global.text // 🎨 Texto Principal
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // --- LA BARRA DE PROGRESO ---
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: double.parse(controller.Indicator["valor"].toString()) / 100,
                        minHeight: 10,
                        backgroundColor: Global.bg, // El fondo de la barra se mezcla con la app
                        valueColor: AlwaysStoppedAnimation<Color>(Global.action), // 🎨 Relleno Neón
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // --- SECCIÓN DE LOGROS ---
              Text(
                "Historial de Logros",
                style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Global.text
                ),
              ),
              const SizedBox(height: 16),

              // Si no hay semanas o logros en absoluto
              semanas.isEmpty
                  ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Text(
                    "Aún no tienes logros registrados en este indicador.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(color: Global.text.withOpacity(0.5)),
                  ),
                ),
              )
                  : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: semanas.length,
                itemBuilder: (context, i) {
                  final semana = semanas[i];
                  final List<dynamic> logros = semana["logros"] ?? [];

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // TITULO DE LA SEMANA
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              semana["rango_fecha"] ?? "Semana",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Global.sutil, // 🎨 Turquesa Sutil para separar semanas
                              ),
                            ),
                            Text(
                              semana["progreso_resumen"] ?? "0 de 0",
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Global.action,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // LISTA DE LOGROS DE ESTA SEMANA
                      logros.isEmpty
                          ? Padding(
                        padding: const EdgeInsets.only(bottom: 20, left: 4),
                        child: Text(
                          "Sin logros esta semana.",
                          style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Global.text.withOpacity(0.4)
                          ),
                        ),
                      )
                          : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: logros.length,
                        itemBuilder: (context, index) {
                          final logro = logros[index];
                          final bool esCompletado = logro["completado"] ?? false;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Global.card, // 🎨 Tarjeta interna
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: esCompletado
                                      ? Global.action.withOpacity(0.4) // Borde neón si está listo
                                      : Global.sutil.withOpacity(0.15), // Borde discreto si no
                                  width: 1
                              ),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              leading: InkWell(
                                onTap: () async {
                                  updateCheckLogro(logro["id"]);
                                  await getIndicatorById(indicadorId);
                                },
                                child: CircleAvatar(
                                  backgroundColor: esCompletado
                                      ? Global.action.withOpacity(0.1)
                                      : Global.bg, // Círculo obscuro si está incompleto
                                  child: Icon(
                                    esCompletado ? CupertinoIcons.check_mark_circled_solid : CupertinoIcons.circle,
                                    color: esCompletado ? Global.action : Global.text.withOpacity(0.3),
                                  ),
                                ),
                              ),
                              title: Text(
                                logro["nombre"] ?? "Logro sin nombre",
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  decoration: esCompletado ? TextDecoration.lineThrough : null,
                                  color: esCompletado
                                      ? Global.text.withOpacity(0.4)
                                      : Global.text,
                                ),
                              ),
                              subtitle: Text(
                                "Puntos: ${logro["puntos"] ?? 0}",
                                style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Global.text.withOpacity(0.5)
                                ),
                              ),
                              trailing: Icon(
                                  CupertinoIcons.chevron_right,
                                  size: 16,
                                  color: Global.text.withOpacity(0.3)
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      );
    });
  }
}