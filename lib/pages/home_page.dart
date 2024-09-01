import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:hackathon_app/constant.dart';
import 'package:hackathon_app/services/api_services.dart';
import 'package:image_picker/image_picker.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController userTextField = TextEditingController();
  ScrollController scrollController = ScrollController();
  List<List<String>> message = [];
  String usermsg = "";
  bool isfetching = false;
  ApiServices apiServices = ApiServices();

  StreamSubscription<String>? _subscription;

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void chatMessageStream(String usermessage) {
    _subscription = apiServices.apiCallStream(usermessage).listen((chat) {
      setState(() {
        message.add(["GenixAi", chat]);
        animateToEnd();
      });
    }, onDone: () {
      setState(() {
        isfetching = false;
      });
    });
  }

  void animateToEnd() {
    scrollController.animateTo(
      scrollController.position.maxScrollExtent + 500,
      duration: const Duration(seconds: 2),
      curve: Curves.linearToEaseOut,
    );
  }

  Future chatMessage(String usermessage) async {
    String chat = (await apiServices.apiCallsendMessage(usermessage));
    message.add(["GenixAi", chat]);
    animateToEnd();
    setState(() {
      isfetching = false;
    });
  }

  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<Uint8List?> _getImageBytes() async {
    if (_imageFile == null) return null;
    return await _imageFile!.readAsBytes();
  }

  onSubmit(String usermsg) {
    isfetching = true;
    message.add(["user", usermsg]);
    userTextField.clear();
    setState(() {});
    animateToEnd();
    chatMessage(usermsg);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AutoGenixBot"),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: ListView.builder(
                controller: scrollController,
                shrinkWrap: true,
                itemCount: message.length,
                itemBuilder: (context, index) {
                  return MessageTile(
                    name: message[index][0],
                    message: message[index][1],
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: userTextField,
              onChanged: (value) {
                usermsg = value;
              },
              onSubmitted: isfetching
                  ? null
                  : (value) {
                      usermsg = value;
                      onSubmit(usermsg);
                    },
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.message_rounded),
                suffixIcon: Container(
                  width: 100,
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () async {
                          await _pickImage();
                          Uint8List? imageBytes = await _getImageBytes();

                          if (imageBytes != null) {
                            // Use the image bytes here
                            print(
                                "Image size: ${imageBytes.length} bytes" * 100);
                          }
                        },
                        icon: const Icon(Icons.attach_file_rounded),
                      ),
                      IconButton(
                        onPressed: isfetching
                            ? null
                            : () {
                                onSubmit(usermsg);
                              },
                        icon: Icon(
                          Icons.send_rounded,
                          color: isfetching ? Colors.grey[600] : null,
                        ),
                      ),
                    ],
                  ),
                ),
                hintText: "Message",
                border: border,
                focusedBorder: focusborder,
              ),
            ),
          )
        ],
      ),
    );
  }
}

class MessageTile extends StatefulWidget {
  const MessageTile({super.key, required this.name, required this.message});

  final String name;
  final String message;

  @override
  State<MessageTile> createState() => _MessageTileState();
}

class _MessageTileState extends State<MessageTile> {
  List<TextSpan> parseText(String text) {
    List<TextSpan> spans = [];
    final RegExp regExp = RegExp(r'\*\*(.*?)\*\*');
    final matches = regExp.allMatches(text);

    int start = 0;
    for (final match in matches) {
      // Add the text before the bold part
      if (match.start > start) {
        spans.add(TextSpan(text: text.substring(start, match.start)));
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
      spans.add(TextSpan(text: text.substring(start)));
    }

    return spans;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: widget.name == "user"
                  ? const CircleAvatar(
                      child: Text(
                        "U",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    )
                  : const CircleAvatar(
                      child: Text(
                        "AI",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
            ),
            Expanded(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 10,
                    ),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        widget.name == "user" ? "User" : "GenixAi",
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 10,
                    ),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: RichText(
                        text: TextSpan(
                          style: DefaultTextStyle.of(context).style,
                          children: parseText(widget.message),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
