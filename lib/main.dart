import 'package:epfl_lend_borrow/data/constants.dart';
import 'package:epfl_lend_borrow/data/notifiers.dart';
import 'package:epfl_lend_borrow/screens/pages/welcome_page.dart';
import 'package:epfl_lend_borrow/screens/widget_tree.dart';
import 'package:epfl_lend_borrow/widgets/navbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}
String? title='EPFL Lend&&Borrow'; //telling this variable can be null
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState(){
    intitThemeMode();
    super.initState();
  }
  void intitThemeMode()async{
    final SharedPreferences prefs= await SharedPreferences.getInstance();
    final bool? repeat =prefs.getBool(KConstants.themeModeKey);
    isDarkMode.value= repeat ?? false;//i assume that ?? means that if null choose the value after it
  }
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: isDarkMode,
      builder: (context, value, child) {
        return MaterialApp(
          title: title!,  //assuring the app the current value of title cannot be null
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFFE50914), // EPFL red-ish seed color
              primary: const Color(0xFFDA291C),
              brightness: isDarkMode.value? Brightness.dark:Brightness.light,

            ),
            useMaterial3: true,
          ),
          home: const MyHomePage()//HomeScreen(),
        );
      }
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: isDarkMode, 
      builder: (context,isDark,child){
        return MaterialApp(
          title:'Flutter',
          debugShowCheckedModeBanner: false,
          theme:ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.teal,
              brightness: isDarkMode.value? Brightness.dark : Brightness.light
            ),
          ),
          home:WelcomePage(),
        );  
      }
    );
  }
}
