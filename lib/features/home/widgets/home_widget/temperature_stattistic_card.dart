import 'package:flutter/material.dart';

class TemperatureStattisticCard extends StatefulWidget {
  const TemperatureStattisticCard({super.key});

  @override
  State<TemperatureStattisticCard> createState() =>
      _TemperatureStattisticCardState();
}

class _TemperatureStattisticCardState extends State<TemperatureStattisticCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 95,
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: ShapeDecoration(
        gradient: const LinearGradient(
          begin: Alignment(0.94, -0.34),
          end: Alignment(-0.94, 0.34),
          colors: [
            Color(0xFFA5EDFF),
            Color(0xFFCEF2FB),
          ],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}
