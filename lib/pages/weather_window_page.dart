import 'dart:convert';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:hackathon_app/constant.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WeatherWindowPage extends StatefulWidget {
  const WeatherWindowPage({super.key});

  @override
  State<WeatherWindowPage> createState() => _WeatherWindowPageState();
}

class _WeatherWindowPageState extends State<WeatherWindowPage> {
  bool isloading = true;
  String? currentTemp;
  String? pressure;
  String? humidity;
  String? windSpeed;
  String? currentSky;
  List? forecast;
  int selected = 0;
  String apiKey = 'e114a7a0ae595a3fab28ba629489de90';
  List<String> date = [];
  String city_ = "Chennai";
  TextEditingController userTextField = TextEditingController();

  Future getDate(String city) async {
    final url = Uri.parse("http://api.openweathermap.org/data/2.5/forecast");
    List<String> date_ = [];

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
        String dtTxt = entry['dt_txt'].toString().split(" ")[0];
        if (!date_.contains(dtTxt)) {
          date_.add(dtTxt);
        }
      }
      return date_;
    } else {
      return "Error fetching weather data. Please check your API key and city name.";
    }
  }

  Future getCurrentWeather(int index, String city) async {
    try {
      final url = Uri.parse("http://api.openweathermap.org/data/2.5/forecast");
      final newData = [];
      final params = {
        'q': city,
        'appid': apiKey,
        'units': 'metric',
      };

      final uri = url.replace(queryParameters: params);
      final response = await http.get(uri);
      final data = jsonDecode(response.body);
      if (data["cod"] != "200") {
        throw "Unexpected";
      }

      currentTemp = data["list"][index]["main"]["temp"].toString();
      currentSky = data["list"][index]["weather"][0]["main"].toString();
      humidity = data["list"][index]["main"]["humidity"].toString();
      windSpeed = data["list"][index]["wind"]["speed"].toString();
      pressure = data["list"][index]["main"]["pressure"].toString();
      for (var entry in data["list"]) {
        String dtTxt = date[index];
        if (entry["dt_txt"].toString().contains(dtTxt)) {
          newData.add(entry);
        }
      }
      forecast = newData;

      return data;
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  void initState() {
    super.initState();
    getDate(city_).then(
      (value) {
        setState(() {
          date = value;
          isloading = false;
        });
      },
    );
    userTextField.text = city_;
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              setState(() {});
            },
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
        title: const Text(
          "Weather",
        ),
        elevation: 0,
        centerTitle: true,
      ),
      body: isloading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : FutureBuilder(
              future: getCurrentWeather(selected, city_),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Column(
                    children: [
                      SizedBox(
                        height: height / 2.5,
                      ),
                      const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(
                        height: 200,
                      )
                    ],
                  );
                } else if (snapshot.hasError) {
                  return const Center(child: Text("ERROR"));
                }
                return Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: width / 2.3,
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              child: TextField(
                                controller: userTextField,
                                onChanged: (value) {
                                  city_ = value;
                                },
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(CupertinoIcons.map),
                                  suffixIcon: IconButton(
                                      onPressed: () async {
                                        await getDate(city_);
                                        setState(() {});
                                      },
                                      icon: const Icon(
                                          CupertinoIcons.cloud_download)),
                                  hintText: "City name",
                                  border: border,
                                  focusedBorder: focusborder,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Card(
                                elevation: 7,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16)),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: BackdropFilter(
                                    filter:
                                        ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        children: [
                                          Text(
                                            "$currentTemp K",
                                            style: const TextStyle(
                                                fontSize: 32,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(
                                            height: 16,
                                          ),
                                          Icon(
                                            currentSky == "Clouds"
                                                ? Icons.cloud
                                                : currentSky == "Rain"
                                                    ? CupertinoIcons
                                                        .cloud_rain_fill
                                                    : Icons.sunny,
                                            size: 64,
                                          ),
                                          const SizedBox(
                                            height: 16,
                                          ),
                                          Text(
                                            "$currentSky",
                                            style: const TextStyle(
                                              fontSize: 20,
                                            ),
                                          ),
                                          SizedBox(
                                            height: 20,
                                          ),
                                          Row(
                                            children: [
                                              Additional_Widget(
                                                  icon:
                                                      Icons.water_drop_rounded,
                                                  name: "Humidity",
                                                  number: "$humidity"),
                                              Additional_Widget(
                                                icon: Icons.air_rounded,
                                                name: "Wind Speed",
                                                number: "$windSpeed",
                                              ),
                                              Additional_Widget(
                                                  icon: Icons
                                                      .beach_access_rounded,
                                                  name: "Pressure",
                                                  number: "$pressure"),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      SizedBox(
                        width: width / 2,
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: mirror,
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    alignment: Alignment.topLeft,
                                    child: const Row(
                                      children: [
                                        Icon(Icons.calendar_month_rounded),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          "6-Day Forecast",
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Divider(),
                                  SizedBox(
                                    height: 125,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: forecast!.length - 1,
                                      itemBuilder: (context, index) {
                                        final foreCast = forecast![index + 1];
                                        final time = DateTime.parse(
                                            foreCast["dt_txt"].toString());
                                        return Card_Widget(
                                          time: DateFormat("j").format(time),
                                          icon: foreCast["weather"][0]
                                                          ["main"] ==
                                                      "Clouds" ||
                                                  foreCast["weather"][0]
                                                          ["main"] ==
                                                      "Rain"
                                              ? Icons.cloud
                                              : Icons.sunny,
                                          temp: foreCast["main"]["temp"]
                                              .toString(),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: mirror,
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    alignment: Alignment.topLeft,
                                    child: const Row(
                                      children: [
                                        Icon(CupertinoIcons.clock_solid),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          "Hourly Forecast",
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Divider(),
                                  SizedBox(
                                    height: 125,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: forecast!.length - 1,
                                      itemBuilder: (context, index) {
                                        final foreCast = forecast![index + 1];
                                        final time = DateTime.parse(
                                            foreCast["dt_txt"].toString());
                                        return Card_Widget(
                                          time: DateFormat("j").format(time),
                                          icon: foreCast["weather"][0]
                                                          ["main"] ==
                                                      "Clouds" ||
                                                  foreCast["weather"][0]
                                                          ["main"] ==
                                                      "Rain"
                                              ? Icons.cloud
                                              : Icons.sunny,
                                          temp: foreCast["main"]["temp"]
                                              .toString(),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class Additional_Widget extends StatelessWidget {
  const Additional_Widget(
      {super.key,
      required this.icon,
      required this.name,
      required this.number});

  final icon;
  final name;
  final number;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Icon(
              icon,
              size: 30,
            ),
            const SizedBox(
              height: 5,
            ),
            Text(
              name,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
            ),
            const SizedBox(
              height: 5,
            ),
            Text(
              number,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

class Card_Widget extends StatelessWidget {
  const Card_Widget(
      {super.key, required this.time, required this.icon, required this.temp});

  final time;
  final icon;
  final temp;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Text(
                time,
                style:
                    const TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
              ),
              const SizedBox(
                height: 5,
              ),
              Icon(
                icon,
                size: 30,
              ),
              const SizedBox(
                height: 5,
              ),
              Text(
                temp,
                style: const TextStyle(fontSize: 15),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
