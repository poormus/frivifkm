import 'package:easy_localization/src/public_ext.dart';
import 'package:firebase_calendar/base_scaffolds/base_scaffold.dart';
import 'package:firebase_calendar/dialog/blurry_dialog_new.dart';
import 'package:firebase_calendar/models/current_user_data.dart';
import 'package:firebase_calendar/models/document.dart';
import 'package:firebase_calendar/services/online_library_service.dart';
import 'package:firebase_calendar/shared/constants.dart';
import 'package:firebase_calendar/shared/navigation.dart';
import 'package:firebase_calendar/shared/utils.dart';
import 'package:flutter/material.dart';

class OnlineLibrary extends StatelessWidget {

  final CurrentUserData currentUserData;
  final String userRole;
  DocumentServices documentServices = DocumentServices();

  OnlineLibrary(
      {Key? key, required this.currentUserData, required this.userRole})
      : super(key: key);

  Future showDeleteDialog(BuildContext context,String documentId) async {
    final dialog =BlurryDialogNew(title: 'Delete this document?'.tr(), continueCallBack: (){
       documentServices.deleteDocument(documentId);
       Navigator.pop(context);
    });
    showDialog(context: context, builder: (_){
      return dialog;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return BaseScaffold(
        appBarName: 'Online library'.tr(),
        body: buildBody(size),
        shouldScroll: false,
        floatingActionButton: buildFab(context));
  }

  Widget buildBody(Size size) {
    return StreamBuilder<List<Document>>(
      stream: documentServices
          .getDocumentsForOrganization(currentUserData.currentOrganizationId),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final documents = snapshot.data!;
          if (documents.length == 0) {
            return noDataWidget('No documents found'.tr(), false);
          } else {
            return ListView.builder(
                itemCount: documents.length,
                itemBuilder: (context, index) {
                  return documentTile(documents[index], context, size);
                });
          }
        } else if (snapshot.hasError) {
          return noDataWidget(snapshot.error.toString(), false);
        } else
          return noDataWidget(null, true);
      },
    );
  }

  Widget? buildFab(BuildContext context) {
    return userRole == '4'||userRole == '3'
        ? FloatingActionButton(
            backgroundColor: Constants.BUTTON_COLOR,
            onPressed: () {
              Navigation.navigateToAddDocumentScreen(context, currentUserData);
            },
            child: Icon(Icons.add),
          )
        : null;
  }

  Widget documentTile(Document document, BuildContext context, Size size) {
    return GestureDetector(
      onTap: () {
        Navigation.navigateToViewPdf(context, document);
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
              color: Constants.CONTAINER_COLOR,
              borderRadius: BorderRadius.circular(8)),
          child: ListTile(
            leading: Icon(Icons.picture_as_pdf_outlined,
                color: Constants.CANCEL_COLOR),
            title: Container(
                height: 35,
                child: Container(
                    width: size.width * 0.50,
                    child: Text(document.documentName,
                        style: appTextStyle.copyWith(
                            overflow: TextOverflow.ellipsis)))),
            subtitle: Text(Utils.getTimeAgo(document.createdAt, context)),
            trailing:document.createdByUid==currentUserData.uid || userRole == '4' ? IconButton(
              icon: Icon(
                Icons.delete,
                color: Constants.CANCEL_COLOR,
              ),
              onPressed: (){
                showDeleteDialog(context,document.documentId);
              },
            ):null,
          ),
        ),
      ),
    );
  }
}
