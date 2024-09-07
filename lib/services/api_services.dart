import 'dart:convert';
import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:hackathon_app/services/data.dart';
import 'package:http/http.dart' as http;

class ApiServices {
  String apikeygpt =
      "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";
  late ChatSession chat;
  late GenerativeModel model;
  ApiServices(String weatherDetails) {
    String apiKey = "AIzaSyBCN7k2i4E9L48vtyRR4MBOMyPds3Sc8cQ";
    final model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
    );
    this.model = model;
    ChatSession chat = model.startChat(
        history: [Content.model(getData()), Content.text(weatherDetails)]);
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

class WeatherApi {
  String apiKey = 'e114a7a0ae595a3fab28ba629489de90';

  Future getWeather(String city) async {
    final url = Uri.parse("http://api.openweathermap.org/data/2.5/forecast");

    final params = {
      'q': city,
      'appid': apiKey,
      'units': 'metric',
    };

    final uri = url.replace(queryParameters: params);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      for (var entry in data['list']) {
        String dtTxt = entry['dt_txt'];
        var main = entry['main'];
        var weather = entry['weather'][0];

        print("\nDate and Time: $dtTxt");
        print("Temperature: ${main['temp']}°C");
        print("Weather: ${weather['description'].toString()}");
        print("Humidity: ${main['humidity']}%");
        print("Pressure: ${main['pressure']} hPa");
      }
      return data["list"];
    } else {
      return "Error fetching weather data. Please check your API key and city name.";
    }
  }
}
