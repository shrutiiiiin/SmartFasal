class weathermodel {
  final String location;
  final String weather;
  final double temperature;

  weathermodel(
      {required this.location,
      required this.weather,
      required this.temperature});

  factory weathermodel.fromJson(Map<String, dynamic> json) {
    return weathermodel(
      location: json['name'],
      weather: json['weather'][0]['main'],
      temperature: json['main']['temp'],
    );
  }
}
