import 'package:firebase_calendar/base_scaffolds/base_scaffold.dart';
import 'package:firebase_calendar/models/document.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';


class ViewPdf extends StatelessWidget {
  final Document document;
  const ViewPdf({Key? key, required this.document}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(appBarName: 'Reader', body: buildBody(), shouldScroll: false);

  }

  Widget buildBody(){
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SfPdfViewer.network(document.documentUrl),
    );
  }
}
