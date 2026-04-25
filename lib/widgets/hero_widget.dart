import 'package:flutter/material.dart';

class HeroWidget extends StatelessWidget{
  const HeroWidget({super.key,required this.title});
  final String title;
  @override
  Widget build(BuildContext context){
    return Stack(
      alignment: Alignment.center,
      children: [
        Hero(
          tag: 'Hero',
          child: ClipRRect(
                    borderRadius: BorderRadius.circular(20.0),
                    child: Image.asset('assets/images/alps.png',colorBlendMode: BlendMode.darken,),
          ),
        ),
        FittedBox(child: Text(title,style: TextStyle(fontSize:50.0,color: Colors.redAccent),)),
      ],
    );
  }
}