import 'package:epfl_lend_borrow/data/constants.dart';
import 'package:epfl_lend_borrow/widgets/hero_widget.dart';
import 'package:flutter/material.dart';
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20.0),
      child:Card(child: Container(width:double.infinity,padding: EdgeInsetsGeometry.symmetric(vertical:20.0),child: Column(children: [Text('Basic Layout',style:KTextStyle.titleTelaText),Text('description of this',style: KTextStyle.descriptionText)],),),),
    );
  }
}