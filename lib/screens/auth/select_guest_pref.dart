/* import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_calendar/base_scaffolds/base_scaffold.dart';
import 'package:firebase_calendar/components/elevated_button.dart';
import 'package:firebase_calendar/models/event.dart';
import 'package:firebase_calendar/shared/constants.dart';
import 'package:firebase_calendar/shared/my_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../anim/slide_in_right.dart';
import '../../config/key_config.dart';
import '../../shared/utils.dart';
import 'global_events.dart';

class SelectUserPrefs extends StatefulWidget {
  final SharedPreferences preferences;
  final bool? shouldNavigateToEvents;

  const SelectUserPrefs(
      {Key? key, required this.preferences, this.shouldNavigateToEvents})
      : super(key: key);

  @override
  State<SelectUserPrefs> createState() => _SelectUserPrefsState();
}

class _SelectUserPrefsState extends State<SelectUserPrefs> {
  late String selectedCity;
  late List<String> selectedPreferences;
  late MyProvider provider;

  @override
  void initState() {
    provider = Provider.of<MyProvider>(context, listen: false);
    selectedPreferences =
        widget.preferences.getStringList('guestSelectedPreferences') ?? [];
    selectedCity = widget.preferences.getString('guestSelectedCity') ?? '';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      appBarName: 'Preferences'.tr(),
      body: buildBody(),
      shouldScroll: true,
      bottomNav: Container(
          padding: EdgeInsets.only(bottom: 20),
          width: MediaQuery.of(context).size.width,
          height: 50,
          color: Colors.white,
          child: button()),
    );
  }

  Widget buildBody() {
    return SingleChildScrollView(
      child: Column(
        children: [
          ListTile(
            onTap: _handlePressButton,
            title: Text('Select city'.tr()),
            subtitle: Text(selectedCity),
            trailing: Icon(Icons.arrow_drop_down_outlined),
          ),
          widget.shouldNavigateToEvents == null
              ? Container()
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                      child: Text(
                    'You can change your preferences later from setting screen'
                        .tr(),
                    textAlign: TextAlign.center,
                  )),
                ),
          SelectedPreferences(
              selectedPreferences: selectedPreferences,
              onPrefChange: (prefs) {
                selectedPreferences = prefs;
              }),
        ],
      ),
    );
  }

  Future<void> _handlePressButton() async {
    // show input autocomplete with selected mode
    // then get the Prediction selected
    Prediction? p = await PlacesAutocomplete.show(
      offset: 0,
      radius: 1000,
      strictbounds: false,
      region: 'no',
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
      widget.preferences.setDouble('lat', lat);
      widget.preferences.setDouble('lng', lng);
      provider.coordinates = Coordinates(lat: lat, long: lng);
      setState(() {
        selectedCity = detail.result.name;
      });
    }
  }

  Widget buildButton() {
    return ElevatedCustomButton(
        text: "     " + 'Save'.tr() + "     ",
        press: () {
          if (selectedCity == '') {
            Utils.showToastWithoutContext('Please select city'.tr());
            return;
          } else if (selectedPreferences.isEmpty) {
            Utils.showToastWithoutContext(
                'Please select at least one category'.tr());
            return;
          }

          widget.preferences.setString('guestSelectedCity', selectedCity);
          widget.preferences
              .setStringList('guestSelectedPreferences', selectedPreferences);
          widget.preferences.setBool('hasUserSelectedPrefs', true);

          provider.selectedCity = selectedCity;
          provider.selectedPrefs = selectedPreferences;

          if (widget.shouldNavigateToEvents != null) {
            final lat = widget.preferences.getDouble('lat') ?? 0.0;
            final lng = widget.preferences.getDouble('lng') ?? 0.0;
            final guestId = widget.preferences.getString('guestId') ?? '';
            final coordinates = Coordinates(lat: lat, long: lng);
            Navigator.of(context).pop();
            Navigator.push(
                context,
                SlideInRight(GlobalEvents(
                    selectedPrefs: selectedPreferences,
                    coordinates: coordinates,
                    guestId: guestId,
                    area: selectedCity,
                    country: 'no')));
            return;
          }
          Navigator.of(context).pop();
        },
        color: Constants.CANCEL_COLOR);
  }

  Widget button() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        MaterialButton(
          minWidth: MediaQuery.of(context).size.width * 0.5,
          height: 40,
          onPressed: () {
            if (selectedCity == '') {
              Utils.showToastWithoutContext('Please select city'.tr());
              return;
            } else if (selectedPreferences.isEmpty) {
              Utils.showToastWithoutContext(
                  'Please select at least one category'.tr());
              return;
            }

            widget.preferences.setString('guestSelectedCity', selectedCity);
            widget.preferences
                .setStringList('guestSelectedPreferences', selectedPreferences);
            widget.preferences.setBool('hasUserSelectedPrefs', true);

            provider.selectedCity = selectedCity;
            provider.selectedPrefs = selectedPreferences;

            if (widget.shouldNavigateToEvents != null) {
              final lat = widget.preferences.getDouble('lat') ?? 0.0;
              final lng = widget.preferences.getDouble('lng') ?? 0.0;
              final guestId = widget.preferences.getString('guestId') ?? '';
              final coordinates = Coordinates(lat: lat, long: lng);
              Navigator.of(context).pop();
              Navigator.push(
                  context,
                  SlideInRight(GlobalEvents(
                      selectedPrefs: selectedPreferences,
                      coordinates: coordinates,
                      guestId: guestId,
                      area: selectedCity,
                      country: 'no')));
              return;
            }
            Navigator.of(context).pop();
          },
          color: Constants.CANCEL_COLOR,
          child: Text('Save'.tr()),
          textColor: Colors.white,
        ),
      ],
    );
  }
}

class SelectedPreferences extends StatefulWidget {
  final List<String> selectedPreferences;
  final Function(List<String>) onPrefChange;

  const SelectedPreferences(
      {Key? key, required this.selectedPreferences, required this.onPrefChange})
      : super(key: key);

  @override
  State<SelectedPreferences> createState() => _SelectedPreferencesState();
}

class _SelectedPreferencesState extends State<SelectedPreferences> {
  List<String> selectedCategories = [];

  @override
  void initState() {
    widget.selectedPreferences.forEach((element) {
      selectedCategories.add(element);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              GestureDetector(
                onTap: () {
                  if (selectedCategories.length == 0) {
                    selectedCategories.clear();
                    selectedCategories.addAll([
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
                    ]);
                    setState(() {});
                  } else if (selectedCategories.length > 0 &&
                      selectedCategories.length <= 9) {
                    selectedCategories.clear();
                    selectedCategories.addAll([
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
                    ]);
                    setState(() {});
                  } else if (selectedCategories.length == 10) {
                    selectedCategories.clear();
                    setState(() {});
                  } else {
                    selectedCategories.clear();
                    setState(() {});
                  }
                  widget.onPrefChange(selectedCategories);
                },
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                      color: selectedCategories.length == 10
                          ? Constants.BUTTON_COLOR
                          : Constants.BACKGROUND_COLOR,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(5)),
                  child: Center(
                      child: Text(
                    'Select all'.tr(),
                    style: TextStyle(
                        color: selectedCategories.length == 10
                            ? Colors.white
                            : Colors.black),
                  )),
                ),
              ),
              buildContainer('Sports'),
              buildContainer('Outdoor'),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              buildContainer('Culture'),
              buildContainer('Course'),
              buildContainer('Food and drink'),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              buildContainer('Music/Concert'),
              buildContainer('Movie/Theater'),
              buildContainer('Children'),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              buildContainer('Other'),
              buildContainer('Art'),
              Container(
                width: 100,
                height: 100,
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget buildContainer(String name) {
    return GestureDetector(
      onTap: () {
        if (selectedCategories.contains(name)) {
          setState(() {
            selectedCategories.remove(name);
          });
        } else {
          setState(() {
            selectedCategories.add(name);
          });
        }
        widget.onPrefChange(selectedCategories);
      },
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
            color: selectedCategories.contains(name)
                ? Constants.BUTTON_COLOR
                : Constants.BACKGROUND_COLOR,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(5)),
        child: Center(
            child: Text(
          name.tr(),
          style: TextStyle(
              color: selectedCategories.contains(name)
                  ? Colors.white
                  : Colors.black),
        )),
      ),
    );
  }
}
 */