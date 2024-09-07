import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hackathon_app/constant.dart';

class MessageTile extends StatefulWidget {
  const MessageTile({
    super.key,
    required this.message,
    required this.isUser,
    this.image,
  });

  final String message;
  final bool isUser;
  final Uint8List? image;

  @override
  State<MessageTile> createState() => _MessageTileState();
}

class _MessageTileState extends State<MessageTile> {
  final Color color = primaryColor;
  List<TextSpan> parseText(String text) {
    List<TextSpan> spans = [];
    final RegExp regExp = RegExp(r'\*\*(.*?)\*\*');
    final matches = regExp.allMatches(text);

    int start = 0;
    for (final match in matches) {
      // Add the text before the bold part
      if (match.start > start) {
        spans.add(TextSpan(
            text: text.substring(start, match.start),
            style: TextStyle(
                color: widget.isUser
                    ? Colors.white
                    : Colors.black.withOpacity(0.7))));
      }

      // Add the bold text
      spans.add(TextSpan(
        text: match.group(1),
        style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor),
      ));

      start = match.end;
    }

    // Add the remaining text after the last match
    if (start < text.length) {
      spans.add(TextSpan(
          text: text.substring(start),
          style: TextStyle(
              color: widget.isUser
                  ? Colors.white
                  : Colors.black.withOpacity(0.7))));
    }

    return spans;
  }

  BoxDecoration boxDecoration(bool isUser) {
    return BoxDecoration(
        borderRadius: BorderRadius.only(
          topRight: const Radius.circular(20),
          topLeft: const Radius.circular(20),
          bottomLeft:
              isUser ? const Radius.circular(20) : const Radius.circular(2),
          bottomRight:
              isUser ? const Radius.circular(2) : const Radius.circular(20),
        ),
        border: Border.all(color: Colors.white.withOpacity(0.13)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            isUser
                ? color
                : const Color.fromRGBO(
                    224, 224, 224, 1), //color.withOpacity(0.45),
            isUser ? color : const Color.fromRGBO(224, 224, 224, 1),
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
          left: widget.isUser ? 20 : 0,
          top: 5,
          bottom: 5,
          right: widget.isUser ? 0 : 20),
      padding: const EdgeInsets.all(10),
      decoration: boxDecoration(widget.isUser),
      child: RichText(
        text: TextSpan(
          style: DefaultTextStyle.of(context).style,
          children: parseText(widget.message),
        ),
      ),
    );
  }
}
