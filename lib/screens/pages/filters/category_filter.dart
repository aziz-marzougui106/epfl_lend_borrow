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
    return ElevatedButton(
      onPressed: (){
        showModalBottomSheet<Widget>(
          context: context, 
          builder: (context)=>Container(
            child: ListView.builder(
              itemCount: ItemCategory.values.length,
              itemBuilder: (context, index) => CheckboxListTile.adaptive(value:false, title:Text(ItemCategory.values.elementAt(index).toString()), onChanged: (value)=> setState(() {widget.chosenCat[ItemCategory.values.elementAt(index)]=value!;}))
            ),
          )
        ); 
      }, 
      child: Text('category')
    );
  }
}