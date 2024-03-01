import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;


class ColoredBoxInlineSyntax extends md.InlineSyntax {
  ColoredBoxInlineSyntax({
    String pattern = r'\[(.*?)\]',
  }) : super(pattern);

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    /// This creates a new element with the tag name `coloredBox`
    /// The `textContent` of this new tag will be the
    /// pattern match with the @ symbol
    ///
    /// We can change how this looks by creating a custom
    /// [MarkdownElementBuilder] from the `flutter_markdown` package.
    final withoutBracket1 = match.group(0)?.replaceAll('[', "");
    final withoutBracket2 = withoutBracket1?.replaceAll(']', "");
    md.Element mentionedElement = md.Element.text("coloredBox", withoutBracket2!);
    print('Mentioned user ${mentionedElement.textContent}');
    parser.addNode(mentionedElement);
    return true;
  }
}

class ColoredBoxMarkdownElementBuilder extends MarkdownElementBuilder {
  final BuildContext context;
  final List<String> mentionedUsers;
  final String myName;

  ColoredBoxMarkdownElementBuilder(this.context, this.mentionedUsers, this.myName);

  ///This method would help us figure out if the text element needs styling
  ///The background color of the text would be Color(0xffDCECF9) if it is the
  ///sender's name that is mentioned in the text, otherwise it would be transparent
  Color _backgroundColorForElement(String text) {
    Color color = Colors.transparent;
    if (mentionedUsers != null) {
      if (mentionedUsers.contains(myName) && text.contains(myName)) {
        color = Color(0xffDCECF9);
      } else {
        color = Colors.transparent;
      }
    }
    return color;
  }

  ///This method would help us figure out if the text element needs styling
  ///The text color would be blue if the text is a user's name and is mentioned
  ///in the text
  Color _textColorForBackground(Color backgroundColor, String textContent) {
    return checkIfFormattingNeeded(textContent) ? Colors.blue : Colors.black;
  }

  @override
  Widget visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    return Container(
      margin: EdgeInsets.only(left: 0, right: 0, top: 2, bottom: 2),
      decoration: element.textContent.contains(myName)
          ? BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
        color: _backgroundColorForElement(element.textContent),
      )
          : null,
      child: Padding(
        padding: element.textContent.contains(myName) ? EdgeInsets.all(4.0) : EdgeInsets.all(0),
        child: Text(
          element.textContent,
          style: TextStyle(
            color: _textColorForBackground(
              _backgroundColorForElement(
                element.textContent.replaceAll('@', ''),
              ),
              element.textContent.replaceAll('@', ''),
            ),
            fontWeight: checkIfFormattingNeeded(
              element.textContent.replaceAll('@', ''),
            )
                ? FontWeight.w600
                : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  bool checkIfFormattingNeeded(String text) {
    var checkIfFormattingNeeded = false;
    if (mentionedUsers != null && mentionedUsers.isNotEmpty) {
      if (mentionedUsers.contains(text) || mentionedUsers.contains(myName)) {
        checkIfFormattingNeeded = true;
      } else {
        checkIfFormattingNeeded = false;
      }
    }
    return checkIfFormattingNeeded;
  }
}