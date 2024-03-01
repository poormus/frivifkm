import 'dart:io';
import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:firebase_calendar/dialog/sort_logs_by_date.dart';
import 'package:firebase_calendar/helper/create_qr_pdf.dart';
import 'package:firebase_calendar/models/current_user_data.dart';
import 'package:firebase_calendar/models/qr_scan.dart';
import 'package:firebase_calendar/services/qr_services.dart';
import 'package:firebase_calendar/shared/constants.dart';
import 'package:firebase_calendar/shared/my_provider.dart';
import 'package:firebase_calendar/shared/strings.dart';
import 'package:firebase_calendar/shared/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OrganizationLogs extends StatefulWidget {
  final CurrentUserData currentUserData;

  const OrganizationLogs({Key? key, required this.currentUserData})
      : super(key: key);

  @override
  _OrganizationLogsState createState() => _OrganizationLogsState();
}

class _OrganizationLogsState extends State<OrganizationLogs> {
  QrServices qrServices=QrServices();
  String query = '';
  late CreateQrPdf createQrPdf;
  DateTime logFrom = DateTime(2020);
  DateTime logTo = DateTime.now();
  late Stream<List<QrScan>> getQrLogsForAdmin;


  @override
  void initState() {
    getQrLogsForAdmin=qrServices
        .getQrLogForAdmin(widget.currentUserData.currentOrganizationId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final provider = Provider.of<MyProvider>(context);
    return _buildBody(size, provider);
  }

  List<QrScan> _sortQrLogsByName(List<QrScan> logs) {
    List<QrScan> filteredList = [];
    filteredList = logs
        .where((element) =>
            element.userName.toLowerCase().contains(query.toLowerCase()))
        .toList();
    return filteredList;
  }

  List<QrScan> _filteredLogsByDate(
      List<QrScan> logs, DateTime logsFrom, DateTime logsTo) {
    List<QrScan> filteredList = [];
    logs.forEach((element) {
      if (element.createdAt.isAfter(logsFrom.subtract(Duration(hours: 10))) &&
          element.createdAt.isBefore(logsTo.add(Duration(days: 1)))) {
        filteredList.add(element);
      }
    });
    return filteredList;
  }

  void showSortDialog() {
    final dialog = SortLogsByDateDialog(filterSet: (SelectedDates dates) {
      setState(() {
        logFrom = dates.dateFrom;
        logTo = dates.dateTo;
      });
    });
    showDialog(
        context: context,
        builder: (context) {
          return dialog;
        });
  }

  Widget _buildBody(Size size, MyProvider provider) {
    return Expanded(
      child: StreamBuilder<List<QrScan>>(
          stream: getQrLogsForAdmin,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final list = snapshot.data!;
              final sortedList = _sortQrLogsByName(list);
              final filteredList =
                  _filteredLogsByDate(sortedList, logFrom, logTo);
              if (list.length == 0) {
                return Center(child: Text('Your logs will appear here'.tr()));
              } else {
                createQrPdf = CreateQrPdf(
                    currentUserData: widget.currentUserData,
                    logs: filteredList);
                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: size.width * 0.6,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              decoration: textInputDecoration.copyWith(
                                  fillColor: Constants.CONTAINER_COLOR,
                                  prefixIcon: Icon(
                                    Icons.search,
                                    color: Constants.BACKGROUND_COLOR,
                                  ),
                                  hintText: Strings.SEARCH.tr()),
                              onChanged: (val) {
                                setState(() {
                                  query = val;
                                });
                              },
                            ),
                          ),
                        ),
                        Platform.isIOS?Container():IconButton(
                            onPressed: () {
                              createQrPdf.createPdf();
                            },
                            icon: Icon(Icons.download,
                                color: Constants.CANCEL_COLOR)),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12.0, vertical: 4),
                          child: GestureDetector(
                              onTap: () => showSortDialog(),
                              child: Icon(Icons.filter_alt,
                                  color: Constants.CANCEL_COLOR)),
                        ),
                      ],
                    ),
                    Expanded(
                      child: ListView.builder(
                          itemCount: filteredList.length,
                          itemBuilder: (context, index) {
                            return buildCard(
                                filteredList[index], context, size, provider);
                          }),
                    ),
                  ],
                );
              }
            } else if (snapshot.hasError) {
              return Center(child: Text(snapshot.error.toString()));
            } else
              return Center(child: CircularProgressIndicator());
          }),
    );
  }

  Widget buildCard(
      QrScan qrScan, BuildContext context, Size size, MyProvider provider) {
    final currentUserData = provider.getUserById(qrScan.uid);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        color: Constants.CONTAINER_COLOR,
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10),
              Text(
                qrScan.userName,
                style: appTextStyle.copyWith(
                    fontWeight: FontWeight.bold, fontSize: 18),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Text(Utils.toDateTranslated(qrScan.createdAt, context)),
                  SizedBox(width: 20),
                  Text(Utils.toTime(qrScan.createdAt)),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Text('Log status:'.tr()),
                  SizedBox(
                    width: 20,
                  ),
                  qrScan.logType == 'pending'
                      ? Text('Pending'.tr())
                      : Text(qrScan.logType.tr()),
                ],
              ),
              Row(
                mainAxisAlignment: qrScan.logType == 'pending'
                    ? MainAxisAlignment.end
                    : MainAxisAlignment.spaceBetween,
                children: [
                  if (qrScan.logType != 'pending') ...[
                    qrScan.logType == 'Entry'
                        ? Icon(
                            Icons.login,
                            color: Constants.BUTTON_COLOR,
                          )
                        : Transform.rotate(
                            angle: 180 * math.pi / 180,
                            child: Icon(
                              Icons.logout,
                              color: Constants.CANCEL_COLOR,
                            ))
                  ],
                  ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(50)),
                    child: CachedNetworkImage(
                      fit: BoxFit.cover,
                      width: 40,
                      height: 40,
                      imageUrl: currentUserData.userUrl,
                      placeholder: (context, url) =>
                          new CircularProgressIndicator(),
                      errorWidget: (context, url, error) =>
                          new Icon(Icons.error),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
