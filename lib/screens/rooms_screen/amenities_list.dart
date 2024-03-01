import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AmenitiesList extends StatelessWidget {

  final List<String> amenities;
  const AmenitiesList({Key? key, required this.amenities}) : super(key: key);


  IconData getIcon(String name){

    IconData data=Icons.wifi;
     switch(name.tr()){
       case '1':
         data=FontAwesomeIcons.chalkboard;

         break;
       case '2':
         data=FontAwesomeIcons.projectDiagram;

         break;
       case '3':
         data=FontAwesomeIcons.wifi;
         break;
       case '4':
         data=FontAwesomeIcons.tv;
         break;
       case '5':
         data=FontAwesomeIcons.wind;
         break;
       case '6':
         data=FontAwesomeIcons.toilet;
         break;
       case '7':
         data=FontAwesomeIcons.coffee;
         break;

   }
    return data;
  }

  @override
  Widget build(BuildContext context) {
    final size=MediaQuery.of(context).size;
    return Container(
      width:size.width*0.6,
      height: 20,
      child: ListView.builder(
        scrollDirection:Axis.horizontal ,
          itemCount: amenities.length,
          itemBuilder:(context,index){
        return Padding(
          padding: const EdgeInsets.only(left: 8.0,right: 8),
          child: FaIcon(getIcon(amenities[index]),size: 20,),
        );
      }),
    );
  }
}
