import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class UserManualFarmer extends StatelessWidget {
  // Define manual sections data
  final List<Map<String, String>> manualSections = [
    {
      'title': 'Soil Nutrient Analysis',
      'content':
          'Understand the critical importance of NPK (Nitrogen, Phosphorus, Potassium) nutrients in your soil. Our sensor kit provides precise measurements to help you optimize crop growth and yield.',
      'imagePath': 'assets/home/images/rice.png',
    },
    {
      'title': 'Sensor Usage Guide',
      'content':
          'Learn how to correctly use the NPK sensor. Insert the probe carefully into the soil, ensuring accurate readings that will guide your fertilization strategies.',
      'imagePath': 'assets/home/images/rice.png',
    },
    {
      'title': 'Interpreting Results',
      'content':
          'Our comprehensive guide helps you understand the sensor readings. Know exactly what each nutrient level means for your specific crops and soil conditions.',
      'imagePath': 'assets/home/images/rice.png',
    },
    {
      'title': 'Maintenance and Care',
      'content':
          'Proper maintenance ensures the longevity and accuracy of your NPK sensor. Follow our expert tips to keep your device in optimal condition.',
      'imagePath': 'assets/home/images/rice.png',
    },
  ];

  UserManualFarmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Manual for Farmers'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // First section with image and text
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.grey[100], // Light background color
                  borderRadius: BorderRadius.circular(8), // Rounded corners
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: Image.asset(
                        'assets/home/images/farmercutout.png',
                        height: 200,
                        width: 170,
                        fit: BoxFit.contain,
                      ),
                    ),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          double fontSize =
                              constraints.maxWidth > 600 ? 16 : 15;

                          return Text(
                            'Thank you for choosing our NPK Sensor Kit! This kit is designed to help you monitor the vital nutrients in your soil, ensuring optimal growth for your crops.',
                            style: TextStyle(
                              fontSize: fontSize,
                              fontWeight: FontWeight.w500,
                              height: 1.6,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.start,
                            softWrap: true,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              const Text(
                'With this kit, you can take control of your farm\'s soil health and improve your crop yield.',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              // ListView for additional sections
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                itemCount: manualSections.length,
                itemBuilder: (context, index) {
                  return _buildManualSection(manualSections[index], index);
                },
              ),
              // Divider(
              //   thickness: 2,
              //   height: 500,
              // ),
              const Text(
                'Overview of our app accuracy',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),

              _buildAccuracyChart(),
            ],
          ),
        ),
      ),
    );
  }

  // Add this method to the UserManualFarmer class
  Widget _buildAccuracyChart() {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(16.0),
      child: PieChart(
        PieChartData(
          centerSpaceRadius: 40,
          sections: [
            PieChartSectionData(
              value: 92,
              color: Colors.green,
              title: 'Accurate\n92%',
              radius: 100,
              titleStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            PieChartSectionData(
              value: 8,
              color: Colors.red,
              title: 'Inaccurate\n8%',
              radius: 100,
              titleStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            PieChartSectionData(
              value: 92,
              color: Colors.blue,
              title: 'Accurate\n92%',
              radius: 100,
              titleStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
          sectionsSpace: 3,
          borderData: FlBorderData(show: false),
        ),
        swapAnimationDuration: const Duration(milliseconds: 150),
        swapAnimationCurve: Curves.linear,
      ),
    );
  }

  Widget _buildManualSection(Map<String, String> section, int index) {
    // Alternate the layout based on even/odd index
    bool isEvenIndex = index % 2 == 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: isEvenIndex
            ? [
                // Content on left, image on right for even indices
                Expanded(
                  child: _buildContent(
                      index + 1, section['title']!, section['content']!),
                ),
                Expanded(
                  child: _buildImage(section['imagePath']!),
                ),
              ]
            : [
                // Image on left, content on right for odd indices
                Expanded(
                  child: _buildImage(section['imagePath']!),
                ),
                Expanded(
                  child: _buildContent(
                      index + 1, section['title']!, section['content']!),
                ),
              ],
      ),
    );
  }

  Widget _buildContent(int sectionNumber, String title, String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Display section number along with the title
          Text(
            '$sectionNumber. $title', // Add the section number before the title
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
            ),
            textAlign: TextAlign.start,
            softWrap: true,
          ),
        ],
      ),
    );
  }

  Widget _buildImage(String imagePath) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Image.asset(
        imagePath,
        height: 200,
        width: 200,
        fit: BoxFit.contain,
      ),
    );
  }
}
