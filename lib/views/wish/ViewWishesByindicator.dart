import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:indicator/Global.dart';
import 'package:indicator/main.dart';
import 'package:indicator/models/wishApi.dart';
import 'package:indicator/views/indicator/newLogro.dart';
import 'package:indicator/views/wish/newWish.dart';

class Viewwishesbyindicator extends StatefulWidget {
  const Viewwishesbyindicator({super.key});

  @override
  State<Viewwishesbyindicator> createState() => _ViewwishesbyindicatorState();
}

class _ViewwishesbyindicatorState extends State<Viewwishesbyindicator> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lista de deseos de ${controller.Indicator["indicator"]["nombre"]}"),
        foregroundColor: Global.action,
        actions: [
          IconButton(
            onPressed: (){
              newWish(controller.Indicator["indicator"]["id"]);
            },
            icon: Icon(Icons.add_circle)
          ),
          SizedBox(width: 10,)
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Obx(() => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Validamos de forma segura que la data y la lista de deseos existan
              if (controller.Indicator != null && controller.Indicator['wishes'] != null)
                ...(controller.Indicator['wishes'] as List).map<Widget>((wish) {

                  // Extraemos los campos del deseo de manera segura
                  final String nombreDeseo = wish['nombre'] ?? 'Deseo sin nombre';
                  final int idDeseo = wish['id'] ?? 0;

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                    color: Global.card,
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                        child: Icon(
                          CupertinoIcons.circle, // Un ícono circular estilo checkbox para tus deseos
                          color: Global.action,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        nombreDeseo,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Global.text
                        ),
                      ),
                      trailing: Icon(
                        CupertinoIcons.chevron_right,
                        size: 16,
                        color: Global.text,
                      ),
                      onTap: () {
                        print("Diste click al deseo con ID: $idDeseo y nombre: $nombreDeseo");
                        // Aquí podrás añadir acciones futuras para interactuar con el deseo
                      },
                    ),
                  );
                }).toList()
              else
              // En caso de que no haya deseos o esté cargando
                Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text(
                      "No hay futuros deseos registrados para este indicador.",
                      style: TextStyle(color: Global.text, fontSize: 14),
                    ),
                  ),
                ),
            ],
          ))
        ),
      ),
    );
  }
}
