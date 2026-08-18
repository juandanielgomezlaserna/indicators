import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:indicator/Global.dart';
import 'package:indicator/main.dart';
import 'package:indicator/models/indicatorsApi.dart';
import 'package:indicator/models/logrosApi.dart';
import 'package:indicator/views/indicator/ViewLogrosIndicator.dart';
import 'package:indicator/views/indicator/editIndicator.dart';
import 'package:indicator/views/indicator/editLogro.dart';
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
    return Obx(() => SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(left: 50, right: 50, top: 50),
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
                // Calculamos el ancho disponible para que quepan exactamente 2 columnas con espacio limpio
                double screenWidth = constraints.maxWidth;
                int crossAxisCount = screenWidth > 600 ? 4 : 2; // 3 columnas si es tablet/pantalla ancha, 2 en celular
        
                // Ancho individual de cada tarjeta restando los espacios (spacing)
                double spacing = 14.0;
                double totalSpacing = spacing * (crossAxisCount - 1);
                double itemWidth = (screenWidth - totalSpacing) / crossAxisCount;
        
                // AQUÍ DEFINES TU ALTURA FIJA EXACTA EN PÍXELES (ej. 175 píxeles)
                double fixedItemHeight = 175.0;
                double calculatedAspectRatio = itemWidth / fixedItemHeight;
        
                return Obx(() =>  GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 1 + controller.Indicators.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,       // Columnas fijas inteligentes (2 en móvil, 3 en web/tablet)
                    mainAxisSpacing: spacing,             // Espacio vertical
                    crossAxisSpacing: spacing,            // Espacio horizontal
                    childAspectRatio: calculatedAspectRatio, // Mantiene la altura fija calculada de forma perfecta
                  ),
                  itemBuilder: (context, index) {
                    // PRIMER ELEMENTO: El botón de agregar "+"
                    if (index == 0) {
                      return Card(
                        color: Global.card,
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                              ),
                            ],
                          ),
                        ),
                      );
                    }
        
                    // RESTO DE ELEMENTOS: Las tarjetas de indicadores
                    final indicator = controller.Indicators[index - 1];
                    final double rawValue = double.tryParse(indicator['valor']?.toString() ?? '0') ?? 0.0;
                    final double progressValue = (rawValue / 100).clamp(0.0, 1.0);
        
                    return InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () async {
                        await getIndicatorById(indicator["id"]);
                        print(controller.Indicator);
                        Get.to(() => Viewlogrosindicator());
                      },
                      child: Card(
                        color: Global.card,
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(14.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  InkWell(
                                    borderRadius: BorderRadius.circular(15),
                                    onTap: () {
                                      editIndicador(indicator);
                                    },
                                    child: Icon(Icons.edit, color: Global.action, size: 22),
                                  ),
                                  InkWell(
                                    borderRadius: BorderRadius.circular(15),
                                    onTap: () {
                                      newLogro(indicator["id"]);
                                    },
                                    child: Icon(Icons.add_circle, color: Global.action, size: 22),
                                  ),
                                ],
                              ),
                              Expanded(
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    indicator['nombre'] ?? 'Sin Nombre',
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Global.text,
                                      height: 1.2,
                                    ),
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
                                      minHeight: 7,
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ));
              },
            ),
            SizedBox(height: 10,),
            Align(
              alignment: AlignmentGeometry.centerLeft,
              child: SizedBox(
                width: 130,
                height: 41,
                child: ElevatedButton(
                  onPressed: () async {
                    final logrosWeeks = await getLogrosSemanas();
                    controller.setLogrosWeeks(logrosWeeks);
                    viewLogrosWeeks(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Global.action,
                    foregroundColor: Colors.black87,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "logros >",
                        style: GoogleFonts.poppins(
                          fontSize: 25,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w600,
                          color: Global.bg,
                          letterSpacing: -1,
                          height: 1.0,
                        ),
                      ),
                      // Icon(
                      //   Icons.chevron_right,
                      //   size: 25,
                      //   color: Color(0xFF1E2229),
                      // ),
                    ],
                  ),
                ),
              ),
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
                    onTap: (){
                      editLogro(logro);
                    },
                    title: Text(
                      "${logro["nombre"]} (${logro["puntos"]}%)",
                      style: TextStyle(
                        decoration: completado
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        decorationColor: Global.text,
                        color: Global.text,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text("${logro["nombre_indicador"]}", style: TextStyle(color: Global.text.withOpacity(0.8)),),
                    trailing: Checkbox(
                      value: completado,
                      checkColor: Global.bg,
                      focusColor: Global.action,
                      activeColor: Global.action,
                      onChanged: (value) async {
                        controller.toggleLogro(logro["id"]);
                      },
                      side: BorderSide(color: Global.sutil, width: 2.0),
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 90,)
          ],
        ),
      ),
    ));
  }
}
