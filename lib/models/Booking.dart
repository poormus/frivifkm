import 'dart:ui';

import 'package:easy_localization/src/public_ext.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import 'my_appointment.dart';

class BookingDataSource extends CalendarDataSource{

  BookingDataSource(List<MyAppointment> source){
    this.appointments=source;
  }

  MyAppointment getMyAppointment(int index)=>appointments![index] as MyAppointment;


  @override
  Color getColor(int index)=> getMyAppointment(index).color;

  @override
  String getSubject(int index){
    if(getMyAppointment(index).isConfirmed==false){
      return 'Pending approval'.tr();
    }else  return getMyAppointment(index).subject;
  }

  @override
  DateTime getEndTime(int index)=> getMyAppointment(index).endTime;

  @override
  DateTime getStartTime(int index)=> getMyAppointment(index).startTime;

  @override
  String? getNotes(int index)=> getMyAppointment(index).note;


}