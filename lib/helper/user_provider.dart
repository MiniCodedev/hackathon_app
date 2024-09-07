// ignore_for_file: prefer_typing_uninitialized_variables

import 'dart:convert';
import 'package:hackathon_app/services/api_services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';

class UserProvider extends ChangeNotifier {
  ApiServices? apiServices;
  var weatherData;
  List<String>? date;
  String apiKey = 'db30c378954eebaa7890e147fb9cb00d';
  String city = "Chennai";

  changeCity(cityName) {
    city = cityName;
    getWeatherData();
  }

  Future getWeatherData() async {
    final url = Uri.parse("http://api.openweathermap.org/data/2.5/forecast");
    List<String> date_ = [];
    final newData = [];

    final params = {
      'q': city,
      'appid': apiKey,
      'units': 'metric',
    };

    final uri = url.replace(queryParameters: params);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      String? firstDate;

      for (var entry in data['list']) {
        String dtTxt = entry['dt_txt'].toString().split(" ")[0];

        if (!date_.contains(dtTxt)) {
          date_.add(dtTxt);
          firstDate ??= dtTxt;
        }
        if (entry["dt_txt"].toString().contains(firstDate!)) {
          newData.add(entry);
        }
      }
      weatherData = data;
      date = date_;
      int index = 0;
      final currentTemp = weatherData["list"][index]["main"]["temp"].toString();
      final currentSky =
          weatherData["list"][index]["weather"][0]["main"].toString();
      final humidity =
          weatherData["list"][index]["main"]["humidity"].toString();
      final windSpeed = weatherData["list"][index]["wind"]["speed"].toString();
      final pressure =
          weatherData["list"][index]["main"]["pressure"].toString();

      String prompt = """Today's weather details are as follows: 
- Date: ${date_[0]}
- Current Weather: $currentSky
- Current Temperature: $currentTemp °C
- Humidity: $humidity
- Wind Speed: $windSpeed
- Pressure: $pressure
- Location: $city""";

      apiServices = ApiServices(prompt);
      notifyListeners();
      return date_;
    } else {
      return "Error fetching weather data. Please check your API key and city name.";
    }
  }
}
