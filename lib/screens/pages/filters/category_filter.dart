import 'package:flutter/material.dart';
import '../../../models/item.dart';


class CategoryPage extends StatefulWidget {
  final Map<ItemCategory,bool> chosenCat;
  const CategoryPage({super.key,required this.chosenCat});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: ItemCategory.values.length,
              itemBuilder: (context, index) {final category = ItemCategory.values.elementAt(index);final isChecked = widget.chosenCat[category] ?? false;  return CheckboxListTile.adaptive(value:isChecked, title:Text(ItemCategory.values.elementAt(index).name), onChanged: (value)=> setState(() {widget.chosenCat[ItemCategory.values.elementAt(index)]=value!;}));}
            ),
          ),
          ElevatedButton(
            onPressed: (){
              Navigator.pop(context,widget.chosenCat);
            }, 
            child: Text('done')
          ),
          
        ],
      ),
    );
  }
}