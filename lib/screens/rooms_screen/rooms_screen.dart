import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:firebase_calendar/components/elevated_button.dart';
import 'package:firebase_calendar/models/current_user_data.dart';
import 'package:firebase_calendar/models/room.dart';
import 'package:firebase_calendar/screens/rooms_screen/amenities_list.dart';
import 'package:firebase_calendar/services/Firebase_service.dart';
import 'package:firebase_calendar/shared/constants.dart';
import 'package:firebase_calendar/shared/navigation.dart';
import 'package:firebase_calendar/shared/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'booking_calendar.dart';

class RoomsScreen extends StatefulWidget {
  final CurrentUserData currentUserData;
  final String userRole;

  const RoomsScreen(
      {Key? key, required this.currentUserData, required this.userRole})
      : super(key: key);

  @override
  State<RoomsScreen> createState() => _RoomsScreenState();
}

class _RoomsScreenState extends State<RoomsScreen> {
  final service = FireBaseServices();
  bool isFabVisible = true;
  String currentViewType = 'list';
  String query = '';
  late Stream<List<Room>> getAllRoomsOfOrganization;


  List<Room> _sortRooms(List<Room> rooms){
    List<Room> sortedList=[];
    sortedList = rooms
        .where((element) => element.roomName
        .toLowerCase()
        .contains(query.toLowerCase()))
        .toList();
    return sortedList;
  }

  @override
  void initState() {
   getAllRoomsOfOrganization=service.getAllRooms(widget.currentUserData.currentOrganizationId);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return buildBody(size);
  }

  Widget buildBody(Size size) {
    return Expanded(
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          body: StreamBuilder<List<Room>>(
            stream: getAllRoomsOfOrganization,
            builder: (context, snapshots) {
              if (snapshots.hasData) {
                final rooms = snapshots.data!;
                if (rooms.length == 0) {
                  return noDataWidget('No data found'.tr(), false);
                } else {
                  final sortedList=_sortRooms(rooms);
                  return NotificationListener<UserScrollNotification>(
                    onNotification: (notification) {
                      if (notification.direction == ScrollDirection.forward) {
                        if (!isFabVisible) setState(() => isFabVisible = true);
                      } else if (notification.direction ==
                          ScrollDirection.reverse) {
                        if (isFabVisible) setState(() => isFabVisible = false);
                      }
                      return true;
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: size.width * 0.8,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                  decoration: textInputDecoration.copyWith(
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
                            IconButton(
                              onPressed: () {
                                if (currentViewType == 'list') {
                                  setState(() {
                                    currentViewType = 'grid';
                                  });
                                } else if (currentViewType == 'grid') {
                                  setState(() {
                                    currentViewType = 'list';
                                  });
                                }
                              },
                              icon: Icon(
                                currentViewType == 'grid'
                                    ? Icons.list
                                    : Icons.grid_on,
                                size: 40,
                                color: Constants.BUTTON_COLOR,
                              ),
                            )
                          ],
                        ),
                        Expanded(
                          child: currentViewType == 'list'
                              ? ListView.builder(
                                  scrollDirection: Axis.vertical,
                                  shrinkWrap: true,
                                  itemCount: sortedList.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    return buildRoomCard(sortedList[index]);
                                  },
                                )
                              : GridView.builder(
                                  itemCount: sortedList.length,
                                  gridDelegate:const SliverGridDelegateWithMaxCrossAxisExtent(
                                          maxCrossAxisExtent: 200,
                                          childAspectRatio: 0.92,
                                          crossAxisSpacing: 15,
                                          mainAxisSpacing: 10),
                                  itemBuilder: (_, index) {
                                    return buildRoomCardGrid(sortedList[index]);
                                  }),
                        ),
                      ],
                    ),
                  );
                }
              } else if (snapshots.hasError) {
                return noDataWidget(snapshots.error.toString(), false);
              } else
                return noDataWidget(null, true);
            },
          ),
          floatingActionButton: buildFab(),
        ),
      ),
    );
  }

  Widget buildRoomCard(Room room) {
    return GestureDetector(
      onTap: () {
        Navigation.navigateToViewRoomScreen(context, room,
            widget.currentUserData.currentOrganizationId, widget.userRole,widget.currentUserData);
      },
      child: Card(
        color: Constants.CARD_COLOR,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                  child: CachedNetworkImage(
                    fit: BoxFit.cover,
                    width: MediaQuery.of(context).size.width,
                    height: 200,
                    imageUrl: room.roomUrl,
                    placeholder: (context, url) =>
                        Align(child: new CircularProgressIndicator()),
                    errorWidget: (context, url, error) => new Icon(Icons.error),
                  )),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(width: 5),
                  Text(
                    room.roomName.toUpperCase(),
                    style: TextStyle(fontSize: 20, color: Colors.blue[900]),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Divider(
                color: Colors.blue[900],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AmenitiesList(
                    amenities: room.amenities,
                  ),
                  Row(
                    children: [
                      ElevatedCustomButton(
                          text: 'Book'.tr(),
                          press: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) =>
                                    //Calendar()
                                    //TableCalendarScreen(currentUserData: widget.currentUserData,roomId: room.roomId,)
                                    BookingCalendar(
                                        roomId: room.roomId,
                                        userData: widget.currentUserData,
                                        roomName: room.roomName)));
                          },
                          color: Constants.BUTTON_COLOR),
                      SizedBox(width: 10)
                    ],
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildRoomCardGrid(Room room) {
    return GestureDetector(
      onTap: () {
        Navigation.navigateToViewRoomScreen(context, room,
            widget.currentUserData.currentOrganizationId, widget.userRole,widget.currentUserData);
      },
      child: Card(
        color: Constants.CONTAINER_COLOR,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                  child: CachedNetworkImage(
                    fit: BoxFit.cover,
                    width: MediaQuery.of(context).size.width,
                    height: 60,
                    imageUrl: room.roomUrl,
                    placeholder: (context, url) =>
                        Align(child: new CircularProgressIndicator()),
                    errorWidget: (context, url, error) => new Icon(Icons.error),
                  )),
              Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(width: 5),
                  Flexible(
                    child: RichText(
                      overflow: TextOverflow.ellipsis,
                      strutStyle: StrutStyle(fontSize: 12.0),
                      text: TextSpan(
                        text:room.roomName.toUpperCase(),
                        style: appTextStyle.copyWith(color: Colors.blue[900],),
                      ),
                    ),
                  ),
                ],
              ),
              Spacer(),
              AmenitiesList(amenities: room.amenities,),
              Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedCustomButton(
                      text: 'Book'.tr(),
                      press: () {
                        Navigation.navigateToRoomCalendar(context, room.roomId, widget.currentUserData, room.roomName);
                      },
                      color: Constants.BUTTON_COLOR),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget? buildFab() {
    return widget.userRole == '4' || widget.userRole=='3'
        ? (isFabVisible
            ? FloatingActionButton(
                backgroundColor: Constants.BUTTON_COLOR,
                onPressed: () {
                  Navigation.navigateToAddEditRoomScreen(
                      context,
                      null,
                      widget.currentUserData.currentOrganizationId,
                      widget.userRole,widget.currentUserData);
                },
                child: Icon(Icons.add),
              )
            : null)
        : null;
  }
}
