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
  List<List> message = [];
  String usermsg = "";
  bool isfetching = false;
  ApiServices apiServices = ApiServices();

  void animateToEnd() {
    scrollController.animateTo(
      scrollController.position.maxScrollExtent + 500,
      duration: const Duration(seconds: 2),
      curve: Curves.linearToEaseOut,
    );
  }

  Future chatMessage(String usermessage) async {
    String chat;
    if (imageBytes != null) {
      chat = (await apiServices.apiCallImage(usermessage, imageBytes!));
    } else {
      chat = (await apiServices.apiCallsendMessage(usermessage));
    }

    message.add(["GenixAi", chat, "null"]);
    animateToEnd();

    setState(() {
      imageBytes = null;
      isfetching = false;
    });
  }

  File? _imageFile;
  bool usingImage = false;
  Uint8List? imageBytes;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      _imageFile = File(pickedFile.path);
      imageBytes = await _imageFile!.readAsBytes();
      usingImage = true;
      setState(() {});
    }
  }

  onSubmit() {
    isfetching = true;
    message.add(["user", usermsg, imageBytes ?? "null"]);
    animateToEnd();
    chatMessage(usermsg);
    userTextField.clear();
    setState(() {
      usermsg = "";
      usingImage = false;
    });
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
                    image:
                        message[index][2] == "null" ? null : message[index][2],
                  );
                },
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                !usingImage
                    ? Container()
                    : Container(
                        padding: const EdgeInsets.all(5),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.memory(
                            imageBytes!,
                            fit: BoxFit.cover,
                            height: 100,
                          ),
                        ),
                      ),
                TextField(
                  controller: userTextField,
                  onChanged: (value) {
                    setState(() {
                      usermsg = value;
                    });
                  },
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.message_rounded),
                    suffixIcon: SizedBox(
                      width: 100,
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () async {
                              await _pickImage();
                            },
                            icon: const Icon(Icons.attach_file_rounded),
                          ),
                          IconButton(
                            onPressed: isfetching
                                ? null
                                : usermsg.isEmpty
                                    ? null
                                    : () {
                                        onSubmit();
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
              ],
            ),
          )
        ],
      ),
    );
  }
}

class MessageTile extends StatefulWidget {
  const MessageTile(
      {super.key, required this.name, required this.message, this.image});

  final String name;
  final String message;
  final Uint8List? image;

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
                  widget.image == null
                      ? Container()
                      : Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.memory(widget.image!)),
                        )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
