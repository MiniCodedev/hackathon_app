import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:hackathon_app/constant.dart';
import 'package:hackathon_app/helper/user_provider.dart';
import 'package:hackathon_app/services/api_services.dart';
import 'package:hackathon_app/widgets/message_tile.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

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
  ApiServices? apiServices;
  List<String> commands = [
    "how can we care for the plants in this kind of weather to ensure they stay healthy?",
    "What is today's weather with full details? Do not mention that I provided the data.",
    "only mention that I should go to the weather screen to change the location.",
  ];
  List<String> commandNames = [
    "Weather Based Plant Care",
    "Today's Weather Details",
    "Change location",
  ];

  void animateToEnd() {
    scrollController.animateTo(
      scrollController.position.maxScrollExtent + 500,
      duration: const Duration(seconds: 2),
      curve: Curves.linearToEaseOut,
    );
  }

  Future chatMessage(String usermessage) async {
    String chat;
    message.add(["GenixAi", "....", "null"]);
    setState(() {});
    if (imageBytes != null) {
      chat = (await apiServices!.apiCallImage(usermessage, imageBytes!));
    } else {
      chat = (await apiServices!.apiCallsendMessage(usermessage));
    }
    message.removeAt(message.length - 1);
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

  onCommand(int index_) {
    isfetching = true;
    message.add(["user", commandNames[index_], "null"]);
    animateToEnd();
    chatMessage(commands[index_]);
    setState(() {});
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
    apiServices = context.watch<UserProvider>().apiServices;

    return Scaffold(
      appBar: AppBar(
        title: const Text("AutoGenixBot"),
      ),
      body: apiServices == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(10),
                    controller: scrollController,
                    shrinkWrap: true,
                    itemCount: message.length,
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          message[index][2] == "null"
                              ? Container()
                              : Align(
                                  alignment: message[index][0] == "user"
                                      ? Alignment.topRight
                                      : Alignment.topLeft,
                                  child: Container(
                                    padding: const EdgeInsets.all(5),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.memory(
                                        message[index][2],
                                        fit: BoxFit.cover,
                                        height: 200,
                                      ),
                                    ),
                                  ),
                                ),
                          Align(
                            alignment: message[index][0] == "user"
                                ? Alignment.topRight
                                : Alignment.topLeft,
                            child: MessageTile(
                              isUser: message[index][0] == "user",
                              message: message[index][1],
                              image: message[index][2] == "null"
                                  ? null
                                  : message[index][2],
                            ),
                          ),
                        ],
                      );
                    },
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
                      SizedBox(
                        height: 50,
                        child: ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemCount: commands.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: isfetching
                                  ? null
                                  : () {
                                      onCommand(index);
                                    },
                              child: Container(
                                margin:
                                    const EdgeInsets.only(right: 5, bottom: 10),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.black,
                                    ),
                                    borderRadius: BorderRadius.circular(20)),
                                child: Text(
                                  commandNames[index],
                                  style: const TextStyle(),
                                ),
                              ),
                            );
                          },
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
                                    color: usermsg.isEmpty
                                        ? Colors.grey
                                        : !isfetching
                                            ? primaryColor
                                            : Colors.grey,
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
