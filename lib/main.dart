import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}
String? title='EPFL Lend&&Borrow'; //telling this variable can be null
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title!,  //assuring the app the current value of title cannot be null
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE50914), // EPFL red-ish seed color
          primary: const Color(0xFFDA291C),
        ),
        useMaterial3: true,
      ),
      home: const MyHomePage()//HomeScreen(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int currentIndex=0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text("HomePage"),
        centerTitle: true,
      ),
      body: currentIndex==0? Center(child:Text('0')):Center(child:Text('1')),
      bottomNavigationBar: NavigationBar(
        destinations:[
          NavigationDestination(icon: Icon(Icons.home), label: 'home'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'settings')
        ],
        onDestinationSelected: (int value) {
          setState(() {
            currentIndex=value;
          });
        },
        selectedIndex: currentIndex,
      ),
    );
  }
}
