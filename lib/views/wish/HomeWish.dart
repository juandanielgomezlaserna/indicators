import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:indicator/Global.dart';
import 'package:indicator/main.dart';
import 'package:indicator/models/wishApi.dart';
import 'package:indicator/views/wish/ViewWishesByindicator.dart';

class Homewish extends StatefulWidget {
  const Homewish({super.key});

  @override
  State<Homewish> createState() => _HomewishState();
}

class _HomewishState extends State<Homewish> {
  @override
  void initState() {
    super.initState();
    // Consigue los indicadores actualizados al entrar a la pantalla
    getIndicatorsWishes();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(top: 50, left: 50, right: 50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SizedBox(width: 10,),
                Text(
                  "lista de deseos",
                  style: GoogleFonts.inter(fontSize: 30, fontWeight: FontWeight.w600, color: Global.title, letterSpacing: -1.5),
                ),
              ],
            ),
            SizedBox(height: 10,),
            LayoutBuilder(
              builder: (context, constraints) {
                // Calculamos el ancho disponible de la pantalla o contenedor
                double screenWidth = constraints.maxWidth;
                int crossAxisCount = screenWidth > 600 ? 4 : 2; // 4 columnas en tablet/escritorio, 2 en celular

                // Ancho individual de cada tarjeta restando los espacios (spacing)
                double spacing = 15.0;
                double totalSpacing = spacing * (crossAxisCount - 1);
                double itemWidth = (screenWidth - totalSpacing) / crossAxisCount;

                // Altura fija exacta en píxeles para cada tarjeta de deseos (160 píxeles como tenías)
                double fixedItemHeight = 160.0;
                double calculatedAspectRatio = itemWidth / fixedItemHeight;

                return Obx(() => GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.IndicatorsWishes.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,       // Columnas inteligentes según el ancho
                    mainAxisSpacing: spacing,             // Espacio vertical entre filas
                    crossAxisSpacing: spacing,            // Espacio horizontal entre columnas
                    childAspectRatio: calculatedAspectRatio, // Mantiene la altura fija de forma perfecta
                  ),
                  itemBuilder: (context, index) {
                    final indicator = controller.IndicatorsWishes[index];

                    // Extraemos las variables del mapa JSON de forma segura
                    final String nombre = indicator['nombre'] ?? 'Sin nombre';
                    final int totalDeseos = indicator['total_deseos'] ?? 0;
                    final String tipo = indicator['tipo'] ?? '';

                    return Card(
                      color: Global.card,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      // ClipRRect asegura que el efecto visual del click (splash) respete los bordes redondeados
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          onTap: () async {
                            await getWishesByIndicator(indicator["id"]);
                            Get.to(() => Viewwishesbyindicator());
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Icono dinámico o visual según el tipo de indicador
                                Icon(
                                  tipo == 'porcentaje' ? CupertinoIcons.percent : CupertinoIcons.star_fill,
                                  color: Global.action,
                                  size: 28,
                                ),
                                const SizedBox(height: 10),
                                // Nombre del indicador
                                Text(
                                  nombre,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                    color: Global.text,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                // Conteo de deseos acumulados (desde tu query SQL COUNT)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Global.action,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    "$totalDeseos futuros",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ));
              },
            ),
            SizedBox(height: 90,),
          ],
        ),
      ),
    );
  }
}