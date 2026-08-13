import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:indicator/Global.dart';
import 'package:indicator/main.dart';
import 'package:indicator/models/indicatorsApi.dart';
import 'package:indicator/models/logrosApi.dart';

class Homeprincipal extends StatefulWidget {
  const Homeprincipal({super.key});

  @override
  State<Homeprincipal> createState() => _HomeprincipalState();
}

class _HomeprincipalState extends State<Homeprincipal> {
  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
      appBar: AppBar(
        title: Text("Indicadores de vida V3.0", style: GoogleFonts.poppins(),),
        foregroundColor: Global.action,
        leading: Icon(Icons.favorite),
        actions: [
          InkWell(
            borderRadius: BorderRadius.circular(15),
            onTap: () async {
              if(controller.Page == "indicator"){
                await getIndicators();
                await getLogrosPendientes();
              }
            },
            child: Icon(CupertinoIcons.refresh),
          ),
          SizedBox(width: 10,),
        ],
      ),
      body: controller.Pages[controller.Page],
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 75,
          color: Global.card,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                  onPressed: (){
                    controller.setPage("indicator");
                  },
                  icon: Icon(Icons.favorite, size: 50,)
              ),
              IconButton(
                  onPressed: (){
                    controller.setPage("wish");
                  },
                  icon: Icon(CupertinoIcons.book_fill, size: 50,)
              ),
              IconButton(
                  onPressed: (){
                    controller.setPage("finance");
                  },
                  icon: Icon(Icons.wallet, size: 50,)
              ),
              IconButton(
                  onPressed: (){
                    controller.setPage("user");
                  },
                  icon: Icon(Icons.person, size: 50,)
              ),
            ],
          ),
        ),
      ),
    ));
  }
}
