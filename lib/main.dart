import 'package:flutter/material.dart';
import 'colors.dart';
import 'weatherPage.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Météhenchoz',
      theme: ThemeData(
        primarySwatch: MyColors.meteblue,
        appBarTheme: const AppBarTheme(
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
      ),
      home: const WeatherPage(),
    );
  }
}