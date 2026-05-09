import 'package:epfl_lend_borrow/data/constants.dart';
import 'package:epfl_lend_borrow/screens/pages/home_page.dart';
import 'package:epfl_lend_borrow/screens/pages/profile_page.dart';
import 'package:epfl_lend_borrow/screens/pages/settings_page.dart';
import 'package:epfl_lend_borrow/widgets/navbar_widget.dart';
import 'package:epfl_lend_borrow/data/notifiers.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const List<Widget> pages=[HomePage(),ProfilePage()];

class WidgetTree extends StatelessWidget {
  const WidgetTree({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("HomePage"),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: ()async{
              isDarkMode.value= !isDarkMode.value;
              final SharedPreferences prefs=await SharedPreferences.getInstance();
              await prefs.setBool(KConstants.themeModeKey, isDarkMode.value);
            }, 
            icon: ValueListenableBuilder(
              valueListenable: isDarkMode, 
              builder: (context,isDark,child){
                return Icon(isDark?Icons.dark_mode:Icons.light_mode);
              }
            )),
          IconButton(
            onPressed: (){
              Navigator.push(//you can use pushReplacement but we can access nomore this page.use cases:login page
                context, 
                MaterialPageRoute(builder: (context){return SettingsPage();})
              );
            }, 
            icon: Icon(Icons.settings))
        ],
      ),
      body: ValueListenableBuilder(valueListenable: selectedPageNotifier, builder: (context,value,child){
        return pages.elementAt(value);
      }),
      drawer: Drawer(
        backgroundColor: Colors.amber,
        child: ValueListenableBuilder(
          valueListenable: isDarkMode,
          builder:(contex,isDark,child){
            return IconButton(onPressed:() => isDarkMode.value=!isDark, icon: Icon(isDark? Icons.dark_mode:Icons.light_mode));
            
          }
        ),
      ),
      
      bottomNavigationBar: MyNavBar(),
    );
  }
}