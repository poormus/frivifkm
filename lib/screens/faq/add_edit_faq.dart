import 'package:easy_localization/src/public_ext.dart';
import 'package:firebase_calendar/base_scaffolds/base_scaffold.dart';
import 'package:firebase_calendar/components/elevated_button.dart';
import 'package:firebase_calendar/models/faq.dart';
import 'package:firebase_calendar/services/faq_services.dart';
import 'package:firebase_calendar/shared/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AddEditFAQ extends StatefulWidget {
  final FAQ? faq;
  final String organizationId;
  final String uid;

  const AddEditFAQ({Key? key, this.faq, required this.organizationId, required this.uid})
      : super(key: key);

  @override
  _AddEditFAQState createState() => _AddEditFAQState();
}

class _AddEditFAQState extends State<AddEditFAQ> {
  final key = GlobalKey<FormState>();
  final faqServices = FaqServices();
  late String question;
  late String answer;

  @override
  void initState() {
    question = widget.faq == null ? '' : widget.faq!.question;
    answer = widget.faq == null ? '' : widget.faq!.answer;
    super.initState();
  }

  Future saveFaq() async {
    if (key.currentState!.validate()) {
      if (widget.faq == null) {
        await faqServices.createFaq(question, widget.organizationId, answer,context,widget.uid);
      } else {
        await faqServices.updateFaq(widget.faq!.faqId, question, answer,context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(appBarName: 'Create Faq'.tr(), body: _buildBody(), shouldScroll: true);
    return buildScaffold('Create Faq'.tr(), context, _buildBody(),null);
  }

  Widget _buildBody(){
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: key,
          child: Column(
            children: [
              _builtFaqQuestionText(),
              _buildFaqAnswerText(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedCustomButton(
                        text: widget.faq == null ? 'Save'.tr() : 'Update'.tr(),
                        press: saveFaq,
                        color: Constants.BUTTON_COLOR),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _builtFaqQuestionText() {
    final maxLines = 3;
    return Container(
      margin: EdgeInsets.all(12),
      height: maxLines * 24.0,
      child: TextFormField(
        initialValue: question,
        textInputAction: TextInputAction.newline,
        maxLength: 100,
        inputFormatters: [
          LengthLimitingTextInputFormatter(100),
        ],
        maxLines: maxLines,
        decoration: InputDecoration(
          enabledBorder: InputBorder.none,
          hintText: "Your question".tr(),
          fillColor: Constants.CONTAINER_COLOR,
          filled: true,
        ),
        onChanged: (val) {
          setState(() {
            question = val;
          });
        },
        validator: (val) => val!.isEmpty ? 'Field can not be empty'.tr() : null,
      ),
    );
  }

  Widget _buildFaqAnswerText() {
    final maxLines = 7;
    return Container(
      margin: EdgeInsets.all(12),
      height: maxLines * 24.0,
      child: TextFormField(
        initialValue: answer,
        textInputAction: TextInputAction.newline,
        maxLength: 500,
        inputFormatters: [
          LengthLimitingTextInputFormatter(500),
        ],
        maxLines: maxLines,
        decoration: InputDecoration(
          enabledBorder: InputBorder.none,
          hintText: "Your answer".tr(),
          fillColor: Constants.CONTAINER_COLOR,
          filled: true,
        ),
        onChanged: (val) {
          setState(() {
            answer = val;
          });
        },
        validator: (val) => val!.isEmpty ? 'Field can not be empty'.tr() : null,
      ),
    );
  }
}
