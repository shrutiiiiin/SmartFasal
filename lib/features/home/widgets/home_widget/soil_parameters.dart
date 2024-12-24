import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class soil_parameters extends StatelessWidget {
  const soil_parameters({
    super.key,
    required this.screenHeight,
    required this.screenWidth,
    required this.gridData,
  });

  final double screenHeight;
  final double screenWidth;
  final List<Map<String, dynamic>> gridData;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
        physics: const BouncingScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: screenHeight * 0.002,
          crossAxisSpacing: screenWidth * 0.02,
          childAspectRatio: 3 / 2,
        ),
        itemCount: gridData.length,
        itemBuilder: (context, index) {
          final item = gridData[index];
          return Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 6, right: 4),
                child: Container(
                  width: screenWidth * 0.44,
                  height: screenHeight * 0.19,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: item['color'],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 8, left: 2),
                            child: Image.asset(
                              item['image'],
                              width: screenWidth * 0.14,
                              height: screenWidth * 0.12,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8, left: 8),
                            child: Text(item['value'],
                                style: const TextStyle(
                                  fontSize: 26,
                                  color: Colors.black,
                                )),
                          )
                        ],
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.only(top: 8, bottom: 8, left: 8),
                        child: Text(
                          item['title'],
                          style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xff000000).withOpacity(0.70)),
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          );
        });
  }
}
