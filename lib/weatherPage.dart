import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:app_settings/app_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'colors.dart';
import 'searchForm.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  _WeatherPageState createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  String apiKey = 'b301c07a26014a9cbb355734222505';
  String apiUrl = 'https://api.weatherapi.com/v1/forecast.json';
  String locationName = '';
  String weatherIconUrl = '';
  String temperatureCelsius = '';
  String iconDesc = '';
  String forecastDate1 = '';
  String forecastDate2 = '';
  String forecastDate3 = '';
  String forecastMinTemp1 = '';
  String forecastMinTemp2 = '';
  String forecastMinTemp3 = '';
  String forecastMaxTemp1 = '';
  String forecastMaxTemp2 = '';
  String forecastMaxTemp3 = '';
  String forecastIconUrl1 = '';
  String forecastIconUrl2 = '';
  String forecastIconUrl3 = '';
  bool isLoading = false;
  bool isCityFavorite = false;
  int _selectedIndex = 0;
  List<String> favoriteCities = [];

  @override
  void initState() {
    super.initState();
    checkLocationPermissions();
  }

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> checkLocationPermissions() async {
    var serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      AppSettings.openLocationSettings();
    }
    var locationPermissionStatus = await Permission.location.status;
    if (!locationPermissionStatus.isGranted) {
      await AppSettings.openAppSettings();
    }
    var hasPermission = await hasLocationPermission();
    if (hasPermission) {
      var location = await getLocation();
      fetchWeather(location);
    } else {
      fetchWeather("Bulle");
    }
  }

  Future<bool> hasLocationPermission() async {
    var permissionStatus = await Permission.locationWhenInUse.status;
    return permissionStatus.isGranted;
  }

  Future<String> getLocation() async {
    Position position = await Geolocator.getCurrentPosition();
    double latitude = position.latitude;
    double longitude = position.longitude;
    return '$latitude,$longitude';
  }

  Future<void> fetchWeather(String city) async {
    setState(() {
      isLoading = true;
    });

    String url = '$apiUrl?key=$apiKey&q=$city&days=3';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        locationName = data['location']['name'];
        weatherIconUrl = 'https:${data['current']['condition']['icon']}';
        iconDesc = data['current']['condition']['text'];
        temperatureCelsius = '${data['current']['temp_c']}°C';
        final forecastData = data['forecast']['forecastday'];
        forecastDate1 = '${forecastData[0]['date']}';
        forecastDate2 = '${forecastData[1]['date']}';
        forecastDate3 = '${forecastData[2]['date']}';
        forecastMinTemp1 = '${forecastData[0]['day']['mintemp_c']}°C';
        forecastMinTemp2 = '${forecastData[1]['day']['mintemp_c']}°C';
        forecastMinTemp3 = '${forecastData[2]['day']['mintemp_c']}°C';
        forecastMaxTemp1 = '${forecastData[0]['day']['maxtemp_c']}°C';
        forecastMaxTemp2 = '${forecastData[1]['day']['maxtemp_c']}°C';
        forecastMaxTemp3 = '${forecastData[2]['day']['maxtemp_c']}°C';
        forecastIconUrl1 = 'https:${forecastData[0]['day']['condition']['icon']}';
        forecastIconUrl2 = 'https:${forecastData[1]['day']['condition']['icon']}';
        forecastIconUrl3 = 'https:${forecastData[2]['day']['condition']['icon']}';
        isLoading = false;
      });
    } else {
      setState(() {
        locationName = 'Error';
        weatherIconUrl = '';
        iconDesc = '';
        temperatureCelsius = '';
        forecastDate1 = '';
        forecastDate2 = '';
        forecastDate3 = '';
        forecastMinTemp1 = '';
        forecastMinTemp2 = '';
        forecastMinTemp3 = '';
        forecastMaxTemp1 = '';
        forecastMaxTemp2 = '';
        forecastMaxTemp3 = '';
        forecastIconUrl1 = '';
        forecastIconUrl2 = '';
        forecastIconUrl3 = '';
        isLoading = false;
      });
    }
    checkIfCityIsFav(locationName);
  }

  void checkIfCityIsFav(String locationName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    favoriteCities = prefs.getStringList('favoriteCities')?.toList() ?? [];
    setState(() {
      isCityFavorite = favoriteCities.contains(locationName);
    });
  }

  Future<void> addCityFav(String city) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Set<String> favoriteCities = prefs.getStringList('favoriteCities')?.toSet() ?? {};
    if (favoriteCities.contains(city)) {
      favoriteCities.remove(city);
    } else {
      favoriteCities.add(city);
    }
    await prefs.setStringList('favoriteCities', favoriteCities.toList());
    checkIfCityIsFav(locationName);
  }

  void removeCityFromFavorites(String city) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> favoriteCities = prefs.getStringList('favoriteCities')?.toList() ?? [];
    favoriteCities.remove(city);
    await prefs.setStringList('favoriteCities', favoriteCities);
    checkIfCityIsFav(locationName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Météhenchoz'),
        actions: _selectedIndex == 0
            ? [
          IconButton(
            onPressed: () {
              addCityFav(locationName);
            },
            icon: Icon(
              isCityFavorite ? Icons.star : Icons.star_outline_sharp,
              color: isCityFavorite ? Colors.yellow : null,
            ),
          ),
          IconButton(
            onPressed: () {
              checkLocationPermissions();
            },
            icon: const Icon(Icons.location_pin),
          ),
        ]
            : null,
      ),
      body: _selectedIndex == 0 ? buildWeatherTab() : buildFavoritesTab(),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Weather',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: 'Favorites',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: MyColors.meteblue,
        onTap: _onTabSelected,
      ),
    );
  }

  Widget buildWeatherTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  locationName,
                  style: const TextStyle(fontSize: 22),
                ),
              ),
              Image.network(
                weatherIconUrl,
                width: 64,
                height: 64,
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.fromLTRB(16, 10, 32, 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  temperatureCelsius,
                  style: const TextStyle(fontSize: 20),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                iconDesc,
                style: const TextStyle(fontSize: 15),
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(left: 16, right: 16, bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                if (isLoading)
                  const Center(
                    child: CircularProgressIndicator(),
                  ),
                if (!isLoading)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      const Text(
                        'Forecast',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          buildForecastItem(forecastDate1, forecastMinTemp1, forecastMaxTemp1, forecastIconUrl1),
                          buildForecastItem(forecastDate2, forecastMinTemp2, forecastMaxTemp2, forecastIconUrl2),
                          buildForecastItem(forecastDate3, forecastMinTemp3, forecastMaxTemp3, forecastIconUrl3),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: SearchCityForm(fetchWeather: fetchWeather),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget buildForecastItem(String date, String minTemp, String maxTemp, String iconUrl) {
    return Column(
      children: [
        Text(
          date,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Image.network(
          iconUrl,
          width: 32,
          height: 32,
        ),
        const SizedBox(height: 6),
        Text(
          'Min: $minTemp',
          style: const TextStyle(fontSize: 14),
        ),
        Text(
          'Max: $maxTemp',
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  Widget buildFavoritesTab() {
    return ListView.separated(
      itemCount: favoriteCities.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        String city = favoriteCities[index];
        return ListTile(
          title: Text(city),
          trailing: IconButton(
            icon: const Icon(Icons.star, color: Colors.yellow),
            onPressed: () {
              removeCityFromFavorites(city);
            },
          ),
          onTap: () {
            fetchWeather(city);
            _onTabSelected(0);
          },
        );
      },
    );
  }
}