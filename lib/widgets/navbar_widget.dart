import 'package:epfl_lend_borrow/data/notifiers.dart';
import 'package:flutter/material.dart';

class MyNavBar extends StatefulWidget {
  const MyNavBar({super.key});

  @override
  State<MyNavBar> createState() => _MyNavBarState();
}

class _MyNavBarState extends State<MyNavBar> {
  int currentIndex=0;
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: selectedPageNotifier, 
      builder: (context,selectedPage,child){
        return  NavigationBar(
            destinations:[
              NavigationDestination(icon: Icon(Icons.home), label: 'home'),
              NavigationDestination(icon: Icon(Icons.settings), label: 'settings')
            ],
            onDestinationSelected: (int sel) {
              selectedPageNotifier.value=sel;
            },
            selectedIndex: selectedPage,
          );
      });
      
  }
}