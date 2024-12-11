import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:innovators/model/weather_model/weather_class.dart';

Future<weathermodel> fetchWeather(double latitude, double longitude) async {
  const apiKey =
      '496781d96d32d174fdb6b60abc1f211f'; // Replace with your API key
  final url =
      'https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&appid=$apiKey&units=metric';

  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    return weathermodel.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to load weather data');
  }
}
