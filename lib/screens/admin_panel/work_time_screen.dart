import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:firebase_calendar/components/secondary_button.dart';
import 'package:firebase_calendar/dialog/view_user_work_by_admin.dart';
import 'package:firebase_calendar/helper/save_file_mobile.dart';
import 'package:firebase_calendar/models/current_user_data.dart';
import 'package:firebase_calendar/models/work_time.dart';
import 'package:firebase_calendar/shared/constants.dart';
import 'package:firebase_calendar/shared/my_provider.dart';
import 'package:firebase_calendar/shared/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class WorkTimeScreen extends StatefulWidget {
  final CurrentUserData currentUserData;
  const WorkTimeScreen({Key? key, required this.currentUserData})
      : super(key: key);

  @override
  _WorkTimeScreenState createState() => _WorkTimeScreenState();
}

class _WorkTimeScreenState extends State<WorkTimeScreen> {
  String sortString = 'This year';
  int currentClickIndex = 1;

  @override
  void initState() {
    Utils.fileFromImageUrl(Utils.getOrgNameAndImage(
        widget.currentUserData.currentOrganizationId,
        widget.currentUserData.userOrganizations)[1]);
    super.initState();
  }

  Future createPdf(MyProvider provider) async {
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
    final PdfGrid grid = _getGrid(contentFont, provider);
    final PdfLayoutResult result = _drawHeader(
        page, pageSize, grid, contentFont, headerFont, footerFont, imageBytes);
    _drawGrid(page, grid, result, contentFont);

    final List<int> bytes = await document.save();
    document.dispose();
    await FileSaveHelper.saveAndLaunchFile(bytes, 'Voluntary work.pdf');
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

    //Draw string
    page.graphics.drawString(
        Utils.getOrgNameAndImage(widget.currentUserData.currentOrganizationId,
            widget.currentUserData.userOrganizations)[0],
        headerFont,
        brush: PdfBrushes.black,
        bounds: Rect.fromLTWH(10, 90, pageSize.width - 115, 90),
        format: PdfStringFormat(lineAlignment: PdfVerticalAlignment.middle));

    page.graphics
        .drawImage(PdfBitmap(imageData), Rect.fromLTWH(10, 10, 100, 100));

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
        page: page, bounds: Rect.fromLTWH(0, result.bounds.bottom + 40, 0, 0))!;
  }

  Future<List<int>> _readData(String name) async {
    final ByteData data = await rootBundle.load('assets/fonts/$name');
    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  }

//Create PDF grid and return
  PdfGrid _getGrid(PdfFont contentFont, MyProvider provider) {
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

    provider.allGroupsOfAnOrganization.forEach((element) {
      final PdfGridRow row = grid.rows.add();
      row.cells[0].value = element.groupName;
      row.cells[1].value =
          calculateTotalWorkTimeOfAGroup(provider, element.groupId).toString();
    });
    final PdfGridRow row = grid.rows.add();
    row.cells[0].value = 'Total';
    row.cells[1].value = _filteredWorkTime(
            provider, widget.currentUserData.currentOrganizationId)
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

  int _filteredWorkTime(MyProvider provider, String organizationId) {
    int totalWorkHour = 0;
    final allWorkTime = provider.allWorkTimeOfAnOrganization;
    final allEntries = allWorkTime.entries;
    switch (currentClickIndex) {
      case 1:
        allEntries.forEach((element) {
          element.value.forEach((element) {
            if (element.organizationId == organizationId) {
              totalWorkHour += element.hourWorked;
            }
          });
        });
        break;
      case 2:
        allEntries.forEach((element) {
          element.value.forEach((element) {
            if (element.workDate.month == DateTime.now().month &&
                element.organizationId == organizationId) {
              totalWorkHour += element.hourWorked;
            }
          });
        });
        break;
      case 3:
        allEntries.forEach((element) {
          element.value.forEach((element) {
            if (element.workDate.day == DateTime.now().day &&
                element.organizationId == organizationId &&
                element.workDate.month == DateTime.now().month) {
              totalWorkHour += element.hourWorked;
            }
          });
        });
        break;
    }
    return totalWorkHour;
  }

  int calculateTotalWorkTimeOfAGroup(MyProvider provider, String groupId) {
    int totalTime = 0;
    final allWorkTime = provider.allWorkTimeOfAnOrganization;
    final allEntries = allWorkTime.entries;
    switch (currentClickIndex) {
      case 1:
        allEntries.forEach((element) {
          element.value.forEach((element) {
            if (element.groupId == groupId) {
              totalTime += element.hourWorked;
            }
          });
        });
        break;
      case 2:
        allEntries.forEach((element) {
          element.value.forEach((element) {
            if (element.workDate.month == DateTime.now().month &&
                element.groupId == groupId) {
              totalTime += element.hourWorked;
            }
          });
        });
        break;
      case 3:
        allEntries.forEach((element) {
          element.value.forEach((element) {
            if (element.workDate.day == DateTime.now().day &&
                element.groupId == groupId) {
              totalTime += element.hourWorked;
            }
          });
        });
        break;
    }
    return totalTime;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final provider = Provider.of<MyProvider>(context);
    final users = provider.getCurrentOrganizationUserList(
        widget.currentUserData.currentOrganizationId);
    final totalWorkTime = _filteredWorkTime(
        provider, widget.currentUserData.currentOrganizationId);
    return Expanded(
      child: Column(
        children: [
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomTextButton(
                    width: size.width * 0.3,
                    height: 60,
                    text: sortString.tr(),
                    textColor: Colors.black,
                    containerColor: Constants.CONTAINER_COLOR,
                    press: () {
                      currentClickIndex++;
                      if (currentClickIndex > 3) {
                        currentClickIndex = 1;
                      }
                      if (currentClickIndex == 1) {
                        setState(() {
                          currentClickIndex = 1;
                          sortString = 'This year';
                        });
                      } else if (currentClickIndex == 2) {
                        setState(() {
                          currentClickIndex = 2;
                          sortString = 'This month';
                        });
                      } else if (currentClickIndex == 3) {
                        setState(() {
                          currentClickIndex = 3;
                          sortString = 'Today';
                        });
                      }
                    }),
                CustomTextButton(
                    width: size.width * 0.3,
                    height: 60,
                    text: '${totalWorkTime.toString()}' + 'h'.tr(),
                    textColor: Colors.black,
                    containerColor: Constants.BACKGROUND_COLOR,
                    press: () {}),
                Platform.isIOS
                    ? Container()
                    : GestureDetector(
                        onTap: () => createPdf(provider),
                        child: Container(
                          width: size.width * 0.2,
                          height: 60,
                          decoration: BoxDecoration(
                              color: Constants.BUTTON_COLOR,
                              borderRadius: BorderRadius.circular(8)),
                          child: Icon(
                            Icons.download,
                            color: Colors.white,
                          ),
                        ),
                      )
              ],
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  return UserTileWork(
                    person: users[index],
                    adminOrganizationId:
                        widget.currentUserData.currentOrganizationId,
                    provider: provider,
                    currentClickIndex: currentClickIndex,
                  );
                }),
          )
        ],
      ),
    );
  }
}

//user Tile
class UserTileWork extends StatelessWidget {
  final CurrentUserData person;
  final String adminOrganizationId;
  final MyProvider provider;
  final int currentClickIndex;
  const UserTileWork(
      {Key? key,
      required this.person,
      required this.adminOrganizationId,
      required this.provider,
      required this.currentClickIndex})
      : super(key: key);

  int calculateTotalWorkHourOfAUser() {
    int totalHours = 0;
    List<WorkTime>? userWorkTimes =
        provider.allWorkTimeOfAnOrganization['${person.uid}'];
    switch (currentClickIndex) {
      case 1:
        userWorkTimes?.forEach((element) {
          if (element.organizationId == adminOrganizationId) {
            totalHours += element.hourWorked;
          }
        });
        break;
      case 2:
        userWorkTimes?.forEach((element) {
          if (element.organizationId == adminOrganizationId &&
              element.workDate.month == DateTime.now().month) {
            totalHours += element.hourWorked;
          }
        });
        break;
      case 3:
        userWorkTimes?.forEach((element) {
          if (element.organizationId == adminOrganizationId &&
              element.workDate.month == DateTime.now().month &&
              element.workDate.day == DateTime.now().day) {
            totalHours += element.hourWorked;
          }
        });
        break;
    }
    return totalHours;
  }

  @override
  Widget build(BuildContext context) {
    final userName = Utils.getUserName(person.userName, person.userSurname);
    final userRole =
        Utils.getUserRole(person.userOrganizations, adminOrganizationId);
    final userRoleFromIndex = Utils.getUserRoleFromIndex(userRole);
    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(5)),
        child: CachedNetworkImage(
          fit: BoxFit.cover,
          width: 30,
          height: 30,
          imageUrl: person.userUrl,
          placeholder: (context, url) => new CircularProgressIndicator(),
          errorWidget: (context, url, error) => new Icon(Icons.error),
        ),
      ),
      title: Text(userName),
      subtitle: Text(userRoleFromIndex),
      trailing: Column(
        children: [
          Container(
              height: 26,
              width: 50,
              decoration: BoxDecoration(
                  color: Constants.BACKGROUND_COLOR,
                  borderRadius: BorderRadius.circular(8)),
              child: Center(
                child: Text(
                  '${calculateTotalWorkHourOfAUser()}' + 'h'.tr(),
                  style: appTextStyle.copyWith(fontSize: 16),
                ),
              )),
          SizedBox(
            height: 4,
          ),
          // Container(
          //     height: 26,
          //     width: 50,
          //     decoration: BoxDecoration(
          //         color: Constants.BUTTON_COLOR,
          //         borderRadius: BorderRadius.circular(8)),
          //     child: Center(
          //       child: Text('${ calculateApprovedWorkHourOfAUser()}' +
          //           'h'.tr(),style: appTextStyle.copyWith(fontSize: 16,color: Colors.white),),
          //     )),
        ],
      ),
      onTap: () {
        List<WorkTime>? userWorkTimes =
            provider.allWorkTimeOfAnOrganization['${person.uid}'];
        final dialog = ViewUserWorkTimesDialog(
            workTimes: userWorkTimes, currentUserData: person);
        showDialog(context: context, builder: (_) => dialog);
      },
    );
  }

  int calculateApprovedWorkHourOfAUser() {
    int approvedTime = 0;
    List<WorkTime>? userWorkTimes =
        provider.allWorkTimeOfAnOrganization['${person.uid}'];
    userWorkTimes?.forEach((element) {
      if (element.organizationId == adminOrganizationId && element.isApproved) {
        approvedTime += element.hourWorked;
      }
    });
    return approvedTime;
  }
}
