import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hackathon_app/helper/user_provider.dart';
import 'package:hackathon_app/pages/home_page.dart';
import 'package:hackathon_app/pages/weather_page.dart';
import 'constant.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(ChangeNotifierProvider<UserProvider>(
    create: (context) => UserProvider(),
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<UserProvider>().getWeatherData();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const BottomNaavigationPage(),
      theme: ThemeData(
        appBarTheme: AppBarTheme(
            foregroundColor: Colors.white, backgroundColor: primaryColor),
        fontFamily: "Poppins",
        colorSchemeSeed: primaryColor,
        brightness: Brightness.light,
        useMaterial3: true,
      ),
    );
  }
}

class BottomNaavigationPage extends StatefulWidget {
  const BottomNaavigationPage({super.key});

  @override
  State<BottomNaavigationPage> createState() => _BottomNaavigationPageState();
}

class _BottomNaavigationPageState extends State<BottomNaavigationPage> {
  int selectedPage = 0;
  List pages = const [HomePage(), WeatherPage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[selectedPage],
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: selectedPage,
          onTap: (value) {
            setState(() {
              selectedPage = value;
            });
          },
          items: [
            BottomNavigationBarItem(
              label: "home",
              icon: const Icon(Icons.home_rounded),
              activeIcon: Icon(
                Icons.home_rounded,
                color: primaryColor,
              ),
            ),
            BottomNavigationBarItem(
                label: "Weather",
                icon: const Icon(CupertinoIcons.cloud_sun_rain_fill),
                activeIcon: Icon(
                  CupertinoIcons.cloud_sun_rain_fill,
                  color: primaryColor,
                ))
          ]),
    );
  }
}
