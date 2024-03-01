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

class CreatePdfForUser {
  final CurrentUserData currentUserData;

  const CreatePdfForUser({
    required this.currentUserData,
  });

  Future createPdf(
      MyProvider provider, List<WorkTime> workTimes, int currentClick) async {
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
    final PdfGrid grid =
        _getGrid(contentFont, provider, workTimes, currentClick);
    final PdfLayoutResult result = _drawHeader(
        page, pageSize, grid, contentFont, headerFont, footerFont, imageBytes);
    _drawGrid(page, grid, result, contentFont);

    final List<int> bytes = await document.save();
    document.dispose();
    await FileSaveHelper.saveAndLaunchFile(bytes, 'My voluntary work.pdf');
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
    //Draw string user name
    page.graphics.drawString(
      Utils.getUserName(
          this.currentUserData.userName, this.currentUserData.userSurname),
      contentFont,
      brush: PdfBrushes.black,
      bounds: Rect.fromLTWH(10, 115, pageSize.width - 115, 90),
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
  PdfGrid _getGrid(PdfFont contentFont, MyProvider provider,
      List<WorkTime> workTimes, int currentClickIndex) {
    //Create a PDF grid
    final PdfGrid grid = PdfGrid();
    //Specify the columns count to the grid.
    grid.columns.add(count: 2);
    //Create the header row of the grid.
    final PdfGridRow headerRow = grid.headers.add(1)[0];
    //Set style
    headerRow.style.backgroundBrush = PdfSolidBrush(PdfColor(68, 114, 196));
    headerRow.style.textBrush = PdfBrushes.white;
    headerRow.cells[0].value = 'Groups';
    headerRow.cells[0].stringFormat.alignment = PdfTextAlignment.center;
    headerRow.cells[1].value = 'Time';

    final allGroupsOfOrganization = provider.allGroupsOfAnOrganization;
    List<Group> myGroups = [];
    allGroupsOfOrganization.forEach((element) {
      if (element.uidList.contains(this.currentUserData.uid)) {
        myGroups.add(element);
      }
    });
    myGroups.forEach((element) {
      final PdfGridRow row = grid.rows.add();
      row.cells[0].value = element.groupName;
      row.cells[1].value =
          getWorkHoursOfAGroup(element.groupId, workTimes, currentClickIndex)
              .toString();
    });
    final PdfGridRow row = grid.rows.add();
    row.cells[0].value = 'Total';
    row.cells[1].value = getTotalWorkHour(workTimes,
            this.currentUserData.currentOrganizationId, currentClickIndex)
        .toString();

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

  //calculations//
  List<WorkTime> getWorkTimesOfAGroup(
      String groupId, List<WorkTime> workTimes) {
    List<WorkTime> myWorkTimes = [];
    workTimes.forEach((element) {
      if (element.groupId == groupId) {
        myWorkTimes.add(element);
      }
    });
    return myWorkTimes;
  }

  int getWorkHoursOfAGroup(
      String groupId, List<WorkTime> workTimes, int currentClickIndex) {
    int totalWorkHours = 0;
    final totalWorkHoursOfAGroup = getWorkTimesOfAGroup(groupId, workTimes);
    switch (currentClickIndex) {
      case 1:
        totalWorkHoursOfAGroup.forEach((element) {
          totalWorkHours += element.hourWorked;
        });
        break;
      case 2:
        totalWorkHoursOfAGroup.forEach((element) {
          if (element.workDate.month == DateTime.now().month) {
            totalWorkHours += element.hourWorked;
          }
        });
        break;

      case 3:
        totalWorkHoursOfAGroup.forEach((element) {
          if (element.workDate.day == DateTime.now().day) {
            totalWorkHours += element.hourWorked;
          }
        });
        break;
    }
    return totalWorkHours;
  }

  int getTotalWorkHour(
      List<WorkTime> workTimes, String organizationId, int currentClickIndex) {
    int totalWorkHour = 0;
    switch (currentClickIndex) {
      case 1:
        workTimes.forEach((element) {
          if (element.organizationId == organizationId) {
            totalWorkHour += element.hourWorked;
          }
        });
        break;

      case 2:
        workTimes.forEach((element) {
          if (element.organizationId == organizationId &&
              element.workDate.month == DateTime.now().month) {
            totalWorkHour += element.hourWorked;
          }
        });
        break;

      case 3:
        workTimes.forEach((element) {
          if (element.organizationId == organizationId &&
              element.workDate.day == DateTime.now().day) {
            totalWorkHour += element.hourWorked;
          }
        });
        break;
    }
    return totalWorkHour;
  }
  //calculations//
}
