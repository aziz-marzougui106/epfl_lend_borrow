import 'package:flutter/material.dart';
import '../../../models/item.dart';


class TypePage extends StatefulWidget {
  final Map<ItemType,bool> chosenType;
  const TypePage({super.key,required this.chosenType});

  @override
  State<TypePage> createState() => _TypePageState();
}

class _TypePageState extends State<TypePage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: ListView.builder(
            itemCount: ItemType.values.length,
              itemBuilder: (context, index) {final type = ItemType.values.elementAt(index);final isChecked = widget.chosenType[type] ?? false;  return CheckboxListTile.adaptive(value:isChecked, title:Text(ItemType.values.elementAt(index).name), onChanged: (value)=> setState(() {widget.chosenType[ItemType.values.elementAt(index)]=value!;}));}
          ),
        ),
        ElevatedButton(
          onPressed: (){
            Navigator.pop(context,widget.chosenType);
          }, 
          child: Text('done')
        ),
      ],
    );
  }
}