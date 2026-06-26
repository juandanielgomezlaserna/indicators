import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:indicator/Global.dart';
import 'package:indicator/main.dart';
import 'package:indicator/models/logrosApi.dart';

void viewLogrosWeeks(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        backgroundColor: Global.bg, // 🎨 Fondo oscuro
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.all(20), // Margen exterior del diálogo
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Global.bg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Global.sutil.withOpacity(0.2), width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- CABECERA DEL DIÁLOGO ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Historial Global",
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Global.text,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(CupertinoIcons.xmark_circle_fill, color: Global.text.withOpacity(0.5)),
                  )
                ],
              ),
              const SizedBox(height: 16),

              // --- CONTENIDO REACTIVO CON OBX ---
              Expanded(
                child: Obx(() {
                  final List<dynamic> semanas = controller.LogrosWeeks ?? [];

                  if (semanas.isEmpty) {
                    return Center(
                      child: Text(
                        "No hay registros de logros todavía.",
                        style: GoogleFonts.poppins(color: Global.text.withOpacity(0.5)),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: semanas.length,
                    itemBuilder: (context, i) {
                      final semana = semanas[i];
                      final List<dynamic> logros = semana["logros"] ?? [];

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Cabecera de la semana ("Del 1 al 7 de agosto" | "7 de 10")
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
                                    color: Global.sutil, // Turquesa sutil
                                  ),
                                ),
                                Text(
                                  semana["progreso_resumen"] ?? "0 de 0",
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Global.action, // Cyan Neón
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Listado de logros dentro de esta semana
                          logros.isEmpty
                              ? Padding(
                            padding: const EdgeInsets.only(bottom: 16, left: 4),
                            child: Text(
                              "Sin logros registrados.",
                              style: GoogleFonts.poppins(fontSize: 12, color: Global.text.withOpacity(0.4)),
                            ),
                          )
                              : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(), // Evita conflictos con el scroll padre
                            itemCount: logros.length,
                            itemBuilder: (context, index) {
                              final logro = logros[index];
                              final bool esCompletado = logro["completado"] ?? false;
                              final String nombreIndicador = logro["indicador"]?["nombre"] ?? "Indicador";

                              return Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                decoration: BoxDecoration(
                                  color: Global.card, // Tarjeta gris azulado
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: esCompletado
                                        ? Global.action.withOpacity(0.4)
                                        : Global.sutil.withOpacity(0.15),
                                    width: 1,
                                  ),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                                  leading: InkWell(
                                    onTap: () async {
                                      // Cambia el estado del check en la BD
                                      await updateCheckLogro(logro["id"]);
                                      // Refresca el endpoint global para que Obx redibuje el diálogo solo
                                      final logrosWeeks = await getLogrosSemanas();
                                      controller.setLogrosWeeks(logrosWeeks);
                                    },
                                    child: CircleAvatar(
                                      backgroundColor: esCompletado
                                          ? Global.action.withOpacity(0.1)
                                          : Global.bg,
                                      child: Icon(
                                        esCompletado
                                            ? CupertinoIcons.check_mark_circled_solid
                                            : CupertinoIcons.circle,
                                        color: esCompletado ? Global.action : Global.text.withOpacity(0.3),
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    logro["nombre"] ?? "Logro sin nombre",
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      decoration: esCompletado ? TextDecoration.lineThrough : null,
                                      color: esCompletado ? Global.text.withOpacity(0.4) : Global.text,
                                    ),
                                  ),
                                  // 💡 Pintamos los puntos y a qué indicador pertenece en el subtítulo
                                  subtitle: Text(
                                    "Puntos: ${logro["puntos"] ?? 0} • $nombreIndicador",
                                    style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        color: Global.text.withOpacity(0.5)
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 10),
                        ],
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      );
    },
  );
}