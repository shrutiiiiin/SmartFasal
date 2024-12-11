// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// class Crop_recommendation extends StatelessWidget {
//   final String recommendedCrop;
//   const Crop_recommendation({
//     super.key,
//     required this.screenWidth,
//     required this.screenHeight,
//     required this.recommendedCrop,
//   });

//   final double screenWidth;
//   final double screenHeight;

//   @override
//   Widget build(BuildContext context) {
//     // Adjust the radius here by changing width and height
//     double imageRadius = screenWidth * 0.20;

//     return Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(10),
//         color: const Color(0xffDAFFEC),
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             child: Padding(
//               padding: const EdgeInsets.only(
//                 left: 8,
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.only(top: 16),
//                     child: Text(
//                       AppLocalizations.of(context)!.cropbasedonrecommendation,
//                       style: GoogleFonts.poppins(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ),
//                   SizedBox(
//                     height: screenHeight * 0.01,
//                   ),
//                   Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         AppLocalizations.of(context)!.recommendcrop,
//                         style: GoogleFonts.poppins(
//                           fontSize: 14,
//                           fontWeight: FontWeight.w700,
//                         ),
//                       ),
//                       SizedBox(
//                         width: screenWidth * 0.014,
//                       ),
//                       Text(
//                         AppLocalizations.of(context)!.cropname,
//                         style: GoogleFonts.poppins(
//                           fontSize: 14,
//                           fontWeight: FontWeight.w500,
//                           color: const Color(0xff000000).withOpacity(0.70),
//                         ),
//                       ),
//                     ],
//                   ),
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       SizedBox(
//                         height: screenHeight * 0.01,
//                       ),
//                       // Text(
//                       //   'Recommendation:',
//                       //   style: GoogleFonts.poppins(
//                       //     fontSize: 14,
//                       //     fontWeight: FontWeight.w700,
//                       //   ),
//                       // ),
//                       // Text(
//                       //   'Consider planting $recommendedCrop for better yield in this season.',
//                       //   softWrap: true,
//                       //   style: GoogleFonts.poppins(
//                       //     fontSize: 14,
//                       //     fontWeight: FontWeight.w500,
//                       //     color: const Color(0xff000000).withOpacity(0.70),
//                       //   ),
//                       // ),
//                       SizedBox(
//                         height: screenHeight * 0.01,
//                       ),
//                       // Text(
//                       //   'Condition:',
//                       //   style: GoogleFonts.poppins(
//                       //     fontSize: 14,
//                       //     fontWeight: FontWeight.w700,
//                       //   ),
//                       // ),
//                       // Padding(
//                       //   padding: const EdgeInsets.only(bottom: 10),
//                       //   child: Text(
//                       //     'Soil nutrients are suitable, and weather is warm enough.',
//                       //     style: GoogleFonts.poppins(
//                       //       fontSize: 14,
//                       //       fontWeight: FontWeight.w500,
//                       //       color: const Color(
//                       //         0xff000000,
//                       //       ).withOpacity(0.70),
//                       //     ),
//                       //   ),
//                       // ),
//                     ],
//                   )
//                 ],
//               ),
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }
