import 'package:firebase_calendar/base_scaffolds/base_scaffold.dart';
import 'package:firebase_calendar/models/company.dart';
import 'package:firebase_calendar/models/current_user_data.dart';
import 'package:firebase_calendar/screens/auth/sign_up.dart';
import 'package:firebase_calendar/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class SuperAdminScreen extends StatefulWidget {
  final CurrentUserData userData;
  const SuperAdminScreen({Key? key, required this.userData}) : super(key: key);

  @override
  State<SuperAdminScreen> createState() => _SuperAdminScreenState();
}

class _SuperAdminScreenState extends State<SuperAdminScreen> {
  late Stream<List<Organization>> allOrgs;
  final AuthService service = AuthService();

  @override
  void initState() {
    allOrgs = service.allOrganizationsForSuperAdmin();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
        appBarName: 'Super admin', body: buildBody(), shouldScroll: true);
  }

  Widget buildBody() {
    return StreamBuilder<List<Organization>>(
      stream: allOrgs,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final data = snapshot.data!;
          return ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                return orgTile(data[index]);
              });
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget orgTile(Organization organization) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(organization.organizationUrl),
                ),
                SizedBox(width: 10),
                Expanded(child: Text(organization.organizationName)),
              ],
            ),
            SizedBox(height: 20),
            Text('Organisation package level'),
            SizedBox(height: 10),
            DropdownMenu(
                onSelected: (value) {
                  service.updateOrganizationSubLevel(
                      value.toString(), organization.organizationId);
                },
                enableSearch: false,
                initialSelection: organization.subLevel,
                dropdownMenuEntries: [
                  DropdownMenuEntry(value: 'freemium', label: 'Free'),
                  DropdownMenuEntry(value: 'premium', label: 'Premium'),
                  DropdownMenuEntry(value: 'premium+', label: 'Premium plus'),
                ]),
            SizedBox(height: 10),
            Text(
                'Organisation approval (if approved organisation will be visible to public)'),
            Row(
              children: [
                Text(organization.isApproved ? 'Approved' : 'Not approved'),
                Switch(
                    value: organization.isApproved,
                    onChanged: (val) {
                      service.updateOrganizationApproval(
                          val, organization.organizationId);
                    })
              ],
            )
          ]),
        ),
      ),
    );
  }
}
