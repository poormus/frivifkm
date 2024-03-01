import 'package:firebase_calendar/models/current_user_data.dart';
import 'package:firebase_calendar/models/my_appointment.dart';
import 'package:firebase_calendar/unused/add_edit_appointment.dart';
import 'package:firebase_calendar/services/Firebase_service.dart';
import 'package:firebase_calendar/shared/constants.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class TableCalendarScreen extends StatefulWidget {
  final CurrentUserData currentUserData;
  final String roomId;

  const TableCalendarScreen(
      {Key? key, required this.currentUserData, required this.roomId})
      : super(key: key);

  @override
  _TableCalendarScreenState createState() => _TableCalendarScreenState();
}

class _TableCalendarScreenState extends State<TableCalendarScreen> {
  late final ValueNotifier<List<MyAppointment>> _selectedEvents;

  final calendarService = FireBaseServices();
  late List<MyAppointment> appointments;
  CalendarFormat format = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  final timeFormat = new DateFormat('kk:mm');

  List<MyAppointment> _events(DateTime date) {
    List<MyAppointment> a = [];
    // calendarService.appointments.listen((event) {
    //   for (MyAppointment appointment in event) {
    //     a.add(appointment);
    //   }
    // });
    // print(a.length);
    return a;
  }

  @override
  void initState() {
    _selectedEvents = ValueNotifier(_events(_selectedDay));
    //print(_events(DateTime.now()));
    super.initState();
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(),
      body: StreamBuilder<List<MyAppointment>>(
        stream: calendarService.appointments(widget.roomId),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<MyAppointment> nope(DateTime date) {
              List<MyAppointment> a = [];
              final f = new DateFormat('yyyy-MM-dd');
              snapshot.data!.forEach((element) {
                if (f.format(element.startTime) == f.format(date)) {
                  a.add(element);
                }
              });
              return a;
            }

            return SingleChildScrollView(
              child: Column(children: [
                TableCalendar(
                  eventLoader: nope,
                  focusedDay: _focusedDay,
                  firstDay: DateTime(2020),
                  lastDay: DateTime(2030),
                  calendarFormat: format,
                  onFormatChanged: (CalendarFormat _format) {
                    setState(() {
                      format = _format;
                    });
                  },
                  startingDayOfWeek: StartingDayOfWeek.sunday,
                  daysOfWeekVisible: true,
                  //Day Changed
                  onDaySelected: (DateTime selectDay, DateTime focusDay) {
                    setState(() {
                      _selectedDay = selectDay;
                      _focusedDay = focusDay;
                      _selectedEvents.value = _events(selectDay);
                    });
                  },
                  selectedDayPredicate: (DateTime date) {
                    return isSameDay(_selectedDay, date);
                  },
                  calendarStyle: CalendarStyle(
                    isTodayHighlighted: true,
                    selectedDecoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.rectangle,
                    ),
                    selectedTextStyle: TextStyle(color: Colors.white),
                    todayDecoration: BoxDecoration(
                      color: Colors.purpleAccent,
                      shape: BoxShape.rectangle,
                    ),
                    defaultDecoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                    ),
                    weekendDecoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                    ),
                  ),
                  headerStyle: HeaderStyle(
                    formatButtonVisible: true,
                    titleCentered: true,
                    formatButtonShowsNext: false,
                    formatButtonDecoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    formatButtonTextStyle: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                ...nope(_selectedDay).map((e) => Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                        tileColor: e.color,
                        title: Text(
                          e.subject,
                          style: TextStyle(fontSize: 22),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(e.note ?? ''),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(Icons.access_time),
                                SizedBox(width: 10),
                                Text('from:'),
                                Text('${timeFormat.format(e.startTime)}'),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(Icons.access_time),
                                SizedBox(width: 10),
                                Text('to:'),
                                Text('${timeFormat.format(e.endTime)}'),
                              ],
                            )
                          ],
                        ),
                        isThreeLine: true,
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return AddEditAppointment(
                                appointment: e,
                                roomId: widget.roomId,
                                userData: widget.currentUserData,
                                selectedDay: e.startTime);
                          }));
                        },
                      ),
                    ))
              ]),
            );
          } else if (snapshot.hasError) {
            return noDataWidget(snapshot.error.toString(), false);
          } else {
            return noDataWidget(null, true);
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AddEditAppointment(
                      appointment: null,
                      roomId: widget.roomId,
                      userData: widget.currentUserData,
                      selectedDay: _selectedDay,
                    ))),
        child: Icon(Icons.calendar_today),
      ),
    );
  }
}
