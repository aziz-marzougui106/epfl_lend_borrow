import 'package:flutter/material.dart';
import '../../../models/item.dart';


class BrandPage extends StatefulWidget {
  final Map<ItemBrand,bool> chosenBrand;
  const BrandPage({super.key,required this.chosenBrand});

  @override
  State<BrandPage> createState() => _BrandPageState();
}

class _BrandPageState extends State<BrandPage> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: (){
        showModalBottomSheet<Widget>(
          context: context, 
          builder: (context)=>Container(
            child: ListView.builder(
              itemCount: ItemBrand.values.length,
              itemBuilder: (context, index) => CheckboxListTile.adaptive(value:false, title:Text(ItemBrand.values.elementAt(index).toString()), onChanged: (value)=> setState(() {widget.chosenBrand[ItemBrand.values.elementAt(index)]=value!;}))
            ),
          )
        ); 
      }, 
      child: Text('brand')
    );
  }
}