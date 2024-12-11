// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class sensorData extends StatelessWidget {
  final String airQuality;
  final String rainSensor;
  const sensorData({
    super.key,
    required this.airQuality,
    required this.rainSensor,
    required this.screenWidth,
  });

  final double screenWidth;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10, left: 18, right: 12),
          child: Image.asset(
            'assets/home/images/Airquality.png',
            width: screenWidth * 0.15,
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Air Quality',
              style: GoogleFonts.poppins(
                  fontSize: 16, fontWeight: FontWeight.w500),
              softWrap: true,
            ),
            SizedBox(
              height: screenWidth * 0.015,
            ),
            Text(
              airQuality,
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w800, fontSize: 14),
            )
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10, left: 2, right: 12),
          child: Image.asset(
            'assets/home/images/Raindropsensor.png',
            width: screenWidth * 0.15,
          ),
        ),
        SizedBox(
          width: screenWidth * 0.01,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rain Sensor',
              style: GoogleFonts.poppins(
                  fontSize: 16, fontWeight: FontWeight.w500),
              softWrap: true,
            ),
            Text(
              '4096',
              style: GoogleFonts.poppins(
                  fontSize: 14, fontWeight: FontWeight.w800),
            )
          ],
        )
      ],
    );
  }
}
