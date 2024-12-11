import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:innovators/model/location.dart';
import 'package:innovators/model/weather_model/weather_class.dart';
import 'package:innovators/model/weather_model/weather_data.dart';

class WeatherBar extends StatefulWidget {
  final double screenWidth;
  final double screenHeight;

  const WeatherBar({
    super.key,
    required this.screenWidth,
    required this.screenHeight,
  });

  @override
  _WeatherBarState createState() => _WeatherBarState();
}

class _WeatherBarState extends State<WeatherBar> {
  late Future<weathermodel> weatherData;
  LocationHelper locationHelper = LocationHelper();
  String getWeatherWithEmoji(String weather) {
    switch (weather) {
      case 'Clear':
        return '☀️ Sunny';
      case 'Rain':
        return '🌧️ Rainy';
      case 'Clouds':
        return '☁️ Cloudy';
      case 'Snow':
        return '❄️ Snowy';
      case 'Thunderstorm':
        return '⛈️ Stormy';
      case 'Drizzle':
        return '🌦️ Drizzly';
      case 'Mist':
        return '🌫️ Misty';
      case 'Fog':
        return '🌫️ Foggy';
      default:
        return weather;
    }
  }

  String getWeatherEmoji(String weather) {
    switch (weather) {
      case 'Clear':
        return '☀️';
      case 'Rain':
        return '🌧️';
      case 'Clouds':
        return '☁️';
      case 'Snow':
        return '❄️';
      case 'Thunderstorm':
        return '⛈️';
      case 'Drizzle':
        return '🌦️';
      case 'Mist':
        return '🌫️';
      case 'Fog':
        return '🌫️';
      default:
        return '❓'; // Fallback emoji if no match
    }
  }

  @override
  void initState() {
    super.initState();
    weatherData = _getWeatherData();
  }

  Future<weathermodel> _getWeatherData() async {
    await locationHelper.getCurrentLocation();
    return fetchWeather(locationHelper.latitude!, locationHelper.longitude!);
  }

  bool isFavorableForCrops(String weather, double temperature) {
    // Define conditions for favorable weather (example: clear or cloudy weather with moderate temperature)
    if ((weather == 'Clear' || weather == 'Clouds') &&
        (temperature >= 15 && temperature <= 30)) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<weathermodel>(
      future: weatherData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          weathermodel? weather = snapshot.data;
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xffA6EDFF).withOpacity(0.65),
                  const Color(0xffCFF3FC).withOpacity(0.4),
                ],
              ),
            ),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 16, left: 16, bottom: 16),
                  child: Text(
                    getWeatherEmoji(weather!.weather),
                    style: TextStyle(fontSize: widget.screenWidth * 0.15),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          weather.location,
                          style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                              color: Color(0xff000000)),
                        ),
                        const SizedBox(
                          width: 16,
                        ),
                        Text(
                          '${weather.temperature}°C',
                          style: GoogleFonts.poppins(
                            textStyle: TextStyle(
                              fontSize: widget.screenWidth * 0.05,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xff272C69).withOpacity(0.80),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(weather.weather),
                        SizedBox(width: widget.screenWidth * 0.02),
                        Text(
                          isFavorableForCrops(
                                  weather.weather, weather.temperature)
                              ? AppLocalizations.of(context)!.favorable
                              : AppLocalizations.of(context)!.notfavorable,
                          style: TextStyle(
                            color: isFavorableForCrops(
                                    weather.weather, weather.temperature)
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                      ],
                    ),
                    // Text(
                    //   '${weather.temperature}°C',
                    //   style: GoogleFonts.poppins(
                    //     textStyle: TextStyle(
                    //       fontSize: widget.screenWidth * 0.08,
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
                // SizedBox(width: widget.screenWidth * 0.025),
                // Text(
                //   '${weather.temperature}°C',
                //   style: GoogleFonts.poppins(
                //     textStyle: TextStyle(
                //       fontSize: widget.screenWidth * 0.08,
                //     ),
                //   ),
                // ),
              ],
            ),
          );
        } else {
          return const Center(child: Text('No data available'));
        }
      },
    );
  }
}
