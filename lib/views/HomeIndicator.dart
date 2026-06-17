import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:indicator/Global.dart';
import 'package:indicator/main.dart';
import 'package:indicator/models/indicatorsApi.dart';
import 'package:indicator/models/logrosApi.dart';
import 'package:indicator/views/ViewLogrosIndicator.dart';
import 'package:indicator/views/newIndicador.dart';
import 'package:indicator/views/newLogro.dart';
import 'package:indicator/views/viewLogrosWeeks.dart';

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
    return Obx(() => Scaffold(
      appBar: AppBar(
        title: Text("Indicadores de vida V1.3", style: GoogleFonts.poppins(),),
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                children: [
                  SizedBox(
                  width: 160,
                    height: 160,
                    child: Card(
                      color: Global.card,
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
                    return InkWell(
                      borderRadius: BorderRadius.circular(15),
                      onTap: () async {
                        await getIndicatorById(indicator["id"]);
                        print(controller.Indicator);
                        Get.to(() => Viewlogrosindicator());
                      },
                      child: SizedBox(
                        width: 160,
                        height: 160,
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
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      (indicator['tipo'] ?? 'General').toString().toUpperCase(),
                                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Global.sutil),
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
                  }).toList(),
                ]
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
              )
            ],
          ),
        ),
      ),
    ));
  }
}
