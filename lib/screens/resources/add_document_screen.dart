import 'dart:io';
import 'dart:typed_data';

import 'package:easy_localization/src/public_ext.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_calendar/base_scaffolds/base_scaffold.dart';
import 'package:firebase_calendar/components/elevated_button.dart';
import 'package:firebase_calendar/components/secondary_button.dart';
import 'package:firebase_calendar/models/current_user_data.dart';
import 'package:firebase_calendar/services/online_library_service.dart';
import 'package:firebase_calendar/shared/constants.dart';
import 'package:firebase_calendar/shared/utils.dart';
import 'package:flutter/material.dart';

class AddDocument extends StatefulWidget {
  final CurrentUserData currentUserData;
  const AddDocument({Key? key, required this.currentUserData}) : super(key: key);

  @override
  _AddDocumentState createState() => _AddDocumentState();
}

class _AddDocumentState extends State<AddDocument> {


  String? fileName;
  Uint8List? fileBytes;
  String? fileExtension;
  int fileSize=0;
  bool isLoading=false;
  final onlineLibService=DocumentServices();

  void pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(withData: true);

    if (result != null) {
      fileBytes = result.files.first.bytes;
      PlatformFile file = result.files.first;
      setState(() {
        fileName=file.name;
      });
      fileExtension=file.extension;
      fileSize=file.size;
      print(fileBytes);
      print(file.name);
      print(file.bytes);
      print(file.size);
      print(file.extension);
      print(file.path);
    } else {
      // User canceled the picker
    }
  }

  Future uploadFile() async{
    if(fileBytes==null){
      Utils.showSnackBar(context, 'Select a file'.tr());
      return;
    }else if(fileExtension !='pdf'){
      Utils.showSnackBar(context, 'Only pdf format is allowed'.tr());
      return;
    }else if(fileSize>5000000){
      Utils.showSnackBar(context, 'Max file size allowed is 5Mb'.tr());
      return;
    }else{
      setState(() {
        isLoading=true;
      });
      await onlineLibService.createADocument(widget.currentUserData.currentOrganizationId
          , fileName!, fileBytes!,widget.currentUserData.uid).onError((error, stackTrace){
        setState(() {
          isLoading=false;
        });
      });
      setState(() {
        isLoading=false;
      });
    }
    fileBytes=null;
    setState(() {
      fileName=null;
    });
  }
  @override
  Widget build(BuildContext context) {
    return BaseScaffold(appBarName: 'Create document'.tr(), body: buildBody(), shouldScroll: true);
  }

  Widget buildBody(){
    final size=MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 20),
          CustomTextButton(width: size.width*0.8, height: 35, text: 'Select a file'.tr(), textColor: Colors.black, containerColor: Constants.BACKGROUND_COLOR, press:()=>pickFile()),
          SizedBox(height: 20),
          Text(fileName==null?'No file selected'.tr():'${fileName}'),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedCustomButton(text: 'Upload'.tr(), press: ()=>uploadFile(), color: Constants.BUTTON_COLOR),
              SizedBox(width: 10)
            ],
          ),
          SizedBox(height: 20),
          isLoading?Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator()
            ],
          ):Container()
        ],
      ),
    );
  }
}
