import 'package:firebase_calendar/models/qr_scan.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_calendar/helper/save_file_mobile.dart';
import 'package:firebase_calendar/models/current_user_data.dart';
import 'package:firebase_calendar/models/group.dart';
import 'package:firebase_calendar/models/work_time.dart';
import 'package:firebase_calendar/shared/my_provider.dart';
import 'package:firebase_calendar/shared/utils.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class CreateQrPdf {
  final List<QrScan> logs;
  final CurrentUserData currentUserData;

  const CreateQrPdf({
    required this.currentUserData,
    required this.logs,
  });

  Future createPdf() async {
    final imageBytes = await Utils.readFile();
    PdfDocument document;
    document = PdfDocument();
    const String text =
        'Adventure Works Cycles, the fictitious company on which the AdventureWorks sample databases are based, is a large, multinational manufacturing company. The company manufactures and sells metal and composite bicycles to North American, European and Asian commercial markets. While its base operation is located in Bothell, Washington with 290 employees, several regional sales teams are located throughout their market base.';
    document.attachments.add(PdfAttachment(
        'AdventureCycle.txt', utf8.encode(text),
        description: 'Adventure Works Cycles', mimeType: 'application/txt'));
    //Add page to the PDF
    final PdfPage page = document.pages.add();
    //Get page client size
    final Size pageSize = page.getClientSize();
    print('called 1');
    page.graphics.drawRectangle(
        bounds: Rect.fromLTWH(0, 0, pageSize.width, pageSize.height),
        pen: PdfPen(PdfColor(142, 170, 219, 255)));
    final List<int> fontData = await _readData('Roboto-Regular.ttf');
    //Create a PDF true type font.
    final PdfFont contentFont = PdfTrueTypeFont(fontData, 9);
    final PdfFont headerFont = PdfTrueTypeFont(fontData, 30);
    final PdfFont footerFont = PdfTrueTypeFont(fontData, 18);
    final PdfGrid grid = _getGrid(contentFont);
    final PdfLayoutResult result = _drawHeader(
        page, pageSize, grid, contentFont, headerFont, footerFont, imageBytes);
    _drawGrid(page, grid, result, contentFont);

    final List<int> bytes = await document.save();
    document.dispose();
    await FileSaveHelper.saveAndLaunchFile(bytes, 'User logs.pdf');
  }

  PdfLayoutResult _drawHeader(
      PdfPage page,
      Size pageSize,
      PdfGrid grid,
      PdfFont contentFont,
      PdfFont headerFont,
      PdfFont footerFont,
      List<int> imageData) {
    //Draw rectangle
    // page.graphics.drawRectangle(
    //     brush: PdfSolidBrush(PdfColor(91, 126, 215, 255)),
    //     bounds: Rect.fromLTWH(0, 0, pageSize.width , 90));

    int totalEntryCount = 0;
    int totalExitCount = 0;
    logs.forEach((log) {
      if (log.logType == 'Entry') {
        totalEntryCount = totalEntryCount + 1;
      } else if (log.logType == 'Exit') {
        totalExitCount = totalExitCount + 1;
      }
    });

    page.graphics
        .drawImage(PdfBitmap(imageData), Rect.fromLTWH(10, 10, 100, 100));

    //Draw string organization name
    page.graphics.drawString(
        Utils.getOrgNameAndImage(this.currentUserData.currentOrganizationId,
            this.currentUserData.userOrganizations)[0],
        headerFont,
        brush: PdfBrushes.black,
        bounds: Rect.fromLTWH(10, 90, pageSize.width - 115, 90),
        format: PdfStringFormat(lineAlignment: PdfVerticalAlignment.middle));
    //Draw string total entry
    page.graphics.drawString(
      'Total entry: ${totalEntryCount}',
      contentFont,
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(10, 115, pageSize.width - 115, 90),
      format: PdfStringFormat(lineAlignment: PdfVerticalAlignment.middle),
    );
    //Draw string total exit
    page.graphics.drawString(
      'Total exit: ${totalExitCount}',
      contentFont,
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(10, 130, pageSize.width - 115, 90),
      format: PdfStringFormat(lineAlignment: PdfVerticalAlignment.middle),
    );

    //Create data format and convert it to text.
    final DateFormat format = DateFormat.yMMMMd('en_US');
    final String invoiceNumber = 'Invoice Number: 2058557939\r\n\r\nDate: ' +
        format.format(DateTime.now());
    final Size contentSize = contentFont.measureString(invoiceNumber);

    return PdfTextElement().draw(
        page: page,
        bounds: Rect.fromLTWH(30, 120,
            pageSize.width - (contentSize.width + 30), pageSize.height - 120))!;
  }

  void _drawGrid(
      PdfPage page, PdfGrid grid, PdfLayoutResult result, PdfFont contentFont) {
    Rect? totalPriceCellBounds;
    Rect? quantityCellBounds;
    //Invoke the beginCellLayout event.
    grid.beginCellLayout = (Object sender, PdfGridBeginCellLayoutArgs args) {
      final PdfGrid grid = sender as PdfGrid;
      if (args.cellIndex == grid.columns.count - 1) {
        totalPriceCellBounds = args.bounds;
      } else if (args.cellIndex == grid.columns.count - 2) {
        quantityCellBounds = args.bounds;
      }
    };
    //Draw the PDF grid and get the result.
    result = grid.draw(
        page: page, bounds: Rect.fromLTWH(0, result.bounds.bottom + 60, 0, 0))!;
  }

  Future<List<int>> _readData(String name) async {
    final ByteData data = await rootBundle.load('assets/fonts/$name');
    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  }

//Create PDF grid and return
  PdfGrid _getGrid(PdfFont contentFont) {
    //Create a PDF grid
    final PdfGrid grid = PdfGrid();
    //Specify the columns count to the grid.
    grid.columns.add(count: 2);
    //Create the header row of the grid.
    final PdfGridRow headerRow = grid.headers.add(1)[0];
    //Set style
    headerRow.style.backgroundBrush = PdfSolidBrush(PdfColor(68, 114, 196));
    headerRow.style.textBrush = PdfBrushes.white;
    headerRow.cells[0].value = 'User name';
    headerRow.cells[0].stringFormat.alignment = PdfTextAlignment.center;
    headerRow.cells[1].value = 'Log type';

    logs.forEach((log) {
      final PdfGridRow row = grid.rows.add();
      row.cells[0].value = log.userName;
      switch (log.logType) {
        case 'pending':
          row.cells[1].value = log.userName;
          break;
        case 'Exit':
          row.cells[1].value = 'Exit ${Utils.toDate(log.createdAt)}';
          break;
        case 'Entry':
          row.cells[1].value = 'Entry ${Utils.toDate(log.createdAt)}';
          ;
          break;
      }
    });

    final PdfPen whitePen = PdfPen(PdfColor.empty, width: 0.5);
    final PdfBorders borders = PdfBorders();
    borders.all = PdfPen(PdfColor(142, 179, 219), width: 0.5);
    grid.rows.applyStyle(PdfGridCellStyle(borders: borders));
    grid.columns[1].width = 200;
    for (int i = 0; i < headerRow.cells.count; i++) {
      headerRow.cells[i].style.cellPadding =
          PdfPaddings(bottom: 5, left: 5, right: 5, top: 5);
      headerRow.cells[i].style.borders.all = whitePen;
    }
    for (int i = 0; i < grid.rows.count; i++) {
      final PdfGridRow row = grid.rows[i];
      if (i.isEven) {
        row.style.backgroundBrush = PdfSolidBrush(PdfColor(217, 226, 243));
      }
      for (int j = 0; j < row.cells.count; j++) {
        final PdfGridCell cell = row.cells[j];
        if (j == 0) {
          cell.stringFormat.alignment = PdfTextAlignment.center;
        }
        cell.style.cellPadding =
            PdfPaddings(bottom: 5, left: 5, right: 5, top: 5);
      }
    }
    //Set font
    grid.style.font = contentFont;
    return grid;
  }
}
