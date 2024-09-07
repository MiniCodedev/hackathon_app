import 'dart:convert';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
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
  List<List<String>> weatherTemp = [];
  String city_ = "Chennai";
  TextEditingController userTextField = TextEditingController();
  Color color = primaryColor;

  Future getDate(String city) async {
    final url = Uri.parse("http://api.openweathermap.org/data/2.5/forecast");
    List<String> date_ = [];
    List<List<String>> weather_ = [];

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
          weather_.add([
            entry["weather"][0]["main"].toString(),
            entry["main"]["temp"].toString()
          ]);
          date_.add(dtTxt);
        }
      }
      weatherTemp = weather_;
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
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(snackBarError);
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
                }
                return Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: width / 2.3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
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
                              child: Container(
                                decoration: mirror,
                                padding: const EdgeInsets.all(8),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Text(
                                      "$currentTemp °C",
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
                                              ? CupertinoIcons.cloud_rain_fill
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
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    Row(
                                      children: [
                                        const SizedBox(
                                          width: 20,
                                        ),
                                        Additional_Widget(
                                          icon: Icons.water_drop_rounded,
                                          name: "Humidity",
                                          number: "$humidity",
                                          boxDecoration: mirrorWidget(color),
                                        ),
                                        const SizedBox(
                                          width: 20,
                                        ),
                                        Additional_Widget(
                                          icon: Icons.air_rounded,
                                          name: "Wind Speed",
                                          number: "$windSpeed",
                                          boxDecoration: mirrorWidget(color),
                                        ),
                                        const SizedBox(
                                          width: 20,
                                        ),
                                        Additional_Widget(
                                          icon: Icons.beach_access_rounded,
                                          name: "Pressure",
                                          number: "$pressure",
                                          boxDecoration: mirrorWidget(color),
                                        ),
                                        const SizedBox(
                                          width: 20,
                                        ),
                                      ],
                                    ),
                                  ],
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
                                    height: 150,
                                    child: ScrollConfiguration(
                                      behavior: ScrollConfiguration.of(context)
                                          .copyWith(
                                        dragDevices: {
                                          PointerDeviceKind.touch,
                                          PointerDeviceKind.mouse,
                                        },
                                      ),
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: date.length,
                                        itemBuilder: (context, index) {
                                          DateFormat dateFormat =
                                              DateFormat("yyyy-MM-dd");
                                          DateTime dateTime =
                                              dateFormat.parse(date[index]);

                                          String dayName = DateFormat('EEEE')
                                              .format(dateTime);
                                          return GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                selected = index;
                                              });
                                            },
                                            child: CardWidget(
                                              boxDecoration: selected == index
                                                  ? mirrorWidget(Colors.black)
                                                  : null,
                                              dayName: dayName,
                                              time:
                                                  "${date[index].split("-").last}/${date[index].split("-")[1]}",
                                              icon: weatherTemp[index][0] ==
                                                      "Clouds"
                                                  ? Icons.cloud
                                                  : weatherTemp[index][0] ==
                                                          "Rain"
                                                      ? CupertinoIcons
                                                          .cloud_rain_fill
                                                      : Icons.sunny,
                                              temp: weatherTemp[index][1],
                                              fontSize: 14,
                                            ),
                                          );
                                        },
                                      ),
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
                                    height: 130,
                                    child: ScrollConfiguration(
                                      behavior: ScrollConfiguration.of(context)
                                          .copyWith(
                                        dragDevices: {
                                          PointerDeviceKind.touch,
                                          PointerDeviceKind.mouse,
                                        },
                                      ),
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: forecast!.length - 1,
                                        itemBuilder: (context, index) {
                                          final foreCast = forecast![index + 1];
                                          final time = DateTime.parse(
                                              foreCast["dt_txt"].toString());
                                          final weather =
                                              foreCast["weather"][0]["main"];
                                          return CardWidget(
                                            time: DateFormat("j").format(time),
                                            icon: weather == "Clouds"
                                                ? Icons.cloud
                                                : weather == "Rain"
                                                    ? CupertinoIcons
                                                        .cloud_rain_fill
                                                    : Icons.sunny,
                                            temp: foreCast["main"]["temp"]
                                                .toString(),
                                          );
                                        },
                                      ),
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
  const Additional_Widget({
    super.key,
    required this.icon,
    required this.name,
    required this.number,
    this.boxDecoration,
  });

  final icon;
  final name;
  final number;
  final BoxDecoration? boxDecoration;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: boxDecoration,
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
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
              ),
              const SizedBox(
                height: 5,
              ),
              Text(
                number,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CardWidget extends StatelessWidget {
  const CardWidget(
      {super.key,
      required this.time,
      required this.icon,
      required this.temp,
      this.dayName,
      this.fontSize,
      this.onpress,
      this.boxDecoration});

  final time;
  final icon;
  final temp;
  final String? dayName;
  final double? fontSize;
  final FunctionCall? onpress;
  final BoxDecoration? boxDecoration;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      decoration: boxDecoration,
      margin: const EdgeInsets.all(5),
      padding: const EdgeInsets.all(15),
      child: Column(
        children: [
          dayName == null
              ? Container()
              : Text(
                  dayName!,
                  style: const TextStyle(
                      fontWeight: FontWeight.w500, fontSize: 13),
                ),
          dayName == null
              ? Container()
              : const SizedBox(
                  height: 5,
                ),
          Text(
            time,
            style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: fontSize ?? 20,
                color: fontSize == null ? null : Colors.grey),
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
    );
  }
}
