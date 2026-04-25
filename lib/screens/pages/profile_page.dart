import 'package:epfl_lend_borrow/data/notifiers.dart';
import 'package:epfl_lend_borrow/screens/pages/welcome_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  TextEditingController controller=TextEditingController(text: '');
  TextEditingController slideController=TextEditingController(text: '');
  bool? isChecked=false;
  bool isSwitched=false;
  double slide=0.0;
  String? menu='e1';
  @override
  Widget build(BuildContext context) {
    return Padding(padding: EdgeInsets.all(20.0),child: Column(children: [ListTile(title:Text('logout'),onTap: (){selectedPageNotifier.value=0;Navigator.pushReplacement(context, MaterialPageRoute(builder: (context){return WelcomePage();}));},)],),);
  }
}