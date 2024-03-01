import 'dart:io';

import 'package:easy_localization/src/public_ext.dart';
import 'package:firebase_calendar/components/secondary_button.dart';
import 'package:firebase_calendar/shared/constants.dart';
import 'package:firebase_calendar/shared/utils.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class SelectImageSourceDialog extends StatelessWidget {
  final imageSelected selectedImage;

  const SelectImageSourceDialog({Key? key, required this.selectedImage})
      : super(key: key);

  Future pickImageGallery(BuildContext context, ImagePicker picker) async {
    var status = await Permission.storage.status;
    if (Platform.isAndroid) {
      final pickedFile =
          await picker.pickImage(source: ImageSource.gallery, imageQuality: 30);
      if (pickedFile != null) {
        File file = File(pickedFile.path);
        selectedImage(onImageSelected(imageFile: file));
        Navigator.of(context).pop();
      }
    } else {
      if (status.isGranted) {
        final pickedFile = await picker.pickImage(
            source: ImageSource.gallery, imageQuality: 30);
        if (pickedFile != null) {
          File file = File(pickedFile.path);
          selectedImage(onImageSelected(imageFile: file));
          Navigator.of(context).pop();
        }
      } else if (!status.isGranted) {
        await Permission.storage.request();
      }
    }
  }

  Future pickImageCamera(BuildContext context, ImagePicker picker) async {
    var status = await Permission.camera.status;
    if (status.isGranted) {
      final pickedFile =
          await picker.pickImage(source: ImageSource.camera, imageQuality: 30);
      if (pickedFile != null) {
        File file = File(pickedFile.path);
        selectedImage(onImageSelected(imageFile: file));
        Navigator.of(context).pop();
      }
    } else if (status.isDenied) {
      await Permission.camera.request();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final picker = ImagePicker();
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(24),
        ),
      ),
      backgroundColor: Constants.BACKGROUND_COLOR,
      child: Container(
          height: 190,
          child: Stack(
            children: [
              Align(
                child: Column(
                  children: [
                    SizedBox(height: 15),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Complete action using'.tr(),
                        style: appTextStyle.copyWith(fontSize: 20),
                      ),
                    ),
                    SizedBox(height: 10),
                    CustomTextButton(
                        width: size.width * 0.6,
                        height: 40,
                        text: 'Camera'.tr(),
                        textColor: Constants.BUTTON_COLOR,
                        containerColor: Colors.white,
                        press: () {
                          pickImageCamera(context, picker);
                        }),
                    SizedBox(height: 25),
                    CustomTextButton(
                        width: size.width * 0.6,
                        height: 40,
                        text: 'Gallery'.tr(),
                        textColor: Constants.BUTTON_COLOR,
                        containerColor: Colors.white,
                        press: () {
                          pickImageGallery(context, picker);
                        })
                  ],
                ),
              ),
              Align(
                // These values are based on trial & error method
                alignment: Alignment(1.1, -1.1),
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Icon(
                      Icons.cancel,
                      color: Constants.CANCEL_COLOR,
                      size: 40,
                    ),
                  ),
                ),
              ),
            ],
          )),
    );
  }
}

/// create this class to pass the data type you want
class onImageSelected {
  onImageSelected({required this.imageFile});

  final File imageFile;
}

/// Signature for callback which reports the picker value changed based on the class above...
typedef imageSelected = void Function(onImageSelected onImageSelected);
