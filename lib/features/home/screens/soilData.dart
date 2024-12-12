// import 'package:firebase_database/firebase_database.dart';


// class SoilAnalysisData {
//   double nitrogen;
//   double phosphorus;
//   double potassium;
//   double ph;
//   String fertilizerQuality;

//   SoilAnalysisData({
//     this.nitrogen = 0,
//     this.phosphorus = 0,
//     this.potassium = 0,
//     this.ph = 6.5,
//     this.fertilizerQuality = 'Good',
//   });

//   // Factory method to parse data from Firebase snapshot
//   factory SoilAnalysisData.fromSnapshot(Map<dynamic, dynamic> snapshot) {
//     return SoilAnalysisData(
//       nitrogen: double.tryParse(snapshot['nitrogen']?.toString() ?? '') ?? 0.0,
//       phosphorus:
//           double.tryParse(snapshot['phosphorus']?.toString() ?? '') ?? 0.0,
//       potassium:
//           double.tryParse(snapshot['potassium']?.toString() ?? '') ?? 0.0,
//       ph: double.tryParse(snapshot['pH']?.toString() ?? '') ?? 6.5,
//       fertilizerQuality: 'Good', 
//     );
//   }
// }
