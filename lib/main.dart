import 'package:animate_do/animate_do.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:indicator/Global.dart';
import 'package:indicator/controllers/MyController.dart';

void main(){
  Get.put(MyController());
  runApp(
    GetMaterialApp(
      title: "Indicator",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.openSansTextTheme(),
      ),
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        scaffoldBackgroundColor: Global.bg,
        iconTheme: IconThemeData(color: Global.action),
        cardColor: Global.card,
        appBarTheme: AppBarTheme(backgroundColor: Global.bg, centerTitle: false,)
      ),
      home: Splash(),
    )
  );
}

MyController controller = Get.find();

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Center(
          child: FadeIn(child: Icon(Icons.favorite, size: 50,)),
        ),
      ),
    );
  }
}

