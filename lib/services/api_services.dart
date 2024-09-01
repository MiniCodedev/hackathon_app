import 'dart:io';
import 'dart:typed_data';

import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:hackathon_app/services/data.dart';

class ApiServices {
  late ChatSession chat;
  late GenerativeModel model;
  ApiServices() {
    String apiKey = "AIzaSyBCN7k2i4E9L48vtyRR4MBOMyPds3Sc8cQ";
    final model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
    );
    this.model = model;
    ChatSession chat = model.startChat(history: [Content.model(getData())]);
    this.chat = chat;
  }

  List<Part> getData() {
    List<Part> data = [];
    int count = 1;
    for (var file in datasets) {
      for (String parts in file["parts_$count"]) {
        data.add(TextPart(parts));
      }

      count += 1;
    }
    return data;
  }

  Future<String> apiCallImage(String message) async {
    String imagePath = "assets/mangobactspot2.jpg";
    File imageFile = File(imagePath);

    // Read the file as bytes
    Uint8List imageBytes = await imageFile.readAsBytes();

    var response = await model.generateContent(
        [Content.data("Image", imageBytes), Content.text(message)]);
    return response.text ?? "";
  }

  Future<String> apiCallsendMessage(String userMessage) async {
    var content = Content.text(userMessage);
    var response = await chat.sendMessage(content);
    return response.text ?? "";
  }

  Stream<String> apiCallStream(String userMessage) async* {
    const apiKey = "AIzaSyBCN7k2i4E9L48vtyRR4MBOMyPds3Sc8cQ";
    final model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
    );

    final chat = model.startChat(history: [Content.model(getData())]);
    var content = Content.text(userMessage);

    // Simulate streaming of responses
    await for (var response in chat.sendMessageStream(content)) {
      yield response.text ?? "";
    }
  }
}
