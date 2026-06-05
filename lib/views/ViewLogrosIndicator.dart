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
    return Obx(() => Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          controller.Indicator["nombre"] ?? "Indicador",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
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
                color: Global.card,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
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
                            color: Colors.grey[600],
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
                              color: Global.action,
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
                        "${(double.parse(controller.Indicator["valor"])).toInt()}%",
                        style: GoogleFonts.poppins(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Global.text
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // --- LA BARRA DE PROGRESO ---
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: double.parse(controller.Indicator["valor"]) / 100,
                      minHeight: 10,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(Global.action),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "${controller.Indicator["logros"].where((l) => l["completado"] == true).length} de ${controller.Indicator["logros"].length} logros completados",
                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[500]),
                  )
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
            const SizedBox(height: 12),

            // Si el array de logros viene vacío de la base de datos
            controller.Indicator["logros"].length == 0
                ? Center(
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: Text(
                  "Aún no tienes logros registrados en este indicador.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(color: Colors.grey[500]),
                ),
              ),
            )
                : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.Indicator["logros"].length,
              itemBuilder: (context, index) {
                final logro = (controller.Indicator["logros"] ?? [])[index];
                final bool esCompletado = controller.Indicator["logros"][index]["completado"] ?? false;

                return InkWell(
                  onTap: () async {
                    updateCheckLogro(logro["id"]);
                    await getIndicatorById(controller.Indicator["id"]);
                  },
                  borderRadius: BorderRadius.circular(15),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Global.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: esCompletado
                              ? Global.action.withOpacity(0.2)
                              : Global.text.withOpacity(0.4),
                          width: 1
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      leading: CircleAvatar(
                        backgroundColor: esCompletado
                            ? Global.action.withOpacity(0.1)
                            : Colors.grey[500],
                        child: Icon(
                          esCompletado ? CupertinoIcons.check_mark_circled_solid : CupertinoIcons.circle,
                          color: esCompletado ? Global.action : Colors.grey[400],
                        ),
                      ),
                      title: Text(
                        logro["nombre"] ?? "Logro sin nombre",
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          decoration: esCompletado ? TextDecoration.lineThrough : null,
                          color: esCompletado ? Colors.grey[500] : Global.text,
                        ),
                      ),
                      subtitle: Text(
                        "Puntos: ${logro["puntos"] ?? 0}",
                        style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[500]),
                      ),
                      trailing: const Icon(CupertinoIcons.chevron_right, size: 16, color: Colors.grey),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    ));
  }
}