import 'package:easy_localization/src/public_ext.dart';
import 'package:firebase_calendar/anim/slide_in_right.dart';
import 'package:firebase_calendar/models/current_user_data.dart';
import 'package:firebase_calendar/models/my_appointment.dart';
import 'package:firebase_calendar/screens/rooms_screen/add_edit_appointment_sync_fusion.dart';
import 'package:firebase_calendar/services/Firebase_service.dart';
import 'package:firebase_calendar/shared/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../../models/Booking.dart';
import '../../shared/constants.dart';

class BookingCalendar extends StatefulWidget {

  final String roomId;
  final CurrentUserData userData;
  final String roomName;

  const BookingCalendar(
      {Key? key, required this.roomId, required this.userData, required this.roomName})
      : super(key: key);

  @override
  _BookingCalendarState createState() => _BookingCalendarState();
}

class _BookingCalendarState extends State<BookingCalendar> {

  MyAppointment? _selectedAppointment;
  CalendarView _view = CalendarView.month;
  late List<MyAppointment> allAppointments;
  final service = FireBaseServices();
  late BookingDataSource dataSource;
  final CalendarController calendarController = CalendarController();
  final currentView = CalendarView.month;
  late Stream<List<MyAppointment>> appointments;

  @override
  void initState() {
    _selectedAppointment = null;
    calendarController.view = _view;
    appointments=service.appointments(widget.roomId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size=MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Constants.BACKGROUND_COLOR,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: AppBar(
            leading: BackButton(color: Colors.black),
            title: Text(widget.roomName,style: TextStyle(color: Colors.black)),
            elevation: 0,
            backgroundColor: Constants.BACKGROUND_COLOR,
            centerTitle: true,
            actions: [
              IconButton(onPressed: _onCalendarIconTap, icon: Icon(Icons.calendar_today,color: Constants.BUTTON_COLOR))
            ],
          ),
        ),
      ),
      body: Container(
        height: size.height - 80,
        width: size.width,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10), topRight: Radius.circular(10))),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: StreamBuilder<List<MyAppointment>>(
              stream: appointments,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final bookings=snapshot.data!;
                  bookings.removeWhere((element) => element.endTime.isBefore(DateTime.now()) && element.isConfirmed==false);
                  dataSource = BookingDataSource(bookings);
                  return SfCalendar(
                    onTap: _onCalendarTapped,
                    onViewChanged: _onViewChanged,
                    controller: calendarController,
                    dataSource: dataSource,
                    initialSelectedDate: DateTime.now(),
                  );
                } else
                  return Center(child: CircularProgressIndicator());
              }),
        ),
      ),
    );
  }

  void _onCalendarIconTap(){
    if (calendarController.view == CalendarView.day) {
      calendarController.view = CalendarView.month;
    }
  }

  void _onCalendarTapped(CalendarTapDetails calendarTapDetails) {
    if (calendarTapDetails.targetElement == CalendarElement.header ||
        calendarTapDetails.targetElement == CalendarElement.resourceHeader) {
      return;
    }
    _selectedAppointment = null;
    if (calendarController.view == CalendarView.month) {
      calendarController.view = CalendarView.day;
    } else {
      if (calendarTapDetails.appointments != null &&
          calendarTapDetails.targetElement == CalendarElement.appointment) {
        final dynamic appointment = calendarTapDetails.appointments![0];
        if (appointment is MyAppointment) {
          _selectedAppointment = appointment;
        }
      }

      final DateTime selectedDate = calendarTapDetails.date!;
      final CalendarElement targetElement = calendarTapDetails.targetElement;

      if (_selectedAppointment == null) {
        final DateTime date = calendarTapDetails.date!;
        final color = Constants.colorCollection[0];
        final newAppointment = MyAppointment(
            userId: widget.userData.uid,
            organizationId: widget.userData.currentOrganizationId,
            roomName: widget.roomName,
            appointmentId: "",
            roomId: widget.roomId,
            isConfirmed: false,
            startTime: date,
            endTime: date.add(const Duration(hours: 1)),
            color: color,
            subject: '',
            note: '',
            userName: '${widget.userData.userName} ${widget.userData.userSurname}',
            isActive: false
        );
        Navigator.push(context,SlideInRight(AddEditAppointment(
          appointment: newAppointment,
          roomId: widget.roomId,
          userData: widget.userData,
        )));
      } else {
       if(widget.userData.uid==_selectedAppointment!.userId){
         Navigator.push(context,SlideInRight(AddEditAppointment(
           appointment: _selectedAppointment!,
           roomId: widget.roomId,
           userData: widget.userData,
         )));
       }else{
         Utils.showToast(context, 'This is not your booking'.tr());
       }
      }
    }
  }

  void _onViewChanged(ViewChangedDetails visibleDatesChangedDetails) {
    if (_view == calendarController.view ||
        (_view != CalendarView.month &&
            calendarController.view != CalendarView.month)) {
      return;
    }
    SchedulerBinding.instance.addPostFrameCallback((Duration timeStamp) {
      setState(() {
        _view = calendarController.view!;

        /// Update the current view when the calendar view changed to
        /// month view or from month view.
      });
    });
  }
}
