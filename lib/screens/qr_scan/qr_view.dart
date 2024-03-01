import 'dart:io';
import 'dart:ui';
import 'package:easy_localization/src/public_ext.dart';
import 'package:firebase_calendar/anim/popup_anim.dart';
import 'package:firebase_calendar/base_scaffolds/base_scaffold.dart';
import 'package:firebase_calendar/components/secondary_button.dart';
import 'package:firebase_calendar/models/current_user_data.dart';
import 'package:firebase_calendar/services/qr_services.dart';
import 'package:firebase_calendar/shared/constants.dart';
import 'package:firebase_calendar/shared/utils.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:scan/scan.dart';

class QrView extends StatefulWidget {
  final CurrentUserData currentUserData;
  final String userRole;

  const QrView(
      {Key? key, required this.currentUserData, required this.userRole})
      : super(key: key);

  @override
  State<QrView> createState() => _QrViewState();
}

class _QrViewState extends State<QrView> {
  ScanController scanController = ScanController();
  final ImagePicker picker = ImagePicker();
  final QrServices qrServices = QrServices();
  final qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  Barcode? barCode;
  int writeCount = 0;

  @override
  void dispose() {
    controller!.dispose();
    super.dispose();
  }

  @override
  void reassemble() async {
    if (Platform.isAndroid) {
      await controller!.pauseCamera();
    }
    controller!.resumeCamera();
    super.reassemble();
  }

  Future pickImageGallery(BuildContext context, ImagePicker picker) async {
    var status = await Permission.storage.status;

    if (status.isGranted) {
      final pickedFile =
          await picker.pickImage(source: ImageSource.gallery, imageQuality: 30);

      if (pickedFile != null) {
        File file = File(pickedFile.path);
        String? result = await Scan.parse(file.path);
        print('printing result $result');
        if (result != null) {
          createQrFromFile(result);
          Utils.showToastWithoutContext('Log has been created'.tr());
        }
      }
    } else if (!status.isGranted) {
      await Permission.storage.request();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      appBarName: 'Scan qr'.tr(),
      body: buildBody(context),
      shouldScroll: false,
      actions: actions(),
    );
    return buildScaffold('Scan qr', context, buildBody(context), null);
  }

  List<Widget>? actions() {
    return widget.userRole == '4'
        ? [
            IconButton(
                onPressed: () {
                  Navigator.of(context)
                      .push(HeroDialogRoute(builder: (context) {
                    return _PopupCard(
                        organizationId:
                            widget.currentUserData.currentOrganizationId);
                  }));
                },
                icon:
                    Icon(Icons.upload_rounded, color: Constants.CANCEL_COLOR)),
          ]
        : null;
  }

  Widget buildBody(BuildContext context) {
    if (writeCount == 1) {
      dismissDialog();
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        QRView(
          key: qrKey,
          onQRViewCreated: onQrViewCreated,
          overlay: QrScannerOverlayShape(
            borderColor: Constants.BACKGROUND_COLOR,
            borderWidth: 10,
            borderLength: 20,
            borderRadius: 10,
            cutOutSize: MediaQuery.of(context).size.width * 0.8,
          ),
        ),
        Positioned(
          bottom: 40,
          child: Row(
            children: [
              IconButton(
                  onPressed: () {
                    controller?.toggleFlash();
                  },
                  icon: Icon(
                    Icons.flash_on,
                    color: Constants.CANCEL_COLOR,
                  )),
              // IconButton(onPressed: (){
              //   pickImageGallery(context, picker);
              // },icon: Icon(Icons.insert_drive_file,color: Constants.CANCEL_COLOR,)),
              IconButton(
                  onPressed: () {
                    controller?.resumeCamera();
                  },
                  icon: Icon(
                    Icons.camera_alt,
                    color: Constants.CANCEL_COLOR,
                  )),
            ],
          ),
        ),
        Positioned(
            bottom: 10,
            child: Text(
              barCode != null
                  ? 'Log has been created'.tr()
                  : "Scanning...".tr(),
              style: appTextStyle.copyWith(color: Colors.white),
            ))
      ],
    );
  }

  void dismissDialog() {
    final userName = Utils.getUserName(
        widget.currentUserData.userName, widget.currentUserData.userSurname);
    Future.delayed(const Duration(milliseconds: 200), () {
      qrServices.addQrEntry(
          barCode!.code.toString(), widget.currentUserData.uid, userName);
    });
  }

  void createQrFromFile(String organizationId) {
    bool isIdFound = false;
    for (var i = 0; i < widget.currentUserData.userOrganizations.length; i++) {
      if (widget.currentUserData.userOrganizations[i].organizationId ==
          organizationId) {
        isIdFound = true;
        break;
      }
    }
    if (isIdFound) {
      final userName = Utils.getUserName(
          widget.currentUserData.userName, widget.currentUserData.userSurname);
      qrServices.addQrEntry(
          organizationId, widget.currentUserData.uid, userName);
    } else {
      Utils.showToastWithoutContext('Something went wrong'.tr());
    }
  }

  void onQrViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scannedCode) {
      bool isIdFound = false;
      for (var i = 0;
          i < widget.currentUserData.userOrganizations.length;
          i++) {
        if (widget.currentUserData.userOrganizations[i].organizationId ==
            scannedCode.code) {
          isIdFound = true;
          break;
        }
      }
      if (isIdFound) {
        print(scannedCode);
        setState(() {
          this.barCode = scannedCode;
          writeCount++;
        });
      } else {
        Utils.showToastWithoutContext(
            'You are not a member of this organization'.tr());
      }
    });
  }
}

class _PopupCard extends StatelessWidget {
  final String organizationId;
  ScreenshotController screenshotController = ScreenshotController();

  _PopupCard({
    required this.organizationId,
  });

  _shareQrCode() async {
    final directory = (await getApplicationDocumentsDirectory()).path;
    screenshotController.capture().then((image) async {
      if (image != null) {
        try {
          String fileName = DateTime.now().microsecondsSinceEpoch.toString();
          final imagePath = await File('$directory/$fileName.png').create();
          if (imagePath != null) {
            await imagePath.writeAsBytes(image);
            Share.shareFiles([imagePath.path]);
          }
        } catch (error) {}
      }
    }).catchError((onError) {
      print('Error --->> $onError');
    });
  }

  Future<void> shareQrCode() async {
    try {
      final image = await QrPainter(
        color: Colors.black,
        data: organizationId,
        version: QrVersions.auto,
        gapless: false,
      ).toImage(300);
      final a = await image.toByteData(format: ImageByteFormat.png);

      Directory tempDir = await getTemporaryDirectory();
      String tempPath = tempDir.path;
      final ts = DateTime.now().millisecondsSinceEpoch.toString();
      String path = '$tempPath/$ts.png';

      final buffer = a!.buffer;
      await File(path)
          .writeAsBytes(buffer.asUint8List(a.offsetInBytes, a.lengthInBytes));
      Share.shareFiles([path]);
    } catch (e) {
      throw e;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Hero(
          tag: 'animate_popup_qr',
          child: Material(
            color: Colors.white,
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      height: 300,
                      child: Screenshot(
                        controller: screenshotController,
                        child: QrImageView(
                            size: 300,
                            backgroundColor: Colors.white,
                            data: organizationId),
                      ),
                    ),
                  ),
                  CustomTextButton(
                      width: 70,
                      height: 35,
                      text: 'Share'.tr(),
                      textColor: Colors.white,
                      containerColor: Constants.BUTTON_COLOR,
                      press: () {
                        _shareQrCode();
                      }),
                  SizedBox(height: 10)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
