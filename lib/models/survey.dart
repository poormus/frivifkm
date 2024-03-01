import '../shared/utils.dart';

class Survey{

  final String surveyId;
  final String organizationId;
  final String surveyTitle;
  final String createdBy;
  final List<String> surveyQuestions;
  final List<String> toWho;
  final List<String> seenBy;
  final List<SurveyResponse> surveyResponses;
  final DateTime createdAt;
  final DateTime expiresAt;
  final String type;

  const Survey({
    required this.surveyId,
    required this.organizationId,
    required this.surveyTitle,
    required this.createdBy,
    required this.surveyQuestions,
    required this.toWho,
    required this.seenBy,
    required this.surveyResponses,
    required this.createdAt,
    required this.expiresAt,
    required this.type
  });

  Map<String, dynamic> toMap() {
    return {
      'surveyId': this.surveyId,
      'organizationId': this.organizationId,
      'surveyTitle': this.surveyTitle,
      'createdBy':this.createdBy,
      'surveyQuestions': this.surveyQuestions,
      'toWho': this.toWho,
      'seenBy': this.seenBy,
      'surveyResponses': this.surveyResponses.map((e) => e.toMap()).toList(),
      'createdAt':this.createdAt,
      'expiresAt':this.expiresAt,
      'type':this.type
    };
  }

  factory Survey.fromMap(Map<String, dynamic> map) {
    List<SurveyResponse> responses=[];
    List surveyResponsesFromMap=map['surveyResponses'];
    surveyResponsesFromMap.forEach((element) {
      final response=SurveyResponse.fromMap(element as Map<String, dynamic>);
      responses.add(response);
    });
    return Survey(
      surveyId: map['surveyId'],
      organizationId: map['organizationId'],
      createdBy: map['createdBy'],
      surveyTitle: map['surveyTitle'],
      surveyQuestions: List.castFrom(map['surveyQuestions']),
      toWho: List.castFrom(map['toWho']) ,
      seenBy: List.castFrom(map['seenBy']),
      surveyResponses: responses,
      createdAt: Utils.toDateTime(map['createdAt']),
      expiresAt: Utils.toDateTime(map['expiresAt']),
      type: map['type']
    );
  }
}


class SurveyResponse{
  final String uid;
  final List<String> responses;

  const SurveyResponse({
    required this.uid,
    required this.responses,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': this.uid,
      'responses': this.responses,
    };
  }

  factory SurveyResponse.fromMap(Map<String, dynamic> map) {
    return SurveyResponse(
      uid: map['uid'] as String,
      responses: List.castFrom(map['responses'])
    );
  }
}