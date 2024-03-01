
import 'dart:ui';


import 'package:firebase_calendar/shared/constants.dart';
import 'event.dart' as AppEvent;
import 'package:syncfusion_flutter_calendar/calendar.dart';



class EventDataSource extends CalendarDataSource{

  EventDataSource(List<AppEvent.Event> source){
    this.appointments=source;
  }

  AppEvent.Event getMyEvent(int index)=>appointments![index] as AppEvent.Event;


  @override
  Color getColor(int index)=> Constants.CANCEL_COLOR;

  @override
  String getSubject(int index){
    return getMyEvent(index).eventName;
  }

  @override
  DateTime getEndTime(int index)=> getMyEvent(index).eventEndTime;

  @override
  DateTime getStartTime(int index)=> getMyEvent(index).eventStartTime;

  @override
  String? getNotes(int index)=> getMyEvent(index).eventInformation;


}