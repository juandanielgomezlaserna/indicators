import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:indicator/Global.dart';
import 'package:indicator/main.dart';
import 'package:indicator/models/indicatorsApi.dart';
import 'package:indicator/models/logrosApi.dart';
import 'package:indicator/views/newIndicador.dart';
import 'package:indicator/views/newLogro.dart';

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
  }
  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
      appBar: AppBar(
        title: Text("Indicadores de vida", style: GoogleFonts.poppins(),),
        foregroundColor: Global.action,
        leading: Icon(Icons.favorite),
        actions: [
          InkWell(
            borderRadius: BorderRadius.circular(15),
            onTap: () async {
              await getIndicators();
              await getLogrosPendientes();
            },
            child: Icon(CupertinoIcons.refresh),
          ),
          SizedBox(width: 10,),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              children: [
                SizedBox(
                width: 160,
                  height: 160,
                  child: Card(
                    color: Global.card, // Aplicamos el fondo oscuro de la tarjeta
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center, // Distribuye el espacio eficientemente
                        children: [
                          InkWell(
                            borderRadius: BorderRadius.circular(15),
                            onTap: (){
                              newIndicador();
                            },
                            child: Icon(Icons.add_circle, color: Global.action, size: 50,),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                ...
                controller.Indicators.map<Widget>((indicator) {
                  final double rawValue = double.tryParse(indicator['valor']?.toString() ?? '0') ?? 0.0;
                  final double progressValue = (rawValue / 100).clamp(0.0, 1.0);
                  return SizedBox(
                    width: 160,
                    height: 160,
                    child: Card(
                      color: Global.card, // Aplicamos el fondo oscuro de la tarjeta
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween, // Distribuye el espacio eficientemente
                          children: [
                            // Tipo de indicador (Etiqueta superior pequeña)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  (indicator['tipo'] ?? 'General').toString().toUpperCase(),
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Global.sutil), // Color sutil para la categoría
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                InkWell(
                                  borderRadius: BorderRadius.circular(15),
                                  onTap: (){
                                    newLogro(indicator["id"]);
                                  },
                                  child: Icon(Icons.add_circle, color: Global.action,),
                                )
                              ],
                            ),

                            // Nombre del indicador (Cuerpo central)
                            Expanded(
                              child: Center(
                                child: Text(
                                  indicator['nombre'] ?? 'Sin Nombre',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Global.text), // Texto principal claro
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),

                            // Sección de progreso y valor numérico
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${rawValue.toInt()}%',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Global.action), // Color de acción para el valor
                                ),
                                const SizedBox(height: 4),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: progressValue,
                                    backgroundColor: Global.bg, // Fondo de la barra usando el background global
                                    valueColor: AlwaysStoppedAnimation<Color>(Global.action), // Color de progreso llamativo
                                    minHeight: 8, // Más visible en el emulador
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ]
            ),
            SizedBox(height: 10,),
            Text("Logros", style: GoogleFonts.poppins(color: Global.text, fontSize: 18),),
            SizedBox(height: 10,),
            ListView.builder(
              shrinkWrap: true, // ⚡ Mínimo espacio posible
              physics: const ClampingScrollPhysics(),
              itemCount: controller.Logros.length,
              itemBuilder: (context, i) {
                final logro = controller.Logros[i];

                // ⚡ Condicional de estado: ¿Está completado?
                bool completado = logro["completado"] ?? false;

                return Card(
                  color: Global.card,
                  child: ListTile(
                    title: Text(
                      logro["nombre"],
                      style: TextStyle(
                        // ⚡ La magia del tachado
                        decoration: completado
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        // Opcional: darle un tono gris si está tachado para mejor UX
                        color: Global.text,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    trailing: Checkbox(
                      value: completado,
                      onChanged: (value) async {
                        // ⚡ Lógica reactiva: actualiza tu controller aquí
                        controller.toggleLogro(logro["id"]);
                      },
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
