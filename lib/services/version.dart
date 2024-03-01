
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_calendar/config/key_config.dart';
import 'package:firebase_calendar/models/company.dart';

class VersionCheck{

  final refVersion = FirebaseFirestore.instance.collection('appen');
  final organizationRef = Configuration.isProduction?FirebaseFirestore.instance.collection('organizations'):FirebaseFirestore.instance.collection('organizations_test');

  Future<List<String>> getVersion() async{
    List<String> versionInfo=[];
    String versionNumber='';
    String versionNumberIOS='';
    String appStoreUrl='';
    String playStoreUrl='';
    await refVersion.doc('XboWJ6NGij8dlMJkaM80').get().then((value) {
      versionNumber=value['version'].toString();
      versionNumberIOS=value['versionIOS'].toString();
      appStoreUrl=value['appStoreUrl'].toString();
      playStoreUrl=value['playStoreUrl'].toString();
      versionInfo.add(versionNumber);
      versionInfo.add(versionNumberIOS);
      versionInfo.add(appStoreUrl);
      versionInfo.add(playStoreUrl);
    });
    return versionInfo;
  }

  Future<Organization> getOrganizationFromCode(String orgId) async{

     return await organizationRef.doc(orgId).get().then((value) =>
        Organization.fromMap(value.data()!)
     );
  }


}