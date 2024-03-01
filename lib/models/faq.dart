class FAQ{
  final String faqId;
  final String organizationId;
  final String question;
  final String answer;
  final String createdByUid;

  const FAQ({
    required this.faqId,
    required this.organizationId,
    required this.question,
    required this.answer,
    required this.createdByUid
  });

  Map<String, dynamic> toMap() {
    return {
      'faqId': this.faqId,
      'organizationId': this.organizationId,
      'question': this.question,
      'answer': this.answer,
      'createdByUid':this.createdByUid
    };
  }

  factory FAQ.fromMap(Map<String, dynamic> map) {
    return FAQ(
      faqId: map['faqId'] as String,
      organizationId: map['organizationId'] as String,
      question: map['question'] as String,
      answer: map['answer'] as String,
      createdByUid: map['createdByUid']==null?'':map['createdByUid']
    );
  }
}