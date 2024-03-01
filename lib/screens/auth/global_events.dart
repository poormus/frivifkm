/* import 'dart:developer';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_calendar/models/event.dart';
import 'package:firebase_calendar/models/external_user.dart';
import 'package:firebase_calendar/screens/auth/global_settings_screen.dart';
import 'package:firebase_calendar/screens/events/event_map.dart';
import 'package:firebase_calendar/services/auth_service.dart';
import 'package:firebase_calendar/services/event_services.dart';
import 'package:firebase_calendar/shared/my_provider.dart';
import 'package:firebase_calendar/shared/navigation.dart';
import 'package:firebase_calendar/shared/no_data_or_progres_widget.dart';
import 'package:firebase_calendar/shared/strings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:provider/provider.dart';
import '../../anim/slide_in_right.dart';
import '../../components/secondary_button.dart';
import '../../config/key_config.dart';
import '../../dialog/bottom_sheet_organization_info.dart';
import '../../dialog/external_user_attend_modal_bottom.dart';
import '../../shared/constants.dart';
import '../../shared/utils.dart';

class GlobalEvents extends StatefulWidget {
  final String? country;
  final String guestId;
  final String? area;
  final Coordinates coordinates;
  final List<String> selectedPrefs;
  const GlobalEvents(
      {Key? key,
      required this.guestId,
      required this.area,
      this.country,
      required this.coordinates,
      required this.selectedPrefs})
      : super(key: key);

  @override
  _GlobalEventsState createState() => _GlobalEventsState();
}

class _GlobalEventsState extends State<GlobalEvents> {
  final eventService = EventServices();
  final auth = AuthService();
  String query = '';
  late String city;
  late String country;
  String category = '';
  bool isCityChanged = true;
  late List<String> selectedPrefs;
  late Coordinates cityCoordinates;
  late List<Event> eventsForMap;
  late MyProvider provider;

  @override
  void initState() {
    city = widget.area ?? '';
    country = widget.country?.toLowerCase() ?? 'no';
    cityCoordinates = widget.coordinates;
    selectedPrefs = widget.selectedPrefs;
    provider = Provider.of<MyProvider>(context, listen: false);
    auth.allOrganizationsList(provider);
    super.initState();
  }

  downloadUrl() async {
    Map<String, Uint8List> byteList = {};
    for (var o in provider.organizationsForValidation) {
      var iconUrl = o.organizationUrl;
      var request = await http.get(Uri.parse(iconUrl));
      var bytes = request.bodyBytes;
      byteList.putIfAbsent(o.organizationId, () => bytes);
    }
    provider.setByteList(byteList);
  }

  List<Event> _sortEventsByCategory(List<Event> events) {
    List<Event> sortedList = [];
    // sortedList = events
    //     .where((element) =>
    //         element.category.toLowerCase().contains(category.toLowerCase()))
    //     .toList();
    sortedList = events
        .where((element) => selectedPrefs.contains(element.category))
        .toList();
    return sortedList;
  }

  List<Event> _sortEventsByName(List<Event> events) {
    List<Event> sortedList = [];
    sortedList = events
        .where((element) =>
            element.eventName.toLowerCase().contains(query.toLowerCase()))
        .toList();
    return sortedList;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final provider = Provider.of<MyProvider>(context);
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Constants.BACKGROUND_COLOR,
        appBar: PreferredSize(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: AppBar(
                leading: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child:
                        Container(child: Image.asset('assets/frivi_logo.png'))),
                actions: [
                  IconButton(
                      icon: Icon(Icons.cancel, color: Constants.BUTTON_COLOR),
                      onPressed: () => Navigator.pop(context)),
                  IconButton(
                      icon: Icon(Icons.settings, color: Constants.BUTTON_COLOR),
                      onPressed: () {
                        Navigator.push(context, SlideInRight(GlobalSettings()))
                            .then((value) => setState(() {
                                  city = provider.selectedCity;
                                  selectedPrefs = provider.selectedPrefs;
                                  cityCoordinates = provider.coordinates;
                                }));
                      }),
                  IconButton(
                      icon: Icon(Icons.place, color: Constants.BUTTON_COLOR),
                      onPressed: () {
                        if (city == '') {
                          Utils.showToastWithoutContext('Select city');
                          return;
                        } else {
                          //downloadUrl();
                          print(eventsForMap);
                          Navigator.push(
                              context,
                              SlideInRight(EventMap(
                                  events: eventsForMap,
                                  coordinate: cityCoordinates,
                                  guestId: widget.guestId)));
                        }
                      }),
                ],
                iconTheme: IconThemeData(color: Colors.black),
                backgroundColor: Constants.BACKGROUND_COLOR,
                centerTitle: false,
                title: Column(
                  children: [
                    Text(
                      'Timeline'.tr(),
                      style: TextStyle(color: Colors.black),
                    ),
                  ],
                ),
                elevation: 0,
              ),
            ),
            preferredSize: Size.fromHeight(80)),
        body: Container(
          height: size.height - 80,
          width: size.width,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10), topRight: Radius.circular(10))),
          child: buildBody(size, provider),
        ),
      ),
    );
  }

  Widget buildBody(Size size, MyProvider provider) {
    return StreamBuilder<List<Event>>(
        initialData: [],
        stream: eventService.getAllEvents(city, provider),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final events =
                _sortEventsByCategory(_sortEventsByName(snapshot.data!));
            eventsForMap = events;
            if (events.length == 0) {
              return Column(
                children: [
                  buildRow(size),
                  buildInfo(),
                  SizedBox(height: size.height * 0.25),
                  Text('No events in your area yet'.tr())
                ],
              );
            } else {
              return Column(
                children: [
                  buildRow(size),
                  buildInfo(),
                  Expanded(
                    child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: events.length,
                        itemBuilder: (context, index) {
                          return buildListTile(
                              events[index], size, context, provider);
                        }),
                  ),
                ],
              );
            }
          } else if (snapshot.hasError) {
            return NoDataWidget(
                info: snapshot.error.toString(), isProgress: false);
          } else {
            return NoDataWidget(info: '', isProgress: true);
          }
        });
  }

  Widget buildInfo() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            children: [
              Text('City:'.tr()),
              SizedBox(width: 20),
              Text(city == '' ? 'Not selected'.tr() : city),
              IconButton(
                  onPressed: () {
                    _handlePressButton();
                  },
                  icon: Icon(Icons.more_vert))
            ],
          )
        ],
      ),
    );
  }

  Widget buildRow(Size size) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextFormField(
          decoration: textInputDecoration.copyWith(
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Constants.BACKGROUND_COLOR, width: 2.0)),
              prefixIcon: Icon(
                Icons.search,
                color: Constants.BACKGROUND_COLOR,
              ),
              hintText: Strings.SEARCH.tr()),
          onFieldSubmitted: (val) {
            isCityChanged = false;
            setState(() {
              query = val;
            });
          },
        ),
      ),
    );
  }

  Widget buildListTile(
      Event event, Size size, BuildContext context, MyProvider provider) {
    return event.eventEndTime.isAfter(DateTime.now())
        ? GestureDetector(
            onTap: () {
              Navigation.navigateToEventDetail(context, '1', event, '',
                  Constants.CURRENT_USER_HOLDER, '', widget.guestId);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
              child: Card(
                color: Constants.CONTAINER_COLOR,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                          child: CachedNetworkImage(
                            fit: BoxFit.cover,
                            width: size.width,
                            height: 200,
                            imageUrl: event.eventUrl,
                            placeholder: (context, url) =>
                                Align(child: new CircularProgressIndicator()),
                            errorWidget: (context, url, error) =>
                                new Icon(Icons.error),
                          )),
                      SizedBox(height: 10),
                      Text(event.eventName,
                          style: appTextStyle.copyWith(
                              fontWeight: FontWeight.bold, fontSize: 22)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(event.category.tr(), style: textStyle),
                          GestureDetector(
                              onTap: () =>
                                  showOrgInfoModalBottom(event.organizationId),
                              child: Container(
                                  width: 150,
                                  child: Center(
                                      child: Text(event.organizationName,
                                          style: textStyle.copyWith(
                                              overflow: TextOverflow.ellipsis,
                                              decoration:
                                                  TextDecoration.underline))))),
                        ],
                      ),
                      Text(Utils.toDateTranslated(event.eventDate, context),
                          style: textStyle),
                      Text(
                        '${Utils.toTime(event.eventStartTime)} - ${Utils.toTime(event.eventEndTime)}',
                        style: textStyle,
                      ),
                      Text(event.eventAddress, style: textStyle),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          CustomTextButton(
                              width: size.width * 0.25,
                              height: 35,
                              text: isAttending(event)
                                  ? 'Attending'.tr()
                                  : 'Attend'.tr(),
                              textColor: isAttending(event)
                                  ? Colors.white
                                  : Constants.BUTTON_COLOR,
                              containerColor: isAttending(event)
                                  ? Constants.BUTTON_COLOR
                                  : Constants.BACKGROUND_COLOR,
                              press: () => isAttending(event)
                                  ? removeAttendStatus(event)
                                  : showModalBottom(event.eventId, provider)),
                          SizedBox(width: 10)
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
        : Container();
  }

  void removeAttendStatus(Event event) {
    log('called');
    eventService.removeAttendStatus(event, widget.guestId);
  }

  bool isAttending(Event event) {
    bool isAttending = false;
    isAttending = event.externalUsers
        .where((element) => element.guestId == widget.guestId)
        .isNotEmpty;
    return isAttending;
  }

  void showOrgInfoModalBottom(String orgId) {
    showModalBottomSheet(
        isScrollControlled: true,
        enableDrag: true,
        context: context,
        builder: (context) {
          return OrganizationInfoModalBottom(orgId: orgId);
        });
  }

  void showModalBottom(String eventId, MyProvider provider) {
    showDialog(
        context: context,
        builder: (context) {
          return Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: ExternalUserAttendEvent(
                guestId: widget.guestId, eventId: eventId),
          );
        });
  }

  Future<void> _handlePressButton() async {
    // show input autocomplete with selected mode
    // then get the Prediction selected
    Prediction? p = await PlacesAutocomplete.show(
      offset: 0,
      radius: 1000,
      strictbounds: false,
      region: country,
      language: "en",
      context: context,
      mode: Mode.overlay,
      apiKey: Configuration.API_KEY,
      components: [new Component(Component.country, "no")],
      types: ["(cities)"],
      hint: "Search City",
      decoration: InputDecoration(
        hintText: 'Search',
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color: Colors.white,
          ),
        ),
      ),
    );
    setState(() {
      category = '';
    });
    displayPrediction(p);
  }

  void onError(PlacesAutocompleteResponse response) {
    Utils.showToast(context, response.toString());
  }

  Future<Null> displayPrediction(Prediction? p) async {
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
      cityCoordinates = Coordinates(lat: lat, long: lng);
      setState(() {
        city = detail.result.name;
        isCityChanged = true;
      });
    }
  }
}
 */