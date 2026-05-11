import 'package:flutter/material.dart';
import '../../../models/item.dart';


class CategoryPage extends StatefulWidget {
  final Map<ItemType,bool> chosenType;
  const CategoryPage({super.key,required this.chosenType});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListView.builder(
          itemCount: ItemType.values.length,
          itemBuilder: (context, index) => CheckboxListTile.adaptive(value:false, title:Text(ItemType.values.elementAt(index).toString()), onChanged: (value)=> setState(() {widget.chosenType[ItemType.values.elementAt(index)]=value!;}))
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