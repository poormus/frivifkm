
import 'dart:convert';

import 'package:easy_localization/src/public_ext.dart';
import 'package:firebase_calendar/shared/utils.dart';

import 'models/api_model.dart';
import 'package:http/http.dart' as http;

class API{

  final String BASE_API='https://data.brreg.no/enhetsregisteret/api/enheter/';

  Future<OrgDataModel> fetSingleOrganization(String orgNumber)async{

    final response = await http.get(Uri.parse('${BASE_API}${orgNumber}'));
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return OrgDataModel.fromJson(jsonDecode(response.body));
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      Utils.showToastWithoutContext('Organization not found'.tr());
      throw Exception('Failed to load album');
    }
  }
}