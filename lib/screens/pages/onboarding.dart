import 'package:epfl_lend_borrow/screens/widget_tree.dart';
import 'package:epfl_lend_borrow/widgets/hero_widget.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

late TextEditingController emailController ;
late TextEditingController pwdController ;

class Onboarding extends StatelessWidget{
  const Onboarding({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body:Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                HeroWidget(title:'need to know her name'),
                SizedBox(height: 10.0,),
                SizedBox(height: 10.0,),
                TextButton(
                    style:FilledButton.styleFrom(minimumSize: Size(double.infinity,40.0)),
                    onPressed: (){},
                    child: Text("getStarted")
                    
                )
              ],
            ),
          ),
        ),
      )
    );
  }


  
}