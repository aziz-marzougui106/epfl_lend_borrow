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
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child:Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: DropdownButton(
                value:menu,
                items: [DropdownMenuItem(value: 'e1', child: Text('Element1'),),DropdownMenuItem(value: 'e2', child: Text('Element2'),),DropdownMenuItem(value: 'e3', child: Text('Element3'),),], 
                onChanged: (String? value){ setState(() {menu=value;});},
                focusColor: Colors.transparent,//This is a common Flutter issue! The "always selected" highlight you see
              ),
            ),
            TextField(
              controller:controller,
              decoration: InputDecoration(border:OutlineInputBorder()),
              onEditingComplete: () => setState(() {}),
              //onChanged: (value) => setState(() {}), //when the controller changes the state changes
            ),
            Text(controller.text),
            Checkbox.adaptive(tristate: true, value: isChecked, onChanged: (value) {controller.clear(); setState(() => isChecked=value);}),
            CheckboxListTile.adaptive(tristate: true,title:Text('Check me PLZ'), value: isChecked, onChanged:(value)  {controller.clear();setState(()=> isChecked=value);}),
            Switch.adaptive( value: isSwitched, onChanged: (value) {controller.clear(); setState(() => isSwitched=value);}),
            SwitchListTile.adaptive(title:Text('Switch me PLZ'), value: isSwitched, onChanged:(value)  {controller.clear();setState(()=> isSwitched=value);}),
            Slider.adaptive(min:-5.0,max:10.0 , divisions:20, value:slide, onChanged: (double value){slideController.text= value.toString();setState(() => slide=value);}),//divisions on how much parts the range is divided
            Text(slideController.text),
            Text(slide.toStringAsFixed(2)),//2 is the fraction digits
            GestureDetector(
              onTap: () => setState(() {slide=5.0;}),
              child: Image.asset('assets/images/alps.png',fit: BoxFit.contain)
            ),
            InkWell(
              onTap: () {
                setState(() {
                  slide=5.0;
                });
              },
              onDoubleTap: () {
                setState(() {
                  slide=10.0;
                });
              },
              splashColor: Colors.white38,
              child:Container(
                width:double.infinity,
                height: 200,
                color: Colors.white24,
              )
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: (){},
                    style:ElevatedButton.styleFrom(backgroundColor: Colors.teal,foregroundColor: Colors.white),
                    child: Text('click me DD')
                  ),
                  FilledButton(
                    onPressed: (){},
                    child: Text('click me DD')
                  ),
                  TextButton(
                    onPressed: (){},
                    child: Text('click me DD')
                  ),
                  OutlinedButton(
                    onPressed: (){},
                    child: Text('click me DD')
                  ),
                  CloseButton(),
                  BackButton(),
                ],
              ),
            ),

            
          ],
        )
      ),
    );
  }
}