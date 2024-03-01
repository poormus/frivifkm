import 'dart:io';

import 'package:easy_localization/src/public_ext.dart';
import 'package:firebase_calendar/base_scaffolds/base_scaffold.dart';
import 'package:firebase_calendar/components/primary_button.dart';
import 'package:firebase_calendar/components/text_field.dart';
import 'package:firebase_calendar/config/key_config.dart';
import 'package:firebase_calendar/dialog/select_group_for_event.dart';
import 'package:firebase_calendar/dialog/select_image_dialog.dart';
import 'package:firebase_calendar/models/current_user_data.dart';
import 'package:firebase_calendar/models/event.dart';
import 'package:firebase_calendar/services/event_services.dart';
import 'package:firebase_calendar/shared/constants.dart';
import 'package:firebase_calendar/shared/my_provider.dart';
import 'package:firebase_calendar/shared/utils.dart';
import 'package:flutter/material.dart';
// import 'package:googleapis/clouddeploy/v1.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:provider/provider.dart';

import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:google_api_headers/google_api_headers.dart';

class AddEditEventScreen extends StatefulWidget {
  final CurrentUserData currentUserData;
  final String userRole;
  final Event? event;
  final String subLevel;
  const AddEditEventScreen(
      {Key? key,
      required this.currentUserData,
      required this.userRole,
      this.event,
      required this.subLevel})
      : super(key: key);

  @override
  _AddEditEventScreenState createState() => _AddEditEventScreenState();
}

class _AddEditEventScreenState extends State<AddEditEventScreen> {
  late String eventName;
  late DateTime eventDate;
  late DateTime eventStartTime;
  late DateTime eventEndTime;
  late String eventAddress;
  late String eventInformation;
  late List<String> toWho;
  final eventServices = EventServices();
  File? imageFile;
  late ValueNotifier<DateTime> _dateTimeNotifier;
  late bool isPublic;
  final addressController = TextEditingController();
  late String city;
  late String category;
  late Coordinates? coordinates;
  bool isCreating = false;
  List<String> categoryList = [
    'Outdoor',
    'Sports',
    'Art',
    'Culture',
    'Course',
    'Food and drink',
    'Music/Concert',
    'Movie/Theater',
    'Children',
    'Other'
  ];

  @override
  void initState() {
    eventName = widget.event == null ? '' : widget.event!.eventName;
    addressController.text =
        widget.event == null ? '' : widget.event!.eventAddress;
    eventInformation =
        widget.event == null ? '' : widget.event!.eventInformation;
    eventDate = widget.event == null ? DateTime.now() : widget.event!.eventDate;
    eventStartTime =
        widget.event == null ? DateTime.now() : widget.event!.eventStartTime;
    eventEndTime = widget.event == null
        ? DateTime.now().add(const Duration(hours: 1))
        : widget.event!.eventEndTime;
    toWho = widget.event == null ? [] : widget.event!.toWho;
    _dateTimeNotifier = ValueNotifier<DateTime>(eventDate);
    isPublic = widget.event == null ? false : widget.event!.isPublic;
    city = widget.event == null ? '' : widget.event!.city;
    coordinates = widget.event == null
        ? Coordinates(lat: 0.0, long: 0.0)
        : widget.event!.coordinates;
    category = widget.event == null
        ? 'Outdoor'
        : categoryList.singleWhere(
            (element) => element == widget.event!.category,
            orElse: () => 'Outdoor');
    super.initState();
  }

  showSelectImageSourceDialog() {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return SelectImageSourceDialog(
              selectedImage: (onImageSelected onSelected) async {
            setState(() {
              imageFile = onSelected.imageFile!;
            });
          });
        }).then((value) => null);
  }

  showGroupListDialog() {
    toWho = [];
    showDialog(
        barrierDismissible: true,
        context: context,
        builder: (_) {
          return SelectUserForGroupDialog(groupList: (SelectGroup group) {
            setState(() {
              toWho = group.groupDataList;
            });
          });
        }).then((value) => null);
  }

  Future addOrUpdateEvent() async {
    final newEventStartTime = DateTime(eventDate.year, eventDate.month,
        eventDate.day, eventStartTime.hour, eventStartTime.minute);
    final newEventEndTime = DateTime(eventDate.year, eventDate.month,
        eventDate.day, eventEndTime.hour, eventEndTime.minute);
    final String orgName = Utils.getOrgNameAndImage(
        widget.currentUserData.currentOrganizationId,
        widget.currentUserData.userOrganizations)[0];

    if (true) {
      if (newEventStartTime.isBefore(DateTime.now())) {
        Utils.showSnackBar(context, 'Can not create event in the past'.tr());
        return;
      }
    }
    eventAddress = addressController.text.toString();

    if (widget.event == null) {
      if (Utils.validateAddEvent(
          imageFile,
          eventName,
          eventAddress,
          eventInformation,
          toWho,
          newEventStartTime,
          newEventEndTime,
          eventDate,
          context)) {
        if (isPublic) {
          if (city == '') {
            Utils.showToastWithoutContext('Select a city'.tr());
            return;
          } else if (category == '') {
            Utils.showToastWithoutContext('Select a category'.tr());
            return;
          }
        }
        setState(() {
          isCreating = true;
        });
        await eventServices
            .createEvent(
                widget.currentUserData.currentOrganizationId,
                widget.currentUserData.uid,
                eventName,
                eventDate,
                newEventStartTime,
                newEventEndTime,
                imageFile!,
                eventAddress,
                eventInformation,
                toWho,
                isPublic,
                context,
                orgName,
                category,
                city,
                coordinates)
            .catchError((err) => Utils.showToast(context, err.toString()));
      }
    } else {
      if (Utils.validateEventForUpdate(
          eventName,
          eventAddress,
          eventInformation,
          toWho,
          newEventStartTime,
          newEventEndTime,
          eventDate,
          context)) {
        if (isPublic) {
          if (city == '') {
            Utils.showToastWithoutContext('Select a city'.tr());
            return;
          } else if (category == '') {
            Utils.showToastWithoutContext('Select a category'.tr());
            return;
          }
        }
        setState(() {
          isCreating = true;
        });
        await eventServices
            .updateEvent(
                widget.event!.eventId,
                eventName,
                eventDate,
                newEventStartTime,
                newEventEndTime,
                imageFile,
                widget.event!.eventUrl,
                eventAddress,
                eventInformation,
                toWho,
                isPublic,
                context,
                city,
                category,
                coordinates)
            .catchError((err) => Utils.showToast(context, err.toString()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MyProvider>(context);
    final size = MediaQuery.of(context).size;
    return BaseScaffold(
        appBarName: 'Add/Edit Event'.tr(),
        body: buildBody(size, provider),
        shouldScroll: true);
  }

  Widget buildBody(Size size, MyProvider provider) {
    final bool isPremium =
        widget.subLevel != 'freemium' || widget.subLevel != '';
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 10),
          Stack(
            children: [
              Container(
                width: size.width * 0.85,
                height: 150,
                decoration: BoxDecoration(
                  image: DecorationImage(
                      fit: BoxFit.cover,
                      image: widget.event == null
                          ? (imageFile != null
                              ? FileImage(imageFile!)
                              : AssetImage('assets/background_holder.png')
                                  as ImageProvider)
                          : (imageFile != null)
                              ? FileImage(imageFile!)
                              : NetworkImage(widget.event!.eventUrl)
                                  as ImageProvider),
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                ),
              ),
              Positioned(
                  right: 5,
                  bottom: 5,
                  child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Constants.BUTTON_COLOR,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: showSelectImageSourceDialog,
                        icon: Icon(
                          Icons.edit,
                          color: Constants.BACKGROUND_COLOR,
                        ),
                      ))),
            ],
          ),
          SizedBox(height: 10),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 25),
            decoration: new BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Constants.CONTAINER_COLOR),
            child: ListTile(
              onTap: () {
                showGroupListDialog();
              },
              leading: Text('Select group'.tr()),
              trailing: Icon(Icons.arrow_drop_down),
            ),
          ),
          buildTargetList(provider),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 25.0, right: 25.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Stack(
                  children: [
                    Container(
                      width: size.width * 0.4,
                      height: size.height * 0.15,
                      decoration: BoxDecoration(
                          color: Constants.CONTAINER_COLOR,
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    Container(
                        padding: EdgeInsets.only(left: 8, right: 8),
                        width: size.width * 0.4,
                        child: TextFieldInput(
                          maxLength: 30,
                          hintText: 'Event name'.tr(),
                          onChangeValue: (s) => eventName = s,
                          isDone: true,
                          shouldObscureText: false,
                          initialValue: eventName,
                        )),
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Text(
                              'Name'.tr(),
                              style: textStyle,
                            )),
                      ),
                    )
                  ],
                ),
                Stack(
                  children: [
                    Container(
                      width: size.width * 0.4,
                      height: size.height * 0.15,
                      decoration: BoxDecoration(
                          color: Constants.CONTAINER_COLOR,
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    Container(
                        padding: EdgeInsets.only(left: 8, top: 12),
                        width: size.width * 0.4,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(Utils.toDateTranslated(eventDate, context)
                                .substring(4)),
                            IconButton(
                              onPressed: () {
                                pickDate(pickDate: true);
                              },
                              icon: Icon(Icons.arrow_drop_down),
                            ),
                          ],
                        )),
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Text(
                              'Date'.tr(),
                              style: textStyle,
                            )),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 25.0, right: 25.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Stack(
                  children: [
                    Container(
                      width: size.width * 0.4,
                      height: size.height * 0.15,
                      decoration: BoxDecoration(
                          color: Constants.CONTAINER_COLOR,
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    Container(
                        padding: EdgeInsets.only(left: 10, top: 15),
                        width: size.width * 0.4,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Column(
                              children: [
                                Text(
                                  Utils.toTime(eventStartTime),
                                  style: appTextStyle,
                                ),
                                IconButton(
                                  onPressed: () {
                                    pickFromDateTime(pickDate: false);
                                  },
                                  icon: Icon(Icons.arrow_drop_down),
                                ),
                              ],
                            ),
                            Text('       '),
                            Column(
                              children: [
                                Text(
                                  Utils.toTime(eventEndTime),
                                  style: appTextStyle,
                                ),
                                IconButton(
                                  onPressed: () {
                                    pickToDateTime(pickDate: false);
                                  },
                                  icon: Icon(Icons.arrow_drop_down),
                                ),
                              ],
                            ),
                          ],
                        )),
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Text(
                              'Time'.tr(),
                              style: textStyle,
                            )),
                      ),
                    )
                  ],
                ),
                Stack(
                  children: [
                    Container(
                      width: size.width * 0.4,
                      height: size.height * 0.15,
                      decoration: BoxDecoration(
                          color: Constants.CONTAINER_COLOR,
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    Container(
                        padding: EdgeInsets.only(left: 8, right: 8),
                        width: size.width * 0.4,
                        child: TextFieldInput(
                          onTap: () => _handlePressButton(true),
                          maxLength: 30,
                          hintText: 'Address'.tr(),
                          onChangeValue: (s) => eventAddress = s,
                          isDone: true,
                          shouldObscureText: false,
                          controller: addressController,
                        )),
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Text(
                              'Address'.tr(),
                              style: textStyle,
                            )),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          Container(
            width: size.width * 0.85,
            decoration: BoxDecoration(
              color: Constants.CONTAINER_COLOR,
              borderRadius: BorderRadius.all(Radius.circular(5)),
            ),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  width: size.width * 0.8,
                  child: TextFormField(
                    minLines: 1,
                    maxLines: 5,
                    initialValue: eventInformation,
                    textInputAction: TextInputAction.newline,
                    decoration: InputDecoration(
                        hintText: 'Information'.tr(),
                        border: UnderlineInputBorder()),
                    onChanged: (s) => eventInformation = s,
                  ),
                ),
                Container(
                    child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Text(
                        'Information'.tr(),
                        style: textStyle,
                      )),
                )),
              ],
            ),
          ),
          SizedBox(height: 10),
          if (isPremium) buildPublicOptions(size),
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                isCreating
                    ? CircularProgressIndicator()
                    : PrimaryButton(
                        text: widget.event == null
                            ? 'Save Event'.tr()
                            : 'Update Event'.tr(),
                        press: addOrUpdateEvent,
                        color: Constants.BUTTON_COLOR),
              ],
            ),
          ),
          SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }

  Widget buildPublicOptions(Size size) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Constants.CONTAINER_COLOR),
          width: size.width * 0.85,
          child: ListTile(
            leading: Checkbox(
              activeColor: Constants.CANCEL_COLOR,
              value: isPublic,
              onChanged: (bool? value) {
                setState(() {
                  isPublic = value!;
                });
              },
            ),
            title: Text('Make this event public'.tr()),
          ),
        ),
        SizedBox(height: 8),
        if (isPublic) ...[
          buildCategory(size),
          SizedBox(height: 5),
          buildCityTile(size)
        ]
      ],
    );
  }

  Widget buildCategory(Size size) {
    return Container(
      width: size.width * 0.85,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Constants.CONTAINER_COLOR),
      child: DropdownButtonFormField(
          value: category,
          decoration:
              dropDownDecoration.copyWith(fillColor: Constants.CONTAINER_COLOR),
          items: categoryList.map((cat) {
            return DropdownMenuItem(value: cat, child: Text(cat.tr()));
          }).toList(),
          onChanged: (val) => category = val.toString()),
    );
  }

  Widget buildCityTile(Size size) {
    return Container(
      width: size.width * 0.85,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Constants.CONTAINER_COLOR),
      child: ListTile(
        title: Text(city == '' ? 'Select city'.tr() : city),
        trailing: Icon(Icons.arrow_drop_down_outlined),
        onTap: () => _handlePressButton(false),
      ),
    );
  }

  Widget buildTargetList(MyProvider provider) {
    return toWho.isEmpty
        ? Container()
        : Container(
            height: 50,
            margin: EdgeInsets.symmetric(horizontal: 22, vertical: 5),
            decoration: new BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Constants.CONTAINER_COLOR),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: toWho.length,
              itemBuilder: (context, index) {
                return buildTile(toWho[index], provider);
              },
            ),
          );
  }

  Widget buildTile(String id, MyProvider provider) {
    String text = '';
    if (id == '1' || id == '2' || id == '3') {
      switch (id) {
        case '1':
          text = 'Guests'.tr();
          break;

        case '2':
          text = 'Members'.tr();
          break;

        case '3':
          text = 'Leaders'.tr();
          break;
      }
    } else {
      text = provider.getGroupNameById(id);
    }
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(text),
            IconButton(
                onPressed: () {
                  setState(() {
                    toWho.remove(id);
                  });
                },
                icon: Icon(
                  Icons.cancel,
                  color: Constants.CANCEL_COLOR,
                  size: 20,
                ))
          ],
        ),
      ),
    );
  }

  Future pickDate({required bool pickDate}) async {
    final date =
        await pickDateTime(_dateTimeNotifier.value, pickDate: pickDate);
    if (date == null) return;
    setState(() {
      eventDate = date;
    });
  }

  Future pickFromDateTime({required bool pickDate}) async {
    final date = await pickDateTime(eventStartTime, pickDate: pickDate);
    if (date == null) return;
    setState(() {
      eventStartTime = date;
    });
  }

  Future pickToDateTime({required bool pickDate}) async {
    final date = await pickDateTime(eventEndTime, pickDate: pickDate);
    if (date == null) return;
    setState(() {
      eventEndTime = date;
    });
  }

  Future<DateTime?> pickDateTime(DateTime initialDate,
      {required bool pickDate, DateTime? firstDate}) async {
    if (pickDate) {
      final date = await showDatePicker(
          context: context,
          initialDate: initialDate,
          firstDate: firstDate ?? DateTime.now(),
          lastDate: DateTime(2101));
      if (date == null) return null;
      final time = Duration(hours: eventDate.hour, minutes: eventDate.minute);
      return date.add(time);
    } else {
      final timeOfDay = await showTimePicker(
          context: context, initialTime: TimeOfDay.fromDateTime(eventDate));
      if (timeOfDay == null) return null;
      final date =
          DateTime(initialDate.year, initialDate.month, initialDate.day);
      final time = Duration(hours: timeOfDay.hour, minutes: timeOfDay.minute);
      return date.add(time);
    }
  }

  Future<void> _handlePressButton(bool isAddress) async {
    // show input autocomplete with selected mode
    // then get the Prediction selected
    Prediction? p = await PlacesAutocomplete.show(
      offset: 0,
      radius: 1000,
      strictbounds: false,
      region: "no",
      language: "en",
      context: context,
      mode: Mode.overlay,
      apiKey: Configuration.API_KEY,
      components: [new Component(Component.country, "no")],
      types: isAddress ? [] : ["(cities)"],
      hint: "Search City",
      decoration: InputDecoration(
        hintText: 'Search'.tr(),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color: Colors.white,
          ),
        ),
      ),
    );
    displayPrediction(p, isAddress);
  }

  void onError(PlacesAutocompleteResponse response) {
    Utils.showToast(context, response.toString());
  }

  Future<Null> displayPrediction(Prediction? p, bool isAddress) async {
    if (p != null) {
      // get detail (lat/lng)
      GoogleMapsPlaces _places = GoogleMapsPlaces(
        apiKey: Configuration.API_KEY,
        apiHeaders: await GoogleApiHeaders().getHeaders(),
      );
      PlacesDetailsResponse detail =
          await _places.getDetailsByPlaceId(p.placeId!);
      final lat = detail.result.geometry!.location.lat;
      final lng = detail.result.geometry!.location.lng;
      print(lat);
      print(lng);

      if (isAddress) {
        coordinates = Coordinates(lat: lat, long: lng);
        setState(() {
          addressController.text = detail.result.name;
        });
      } else {
        setState(() {
          city = detail.result.name;
        });
      }
    }
  }
}
