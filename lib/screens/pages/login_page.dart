import 'package:epfl_lend_borrow/screens/widget_tree.dart';
import 'package:epfl_lend_borrow/widgets/hero_widget.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

late TextEditingController emailController ;
late TextEditingController pwdController ;

class LoginPage extends StatefulWidget{
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  void initState(){//called only the first time then just the build method called if state changes
    print('init state');
    super.initState();
    emailController =TextEditingController();
    pwdController =TextEditingController();
  }
  @override
  void dispose(){
    emailController.dispose();
    pwdController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    double widthScreen= MediaQuery.of(context).size.width;//can be use instead of LayoutBuilder 
    return Scaffold(
      appBar: AppBar(),
      body:Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: LayoutBuilder(builder: (context,BoxConstraints constraints){
              return FractionallySizedBox(
                widthFactor: constraints.maxWidth >500? 0.5: 1.0,
                child: Column(
                  children: [
                    HeroWidget(title:'need to know her name'),
                    SizedBox(height: 10.0,),
                    TextField(controller: emailController,decoration: InputDecoration(hintText: 'username/email',hintStyle: TextStyle(color:Colors.black12),border:OutlineInputBorder()),onEditingComplete: ()=> setState(() {}),),
                    SizedBox(height: 10.0,),
                    TextField(controller: pwdController,decoration: InputDecoration(hintText: 'password',hintStyle: TextStyle(color:Colors.black12),border:OutlineInputBorder()),onEditingComplete: ()=> setState(() {}),),
                    TextButton(
                        style:FilledButton.styleFrom(minimumSize: Size(double.infinity,40.0)),
                        onPressed: (){
                          onLoginPressed();
                        },
                        child: Text("getStarted")
                        
                    )
                  ],
                ),
              );
            })
          ),
        ),
      )
    );
  }


  void onLoginPressed(){
    if(emailController.text=='mohamed.marzougui@epfl.ch'&& pwdController.text=='hello'){
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context){return WidgetTree();}),(route)=>false);

    }

  }
}