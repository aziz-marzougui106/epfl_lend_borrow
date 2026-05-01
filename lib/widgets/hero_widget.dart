import 'package:flutter/material.dart';

class HeroWidget extends StatelessWidget{
  const HeroWidget({super.key,required this.title, this.nextPage});
  final String title;
  final Widget? nextPage;
  @override
  Widget build(BuildContext context){
    return GestureDetector(
      onTap: nextPage==null?() {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context){return nextPage!;}));
      }:null,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Hero(
            tag: 'Hero',
            child: AspectRatio(
              aspectRatio: 1920/1080,
              child: ClipRRect(
                        borderRadius: BorderRadius.circular(20.0),
                        child: Image.asset('assets/images/alps.png',fit:BoxFit.cover,colorBlendMode: BlendMode.darken,height: 500.0,),
              ),
            ),
          ),
          FittedBox(child: Text(title,style: TextStyle(fontSize:50.0,color: Colors.redAccent),)),
        ],
      ),
    );
  }
}