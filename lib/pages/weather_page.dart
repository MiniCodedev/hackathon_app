import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:hackathon_app/constant.dart';
import 'package:flutter/material.dart';
import 'package:hackathon_app/helper/user_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  bool isloading = true;
  String? currentTemp;
  String? pressure;
  String? humidity;
  String? windSpeed;
  String? currentSky;
  List? forecast;
  int selected = 0;

  List<String> date = [];
  String city_ = '';
  TextEditingController userTextField = TextEditingController();
  var weatherData;

  Future getCurrentWeather(
    int index,
  ) async {
    try {
      List newData = [];

      currentTemp = weatherData["list"][index]["main"]["temp"].toString();
      currentSky = weatherData["list"][index]["weather"][0]["main"].toString();
      humidity = weatherData["list"][index]["main"]["humidity"].toString();
      windSpeed = weatherData["list"][index]["wind"]["speed"].toString();
      pressure = weatherData["list"][index]["main"]["pressure"].toString();

      String dtTxt = date[index];
      print(dtTxt);
      for (var entry in weatherData["list"]) {
        if (entry["dt_txt"].toString().contains(dtTxt)) {
          newData.add(entry);
        }
      }
      forecast = newData;
      return newData;
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  void initState() {
    super.initState();
    final userProvider = context.read<UserProvider>();
    city_ = userProvider.city;
    userTextField.text = city_;
  }

  @override
  Widget build(BuildContext context) {
    weatherData = context.watch<UserProvider>().weatherData;
    date = context.watch<UserProvider>().date ?? [];

    final height = MediaQuery.of(context).size.height;
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
      body: weatherData == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: SizedBox(
                      height: 65,
                      child: ListView.builder(
                        itemCount: date.length,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          DateFormat dateFormat = DateFormat("yyyy-MM-dd");
                          DateTime dateTime = dateFormat.parse(date[index]);

                          String dayName = DateFormat('EEEE').format(dateTime);
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selected = index;
                              });
                            },
                            child: Card(
                              color: selected == index ? primaryColor : null,
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  children: [
                                    Text(dayName,
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: selected == index
                                                ? Colors.white
                                                : null)),
                                    Text(
                                      "${date[index].split("-").last}/${date[index].split("-")[1]}",
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w300,
                                          color: selected == index
                                              ? Colors.white
                                              : Colors.grey[500]),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  FutureBuilder(
                    future: getCurrentWeather(selected),
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
                        child: Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
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
                                                    ? CupertinoIcons
                                                        .cloud_rain_fill
                                                    : Icons.sunny,
                                            color: primaryColor,
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
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(10),
                              alignment: Alignment.topLeft,
                              child: const Text(
                                "Hourly Forecast",
                                style: TextStyle(
                                    fontSize: 26, fontWeight: FontWeight.w500),
                              ),
                            ),
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
                                    icon: foreCast["weather"][0]["main"] ==
                                                "Clouds" ||
                                            foreCast["weather"][0]["main"] ==
                                                "Rain"
                                        ? Icons.cloud
                                        : Icons.sunny,
                                    temp: foreCast["main"]["temp"].toString(),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Container(
                              padding:
                                  const EdgeInsets.only(left: 10, right: 10),
                              alignment: Alignment.topLeft,
                              child: const Text(
                                "Additional Information",
                                style: TextStyle(
                                    fontSize: 26, fontWeight: FontWeight.w500),
                              ),
                            ),
                            Row(
                              children: [
                                Additional_Widget(
                                    icon: Icons.water_drop_rounded,
                                    name: "Humidity",
                                    number: "$humidity"),
                                Additional_Widget(
                                  icon: Icons.air_rounded,
                                  name: "Wind Speed",
                                  number: "$windSpeed",
                                ),
                                Additional_Widget(
                                    icon: Icons.beach_access_rounded,
                                    name: "Pressure",
                                    number: "$pressure"),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: TextField(
                      controller: userTextField,
                      onChanged: (value) {
                        city_ = value;
                      },
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          CupertinoIcons.map,
                        ),
                        suffixIcon: IconButton(
                            onPressed: () {
                              context.read<UserProvider>().changeCity(city_);
                            },
                            icon: Icon(
                              CupertinoIcons.cloud_download,
                              color: primaryColor,
                            )),
                        hintText: "City name",
                        border: border,
                        focusedBorder: focusborder,
                      ),
                    ),
                  )
                ],
              ),
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
              color: primaryColor,
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

// ignore: camel_case_types
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
                color: primaryColor,
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
