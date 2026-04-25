import 'package:epfl_lend_borrow/widgets/hero_widget.dart';
import 'package:flutter/material.dart';
class LoginPage extends StatelessWidget{
  const LoginPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body:Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [HeroWidget(title:'need to know her name'),],
        ),
      )
    );
  }
}