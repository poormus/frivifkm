import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_calendar/components/sized_box.dart';
import 'package:firebase_calendar/models/company.dart';
import 'package:firebase_calendar/services/admin_services.dart';
import 'package:firebase_calendar/shared/constants.dart';
import 'package:flutter/material.dart';

class OrganizationInfoModalBottom extends StatelessWidget {
  final String orgId;
  final adminService = AdminServices();
  OrganizationInfoModalBottom({Key? key, required this.orgId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Wrap(
      children: [
        StreamBuilder<Organization>(
            stream: adminService.getOrganization(orgId),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final org = snapshot.data!;
                return Column(
                  children: [
                    SizedBox(height: 10),
                    ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                        child: CachedNetworkImage(
                          fit: BoxFit.cover,
                          width: size.width * 0.85,
                          height: size.height * 0.2,
                          imageUrl: org.organizationUrl,
                          placeholder: (context, url) =>
                              Align(child: new CircularProgressIndicator()),
                          errorWidget: (context, url, error) =>
                              new Icon(Icons.error),
                        )),
                    SizedBox(height: 5),
                    Text(org.organizationName,
                        style:
                            appTextStyle.copyWith(fontWeight: FontWeight.bold)),
                    SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(width: 25),
                        Text('About'.tr(),
                            style: appTextStyle.copyWith(
                                fontWeight: FontWeight.bold))
                      ],
                    ),
                    SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(width: 25),
                        Container(
                          height: 50,
                          width: size.width * 0.8,
                          child: Text(org.about,
                              style:
                                  appTextStyle.copyWith(color: Colors.black45)),
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(width: 25),
                        Text('Information'.tr(),
                            style: appTextStyle.copyWith(
                                fontWeight: FontWeight.bold))
                      ],
                    ),
                    SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(width: 25),
                        Text(
                          'Contact person: '.tr(),
                          style: appTextStyle.copyWith(color: Colors.black45),
                        ),
                        Text(org.contactPerson,
                            style: appTextStyle.copyWith(color: Colors.black45))
                      ],
                    ),
                    SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(width: 25),
                        Text(
                          'E-post: '.tr(),
                          style: appTextStyle.copyWith(color: Colors.black45),
                        ),
                        Text(org.ePost,
                            style: appTextStyle.copyWith(color: Colors.black45))
                      ],
                    ),
                    SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(width: 25),
                        Text(
                          'Mobil: '.tr(),
                          style: appTextStyle.copyWith(color: Colors.black45),
                        ),
                        Text(org.mobil,
                            style: appTextStyle.copyWith(color: Colors.black45))
                      ],
                    ),
                    SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(width: 25),
                        Text(
                          'Address: '.tr(),
                          style: appTextStyle.copyWith(color: Colors.black45),
                        ),
                        Text(org.address,
                            style: appTextStyle.copyWith(color: Colors.black45))
                      ],
                    ),
                    SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(width: 25),
                        Text(
                          'Website: '.tr(),
                          style: appTextStyle.copyWith(color: Colors.black45),
                        ),
                        Text(org.website,
                            style: appTextStyle.copyWith(color: Colors.black45))
                      ],
                    ),
                    SizedBoxWidget(),
                    SizedBoxWidget(),
                    SizedBoxWidget()
                  ],
                );
              } else
                return Center(child: CircularProgressIndicator());
            }),
      ],
    );
  }
}
