import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_calendar/base_scaffolds/base_scaffold.dart';
import 'package:firebase_calendar/screens/offers/my_offer_history.dart';
import 'package:firebase_calendar/screens/offers/see_offers.dart';
import 'package:flutter/material.dart';

import '../../models/current_user_data.dart';
import '../../shared/constants.dart';


class OffersMain extends StatefulWidget {
  final CurrentUserData currentUserData;

  const OffersMain({Key? key, required this.currentUserData}) : super(key: key);

  @override
  _OffersMainState createState() => _OffersMainState();
}

class _OffersMainState extends State<OffersMain> {


  String currentTab='offers';


  @override
  Widget build(BuildContext context) {
    return BaseScaffold(appBarName: 'Offers'.tr(), body: buildBody(), shouldScroll: false);
  }


  Widget buildBody(){
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          height: Constants.TAB_HEIGHT,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: TextButton(
                    onPressed: () {
                      setState(() {
                        currentTab = 'offers';
                      });
                    },
                    child: Text(
                      'Offers'.tr(),
                      style: TextStyle(
                          color: currentTab == 'offers'
                              ? Constants.BUTTON_COLOR
                              : Colors.grey),
                    )),
              ),
              VerticalDivider(width: 3, color: Colors.grey),
              Expanded(
                child: TextButton(
                    onPressed: () {
                      setState(() {
                        currentTab = 'history';
                      });
                    },
                    child: Text('History'.tr(),
                        style: TextStyle(
                            color: currentTab == 'history'
                                ? Constants.BUTTON_COLOR
                                : Colors.grey))),
              ),
            ],
          ),
        ),
        Divider(
          height: 3,
          color: Colors.grey,
        ),
        if(currentTab=='offers')...[
          SeeOffers(currentUserData: widget.currentUserData)
        ]
        else...[
          OfferHistory(currentUserData: widget.currentUserData)
        ]
      ],
    );
  }
}
