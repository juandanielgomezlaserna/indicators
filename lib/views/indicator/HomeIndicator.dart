import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:indicator/Global.dart';
import 'package:indicator/main.dart';
import 'package:indicator/models/indicatorsApi.dart';
import 'package:indicator/models/logrosApi.dart';
import 'package:indicator/views/indicator/ViewLogrosIndicator.dart';
import 'package:indicator/views/indicator/newIndicador.dart';
import 'package:indicator/views/indicator/newLogro.dart';
import 'package:indicator/views/indicator/viewLogrosWeeks.dart';

class Homeindicator extends StatefulWidget {
  const Homeindicator({super.key});

  @override
  State<Homeindicator> createState() => _HomeindicatorState();
}

class _HomeindicatorState extends State<Homeindicator> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getIndicators();
    getLogrosPendientes();
  }
  @override
  Widget build(BuildContext context) {
    return Obx(() => Padding(
      padding: EdgeInsets.all(50),
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(), // Esto fuerza a que responda siempre al borde
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SizedBox(width: 10,),
                Text(
                  "indicadores",
                  style: GoogleFonts.inter(fontSize: 30, fontWeight: FontWeight.w600, color: Global.title, letterSpacing: -1.5),
                ),
              ],
            ),
            SizedBox(height: 10,),
            LayoutBuilder(
              builder: (context, constraints) {
                // Definimos un ancho ideal para que calcule cuántas columnas poner de forma fluida
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(), // Si ya está dentro de un SingleChildScrollView
                  itemCount: 1 + controller.Indicators.length, // El botón de "+" + la lista de indicadores
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 300, // Ancho máximo aproximado antes de crear una nueva columna
                    mainAxisSpacing: 12,     // Espacio vertical entre tarjetas
                    crossAxisSpacing: 12,    // Espacio horizontal entre tarjetas
                    childAspectRatio: 1.5,   // Mantiene las tarjetas cuadradas (ancho / alto igual)
                  ),
                  itemBuilder: (context, index) {
                    // PRIMER ELEMENTO: El botón de agregar "+"
                    if (index == 0) {
                      return SizedBox(
                        height: 160,
                        child: Card(
                          color: Global.card,
                          elevation: 4,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                InkWell(
                                  borderRadius: BorderRadius.circular(15),
                                  onTap: () {
                                    newIndicador();
                                  },
                                  child: Icon(Icons.add_circle, color: Global.action, size: 50),
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    }

                    // RESTO DE ELEMENTOS: Las tarjetas de indicadores
                    final indicator = controller.Indicators[index - 1];
                    final double rawValue = double.tryParse(indicator['valor']?.toString() ?? '0') ?? 0.0;
                    final double progressValue = (rawValue / 100).clamp(0.0, 1.0);

                    return InkWell(
                      borderRadius: BorderRadius.circular(15),
                      onTap: () async {
                        await getIndicatorById(indicator["id"]);
                        print(controller.Indicator);
                        Get.to(() => Viewlogrosindicator());
                      },
                      child: SizedBox(
                        height: 100,
                        child: Card(
                          color: Global.card,
                          elevation: 4,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    InkWell(
                                      borderRadius: BorderRadius.circular(15),
                                      onTap: () {
                                        newLogro(indicator["id"]);
                                      },
                                      child: Icon(Icons.add_circle, color: Global.action),
                                    )
                                  ],
                                ),
                                Expanded(
                                  child: Align(
                                    alignment: AlignmentGeometry.centerLeft,
                                    child: Text(
                                      indicator['nombre'] ?? 'Sin Nombre',
                                      style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: Global.text),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${rawValue.toInt()}%',
                                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Global.action),
                                    ),
                                    const SizedBox(height: 4),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: progressValue,
                                        backgroundColor: Global.bg,
                                        valueColor: AlwaysStoppedAnimation<Color>(Global.action),
                                        minHeight: 8,
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            SizedBox(height: 10,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Logros", style: GoogleFonts.poppins(color: Global.text, fontSize: 18),),
                InkWell(
                  onTap: () async {
                    final logrosWeeks = await getLogrosSemanas();
                    controller.setLogrosWeeks(logrosWeeks);
                    viewLogrosWeeks(context);
                  },
                  borderRadius: BorderRadius.circular(15),
                  child: Icon(Icons.navigate_next, color: Global.text,),
                )
              ],
            ),
            SizedBox(height: 10,),
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
                    subtitle: Text("${logro["nombre_indicador"]}", style: TextStyle(color: Global.text.withOpacity(0.8)),),
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
            ),
            SizedBox(height: 40,)
          ],
        ),
      ),
    ));
  }
}
