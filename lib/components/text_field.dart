import 'package:flutter/material.dart';

class TextFieldInput extends StatefulWidget {
  final String hintText;
  final ValueChanged<String> onChangeValue;
  final bool isDone;
  final bool shouldObscureText;
  final String? initialValue;
  final int? maxLength;
  final TextEditingController? controller;
  final Function(String)? onFieldSubmitted;
  final Function()? onTap;
  final TextInputType? textInputType;
  final bool autoCorrect;

  const TextFieldInput(
      {Key? key,
      required this.hintText,
      required this.onChangeValue,
      required this.isDone,
      required this.shouldObscureText,
      this.initialValue,
      this.maxLength,
      this.controller,
      this.onFieldSubmitted,
      this.textInputType,
      this.autoCorrect = true,
      this.onTap})
      : super(key: key);

  @override
  State<TextFieldInput> createState() => _TextFieldInputState();
}

class _TextFieldInputState extends State<TextFieldInput> {
  bool obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
        onTap: widget.onTap,
        autocorrect: widget.autoCorrect,
        keyboardType: widget.textInputType,
        onFieldSubmitted: widget.onFieldSubmitted,
        controller: widget.controller,
        maxLength: widget.maxLength,
        initialValue: widget.initialValue,
        obscureText: widget.shouldObscureText ? obscureText : false,
        textInputAction:
            widget.isDone ? TextInputAction.done : TextInputAction.next,
        decoration: InputDecoration(
            suffixIcon: widget.shouldObscureText
                ? IconButton(
                    onPressed: () => setState(() {
                      obscureText = !obscureText;
                    }),
                    icon: Icon(
                        obscureText ? Icons.visibility : Icons.visibility_off),
                  )
                : null,
            hintText: widget.hintText,
            border: UnderlineInputBorder()),
        onChanged: widget.onChangeValue);
  }
}
