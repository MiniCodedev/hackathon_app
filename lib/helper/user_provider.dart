import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';

class UserProvider extends ChangeNotifier {
  var weatherData;
  List<String>? date;
  String apiKey = 'db30c378954eebaa7890e147fb9cb00d';

  Future getWeatherData(String city) async {
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
      date = date_;
      weatherData = data;
      notifyListeners();
      return date_;
    } else {
      return "Error fetching weather data. Please check your API key and city name.";
    }
  }
}
