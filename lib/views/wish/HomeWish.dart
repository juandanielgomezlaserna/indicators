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
                const SizedBox(width: 10),
                Text(
                  "lista de deseos",
                  style: GoogleFonts.inter(fontSize: 30, fontWeight: FontWeight.w600, color: Global.title, letterSpacing: -1.5),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Obx escuchando los cambios en la lista reactiva
            Obx(() {
              final indicadores = controller.IndicatorsWishes;

              if (indicadores.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40.0),
                    child: Text("No hay indicadores disponibles", style: TextStyle(color: Colors.grey)),
                  ),
                );
              }

              // Separar los indicadores en dos grupos según total_deseos
              final conDeseos = indicadores.where((ind) => (ind['total_deseos'] ?? 0) > 0).toList();
              final sinDeseos = indicadores.where((ind) => (ind['total_deseos'] ?? 0) == 0).toList();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // SECCIÓN 1: Con Deseos
                  if (conDeseos.isNotEmpty) ...[
                    Text(
                      "Activos con Deseos",
                      style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: Global.title),
                    ),
                    const SizedBox(height: 12),
                    _construirGrid(conDeseos),
                    const SizedBox(height: 30),
                  ],

                  // SECCIÓN 2: Sin Deseos
                  if (sinDeseos.isNotEmpty) ...[
                    Text(
                      "Sin Deseos Registrados",
                      style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                    _construirGrid(sinDeseos, esInactivo: true),
                  ],
                ],
              );
            }),

            const SizedBox(height: 90),
          ],
        ),
      ),
    );
  }

  // Widget reutilizable para pintar las cuadrículas (Grids)
  Widget _construirGrid(List<dynamic> listaIndicadores, {bool esInactivo = false}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double screenWidth = constraints.maxWidth;
        int crossAxisCount = screenWidth > 600 ? 4 : 2;

        double spacing = 15.0;
        double totalSpacing = spacing * (crossAxisCount - 1);
        double itemWidth = (screenWidth - totalSpacing) / crossAxisCount;

        double fixedItemHeight = 160.0;
        double calculatedAspectRatio = itemWidth / fixedItemHeight;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: listaIndicadores.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: spacing,
            crossAxisSpacing: spacing,
            childAspectRatio: calculatedAspectRatio,
          ),
          itemBuilder: (context, index) {
            final indicator = listaIndicadores[index];

            final String nombre = indicator['nombre'] ?? 'Sin nombre';
            final int totalDeseos = indicator['total_deseos'] ?? 0;
            final String iconoStr = indicator['icono'] ?? '';

            // Busca el IconData directamente en el mapa Global.iconsIndicators
            // Si no lo encuentra, usa uno por defecto (ej. CupertinoIcons.flag_fill)
            final IconData iconoMostrado = Global.iconsIndicators[iconoStr] ?? CupertinoIcons.flag_fill;

            return Card(
              color: esInactivo ? Global.card.withOpacity(0.6) : Global.card,
              elevation: esInactivo ? 1 : 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
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
                        // Icono obtenido desde Global.iconsIndicators
                        Icon(
                          iconoMostrado,
                          color: esInactivo ? Colors.grey : Global.action,
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
                            color: esInactivo ? Colors.grey[400] : Global.text,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Conteo de deseos acumulados
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: esInactivo ? Colors.grey.withOpacity(0.2) : Global.action,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "$totalDeseos futuros",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: esInactivo ? Colors.grey : Colors.black,
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
        );
      },
    );
  }
}