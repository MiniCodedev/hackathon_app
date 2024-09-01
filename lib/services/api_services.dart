import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:hackathon_app/services/data.dart';

class ApiServices {
  late ChatSession chat;
  late GenerativeModel model;
  ApiServices() {
    String apiKey = "AIzaSyAvuRtBGVYMlI_OcGE_QmKRmDLBR6u6J98";
    final model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
      generationConfig: GenerationConfig(maxOutputTokens: 200),
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

  Future<String> apiCallImage(String message, Uint8List imageBytes) async {
    final content = [
      Content.multi([
        TextPart(message),
        DataPart('image/png', imageBytes),
      ])
    ];

    final response = await model.generateContent(content);
    return response.text ?? "";
  }

  Future<String> apiCallsendMessage(String userMessage) async {
    var content = Content.text(userMessage);
    var response = await chat.sendMessage(content);
    return response.text ?? "";
  }
}
