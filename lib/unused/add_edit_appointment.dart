import 'package:firebase_calendar/components/primary_button.dart';
import 'package:firebase_calendar/models/current_user_data.dart';
import 'package:firebase_calendar/models/my_appointment.dart';
import 'package:firebase_calendar/services/Firebase_service.dart';
import 'package:firebase_calendar/shared/constants.dart';
import 'package:firebase_calendar/shared/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

///calendar import
import 'package:syncfusion_flutter_calendar/calendar.dart';

class AddEditAppointment extends StatefulWidget {
  final MyAppointment? appointment;
  final String roomId;
  final CurrentUserData userData;
  final DateTime selectedDay;

  const AddEditAppointment(
      {Key? key,
      required this.appointment,
      required this.roomId,
      required this.userData,
      required this.selectedDay})
      : super(key: key);

  @override
  _AddEditAppointmentState createState() => _AddEditAppointmentState();
}

class _AddEditAppointmentState extends State<AddEditAppointment> {
  final _formKey = GlobalKey<FormState>();
  late String _subject;
  late String? _notes;
  late DateTime _startDate;
  late DateTime _endDate;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  int _selectedColorIndex = 0;
  late Color currentColor;

  @override
  void initState() {
    _startDate = widget.appointment == null
        ? widget.selectedDay
        : widget.appointment!.startTime;
    _endDate = widget.appointment == null
        ? DateTime.now().add(Duration(hours: 1))
        : widget.appointment!.endTime;
    currentColor =
        widget.appointment == null ? Colors.green : widget.appointment!.color;
    _subject = widget.appointment == null ? "" : widget.appointment!.subject;
    _notes = widget.appointment == null ? "" : widget.appointment!.note;
    if (widget.appointment != null) {
      setSelectedIndex();
    }
    super.initState();
  }

  void setSelectedIndex() {
    if (widget.appointment!.color == Color(0xFF0F8644)) {
      _selectedColorIndex = 0;
    } else if (widget.appointment!.color == Color(0xFF8B1FA9)) {
      _selectedColorIndex = 1;
    } else if (widget.appointment!.color == Color(0xFFD20100)) {
      _selectedColorIndex = 2;
    } else if (widget.appointment!.color == Color(0xFFFC571D)) {
      _selectedColorIndex = 3;
    } else if (widget.appointment!.color == Color(0xFF85461E)) {
      _selectedColorIndex = 4;
    } else if (widget.appointment!.color == Color(0xFF36B37B)) {
      _selectedColorIndex = 5;
    } else if (widget.appointment!.color == Color(0xFF3D4FB5)) {
      _selectedColorIndex = 6;
    } else if (widget.appointment!.color == Color(0xFFE47C73)) {
      _selectedColorIndex = 7;
    } else if (widget.appointment!.color == Color(0xFF636363)) {
      _selectedColorIndex = 8;
    }
  }

  Future addBooking() async {
    String roomId = widget.roomId;
    String organizationId = widget.userData.currentOrganizationId;
    String userId = widget.userData.uid;
    if (_formKey.currentState!.validate()) {
      await FireBaseServices().addBooking(_startDate, _endDate, _subject,
          currentColor, roomId, organizationId, userId, _notes, '', '');
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(
              Icons.close,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: <Widget>[
            if (widget.appointment == null) ...[
              IconButton(
                  padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                  icon: const Icon(
                    Icons.done,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    addBooking();
                  })
            ] else
              ...[]
          ],
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(12.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: _subject,
                  style: TextStyle(fontSize: 24.0),
                  decoration: InputDecoration(
                      hintText: "Add title", border: UnderlineInputBorder()),
                  validator: (title) => title != null && title.isEmpty
                      ? 'title can not be empty'
                      : null,
                  onChanged: (val) => setState(() {
                    _subject = val;
                  }),
                ),
                SizedBox(height: 12),
                buildDateTimePickers()
              ],
            ),
          ),
        ));
  }

  Column buildDateTimePickers() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Date:'),
        ListTile(
          title: Text(Utils.toDate(
              widget.appointment == null ? widget.selectedDay : _startDate)),
          trailing: Icon(Icons.calendar_today),
          onTap: () {
            //pickFromDateTime(pickDate: true);
          },
        ),
        ListTile(title: Text('from'), trailing: Text('to')),
        Padding(
          padding: EdgeInsets.only(left: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(Utils.toTime(_startDate)),
                  IconButton(
                      onPressed: () {
                        pickFromDateTime(pickDate: false);
                      },
                      icon: Icon(Icons.arrow_drop_down))
                ],
              ),
              Row(
                children: [
                  Text(Utils.toTime(_endDate)),
                  IconButton(
                      onPressed: () {
                        pickToDateTime(pickDate: false);
                      },
                      icon: Icon(Icons.arrow_drop_down))
                ],
              )
            ],
          ),
        ),
        Divider(
          height: 1.0,
          thickness: 1,
        ),
        SizedBox(height: 10),
        Text('Color'),
        Container(
            margin: const EdgeInsets.only(bottom: 5),
            height: 50,
            child: ListTile(
              leading: Container(
                  width: 30,
                  alignment: Alignment.centerRight,
                  child: Icon(Icons.lens, size: 20, color: currentColor)),
              title: RawMaterialButton(
                padding: const EdgeInsets.only(left: 5),
                onPressed: () {
                  showDialog<Widget>(
                    context: context,
                    barrierDismissible: true,
                    builder: (BuildContext context) {
                      return _CalendarColorPicker(
                        Constants.colorCollection,
                        _selectedColorIndex,
                        Constants.colorNames,
                        onChanged: (_PickerChangedDetails details) {
                          _selectedColorIndex = details.index;
                        },
                      );
                    },
                  ).then((dynamic value) => setState(() {
                        /// update the color picker changes
                        currentColor =
                            Constants.colorCollection[_selectedColorIndex];
                      }));
                },
                child: Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    Constants.colorNames[_selectedColorIndex],
                    style: TextStyle(
                        fontWeight: FontWeight.w500, color: Colors.black),
                    textAlign: TextAlign.start,
                  ),
                ),
              ),
            )),
        Divider(
          height: 1.0,
          thickness: 1,
        ),
        ListTile(
          contentPadding: const EdgeInsets.all(5),
          leading: Icon(
            Icons.subject,
          ),
          title: TextFormField(
            initialValue: _notes,
            onChanged: (String value) {
              _notes = value;
            },
            keyboardType: TextInputType.multiline,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Add note',
            ),
          ),
        ),
        SizedBox(height: 5),
        if (widget.appointment != null) ...[]
      ],
    );
  }

  Future updateBooking() async {}

  Future deleteBooking() async {}

  Future pickFromDateTime({required bool pickDate}) async {
    final date = await pickDateTime(_startDate, pickDate: pickDate);
    if (date == null) return;
    setState(() {
      _startDate = date;
    });
  }

  Future pickToDateTime({required bool pickDate}) async {
    final date = await pickDateTime(_endDate, pickDate: pickDate);
    if (date == null) return;
    setState(() {
      _endDate = date;
    });
  }

  Future<DateTime?> pickDateTime(DateTime initialDate,
      {required bool pickDate, DateTime? firstDate}) async {
    if (pickDate) {
      final date = await showDatePicker(
          context: context,
          initialDate: initialDate,
          firstDate: firstDate ?? DateTime(2015, 8),
          lastDate: DateTime(2101));
      if (date == null) return null;
      final time = Duration(hours: _startDate.hour, minutes: _startDate.minute);
      return date.add(time);
    } else {
      final timeOfDay = await showTimePicker(
          context: context, initialTime: TimeOfDay.fromDateTime(initialDate));
      if (timeOfDay == null) return null;
      final date =
          DateTime(initialDate.year, initialDate.month, initialDate.day);
      final time = Duration(hours: timeOfDay.hour, minutes: timeOfDay.minute);
      return date.add(time);
    }
  }
}

class _CalendarColorPicker extends StatefulWidget {
  const _CalendarColorPicker(
      this.colorCollection, this.selectedColorIndex, this.colorNames,
      {required this.onChanged});

  final List<Color> colorCollection;

  final int selectedColorIndex;

  final List<String> colorNames;

  final _PickerChanged onChanged;

  @override
  State<StatefulWidget> createState() => _CalendarColorPickerState();
}

class _CalendarColorPickerState extends State<_CalendarColorPicker> {
  int _selectedColorIndex = -1;

  @override
  void initState() {
    _selectedColorIndex = widget.selectedColorIndex;
    super.initState();
  }

  @override
  void didUpdateWidget(_CalendarColorPicker oldWidget) {
    _selectedColorIndex = widget.selectedColorIndex;
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.light(),
      child: AlertDialog(
        content: Container(
            width: double.maxFinite,
            height: (widget.colorCollection.length * 50).toDouble(),
            child: ListView.builder(
              padding: const EdgeInsets.all(0),
              itemCount: widget.colorCollection.length,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                    height: 50,
                    child: ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 10),
                      leading: Icon(
                          index == _selectedColorIndex
                              ? Icons.lens
                              : Icons.trip_origin,
                          color: widget.colorCollection[index]),
                      title: Text(widget.colorNames[index]),
                      onTap: () {
                        setState(() {
                          _selectedColorIndex = index;
                          widget.onChanged(_PickerChangedDetails(index: index));
                        });
                        // ignore: always_specify_types
                        Future.delayed(const Duration(milliseconds: 200), () {
                          // When task is over, close the dialog
                          Navigator.pop(context);
                        });
                      },
                    ));
              },
            )),
      ),
    );
  }
}

/// Signature for callback which reports the picker value changed
typedef _PickerChanged = void Function(
    _PickerChangedDetails pickerChangedDetails);

/// Details for the [_PickerChanged].
class _PickerChangedDetails {
  _PickerChangedDetails({this.index = -1, this.resourceId});

  final int index;
  final Object? resourceId;
}
