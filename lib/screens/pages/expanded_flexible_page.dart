import 'package:flutter/material.dart';

class ExpandedFlexiblePage extends StatelessWidget{


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(child: Container(color: Colors.teal,)),Flexible(child: Container(color:Colors.amber)),
            ],
          ),
          Row(children: [Flexible(flex:4,child: Container(color:Colors.amber)),Expanded(child: Container(color: Colors.teal,))],)//you will see how the expanded will shrink
        ],
      )
    );
  }
}