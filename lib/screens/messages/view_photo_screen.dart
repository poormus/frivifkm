import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_calendar/base_scaffolds/base_scaffold.dart';
import 'package:firebase_calendar/shared/constants.dart';
import 'package:firebase_calendar/shared/my_provider.dart';
import 'package:firebase_calendar/shared/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class ViewPhotoScreen extends StatelessWidget {
  final String photoUrl;
  final String senderId;
  const ViewPhotoScreen({Key? key, required this.photoUrl, required this.senderId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider=Provider.of<MyProvider>(context);
    final size=MediaQuery.of(context).size;
    final user=provider.getUserById(senderId);
    final senderName=Utils.getUserName(user.userName, user.userSurname);
    return BaseScaffold(appBarName: senderName, body: buildBody(size), shouldScroll: false);
  }
  Widget buildBody(Size size){
    return Column(
      children: [
        SizedBox(
          height: size.height*0.1,
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          height: size.height*0.5,
          child: CachedNetworkImage(
            fit: BoxFit.cover,
            imageUrl: photoUrl,
            placeholder: (context, url) =>
                Align(child: new CircularProgressIndicator()),
            errorWidget: (context, url, error) =>
            new Icon(Icons.error),
          ),
        ),
        Spacer(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(onPressed: (){}, icon: Icon(Icons.download,color: Constants.CANCEL_COLOR,)),
            IconButton(onPressed: (){}, icon: Icon(Icons.share,color: Constants.CANCEL_COLOR,)),
          ],
        )
      ],
    );
  }
}
