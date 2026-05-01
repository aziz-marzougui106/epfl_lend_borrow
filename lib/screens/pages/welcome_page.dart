import 'package:epfl_lend_borrow/screens/pages/login_page.dart';
import 'package:epfl_lend_borrow/screens/widget_tree.dart';
import 'package:epfl_lend_borrow/widgets/hero_widget.dart';
import 'package:epfl_lend_borrow/screens/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
class WelcomePage extends StatelessWidget{
  const WelcomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:Padding(
        padding: const EdgeInsets.all(20.0),
        child: Align(
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Lottie.asset('assets/lotties/Home_Icon_Loading.json'),
              FittedBox(child: Text('Declare your love bitch',style:TextStyle(fontWeight: FontWeight.bold,fontSize: 50.0,letterSpacing: 50.0)),),
              SizedBox(height: 20.0,),
              FilledButton(
                style:FilledButton.styleFrom(minimumSize: Size(double.infinity,40.0)),
                onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context){return LoginPage();}));
                },
                child: Text("login")
                
              ),
              TextButton(
                style:FilledButton.styleFrom(minimumSize: Size(double.infinity,40.0)),
                onPressed: (){
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context){return WidgetTree();}));
                },
                child: Text("getStarted")
                
              )
            ],
          ),
        ),
      )

    );
  }
}