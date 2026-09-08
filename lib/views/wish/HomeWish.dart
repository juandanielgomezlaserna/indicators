import 'dart:ui';
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
    getIndicatorsWishes();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(top: 50, left: 24, right: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "lista de deseos",
              style: GoogleFonts.inter(
                fontSize: 30,
                fontWeight: FontWeight.w600,
                color: Global.title,
                letterSpacing: -1.5,
              ),
            ),
            const SizedBox(height: 20),
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

              return LayoutBuilder(
                builder: (context, constraints) {
                  double screenWidth = constraints.maxWidth;
                  int crossAxisCount = screenWidth > 600 ? 4 : 2;

                  double spacing = 12.0;
                  double totalSpacing = spacing * (crossAxisCount - 1);
                  double itemWidth = (screenWidth - totalSpacing) / crossAxisCount;

                  // Altura ajustada para el nuevo diseño horizontal de la tarjeta
                  double fixedItemHeight = 84.0;
                  double calculatedAspectRatio = itemWidth / fixedItemHeight;

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: indicadores.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: spacing,
                      crossAxisSpacing: spacing,
                      childAspectRatio: calculatedAspectRatio,
                    ),
                    itemBuilder: (context, index) {
                      final indicator = indicadores[index];

                      final String nombre = indicator['nombre'] ?? 'Sin nombre';
                      final int totalDeseos = indicator['total_deseos'] ?? 0;
                      final String iconoStr = indicator['icono'] ?? '';
                      final IconData iconoMostrado = Global.iconsIndicators[iconoStr] ?? CupertinoIcons.flag_fill;
                      final bool tieneDeseos = totalDeseos > 0;

                      return InkWell(
                        onTap: () async {
                          await getWishesByIndicator(indicator["id"]);
                          Get.to(() => Viewwishesbyindicator());
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: CustomPaint(
                          // Pinta borde punteado si no tiene deseos, o tarjeta sólida si tiene
                          painter: tieneDeseos
                              ? null
                              : DashedCardPainter(color: Global.text.withOpacity(0.3), radius: 16),
                          child: Container(
                            decoration: BoxDecoration(
                              color: tieneDeseos ? Global.card : Colors.transparent,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Icono principal
                                Icon(
                                  iconoMostrado,
                                  color: Global.action,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                // Textos (Nombre y Subtítulo)
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        nombre,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.inter(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                          color: Global.text,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        tieneDeseos ? "$totalDeseos ideas guardadas" : "agregar ideas",
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.inter(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 11,
                                          color: Global.text.withOpacity(0.5),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 4),
                                // Flecha si tiene deseos o signo (+) si está vacío
                                Icon(
                                  tieneDeseos ? CupertinoIcons.chevron_right : Icons.add,
                                  color: Global.text.withOpacity(0.4),
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            }),
            const SizedBox(height: 90),
          ],
        ),
      ),
    );
  }
}

// Pintor auxiliar para generar el borde punteado sin requerir paquetes externos
class DashedCardPainter extends CustomPainter {
  final Color color;
  final double radius;

  DashedCardPainter({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    double dashWidth = 5.0;
    double dashSpace = 4.0;
    Path path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(radius),
      ));

    PathMetrics pathMetrics = path.computeMetrics();
    for (PathMetric pathMetric in pathMetrics) {
      double distance = 0.0;
      while (distance < pathMetric.length) {
        canvas.drawPath(
          pathMetric.extractPath(distance, distance + dashWidth),
          paint,
        );
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}