import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  TextEditingController controller=TextEditingController();
  bool? isChecked=false;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child:Column(
        children: [
          TextField(
            controller:controller,
            decoration: InputDecoration(border:OutlineInputBorder()),
            onEditingComplete: () => setState(() {}),
            //onChanged: (value) => setState(() {}), //when the controller changes the state changes
          ),
          Text(controller.text),
          Checkbox(tristate: true, value: isChecked, onChanged: (value) {controller.clear(); setState(() => isChecked=value);}),
          CheckboxListTile(tristate: true, value: isChecked, onChanged:(value)  {controller.clear();setState(()=> isChecked=value);}),
          
        ],
      )
    );
  }
}