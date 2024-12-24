import 'package:flutter/material.dart';

// Crop nutrient requirement model
class CropNutrientRequirement {
  final String cropName;
  final double nitrogenNeed; // kg/ha
  final double phosphorusNeed; // kg/ha
  final double potassiumNeed; // kg/ha

  const CropNutrientRequirement({
    required this.cropName,
    required this.nitrogenNeed,
    required this.phosphorusNeed,
    required this.potassiumNeed,
  });
}

// Predefined crop nutrient requirements
class CropNutrientDatabase {
  static final List<CropNutrientRequirement> cropRequirements = [
    const CropNutrientRequirement(
      cropName: 'Wheat',
      nitrogenNeed: 60.0,
      phosphorusNeed: 30.0,
      potassiumNeed: 40.0,
    ),
    const CropNutrientRequirement(
      cropName: 'Rice',
      nitrogenNeed: 80.0,
      phosphorusNeed: 40.0,
      potassiumNeed: 50.0,
    ),
    const CropNutrientRequirement(
      cropName: 'Corn',
      nitrogenNeed: 100.0,
      phosphorusNeed: 50.0,
      potassiumNeed: 60.0,
    ),
    const CropNutrientRequirement(
      cropName: 'Soybean',
      nitrogenNeed: 40.0,
      phosphorusNeed: 20.0,
      potassiumNeed: 30.0,
    ),
  ];

  // Method to find crop requirements
  static CropNutrientRequirement? findCropRequirements(String cropName) {
    try {
      return cropRequirements.firstWhere(
        (crop) => crop.cropName.toLowerCase() == cropName.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }
}

class FertilizerCalculatorPage extends StatefulWidget {
  const FertilizerCalculatorPage({super.key});

  @override
  _FertilizerCalculatorPageState createState() =>
      _FertilizerCalculatorPageState();
}

class _FertilizerCalculatorPageState extends State<FertilizerCalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController cropController = TextEditingController();
  final TextEditingController fieldSizeController = TextEditingController();
  final TextEditingController npkRatioController = TextEditingController();

  // New controllers for custom nutrient inputs
  final TextEditingController nitrogenController = TextEditingController();
  final TextEditingController phosphorusController = TextEditingController();
  final TextEditingController potassiumController = TextEditingController();

  String? result;
  bool isCustomNutrients = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dynamic Fertilizer Calculator"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Crop Type:",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                TextFormField(
                  controller: cropController,
                  decoration: const InputDecoration(
                    hintText: "Enter crop type (e.g., Wheat, Rice)",
                  ),
                  onChanged: (value) {
                    // Automatically fetch predefined requirements
                    final cropReq =
                        CropNutrientDatabase.findCropRequirements(value);
                    if (cropReq != null && !isCustomNutrients) {
                      setState(() {
                        nitrogenController.text =
                            cropReq.nitrogenNeed.toString();
                        phosphorusController.text =
                            cropReq.phosphorusNeed.toString();
                        potassiumController.text =
                            cropReq.potassiumNeed.toString();
                      });
                    }
                  },
                  validator: (value) =>
                      value!.isEmpty ? "Please enter a crop type" : null,
                ),
                const SizedBox(height: 16),
                const Text(
                  "Field Size (in hectares):",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                TextFormField(
                  controller: fieldSizeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: "Enter field size",
                  ),
                  validator: (value) =>
                      value!.isEmpty ? "Please enter the field size" : null,
                ),
                const SizedBox(height: 16),
                const Text(
                  "Fertilizer NPK Ratio (%):",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                TextFormField(
                  controller: npkRatioController,
                  decoration: const InputDecoration(
                    hintText: "Enter NPK ratio (e.g., 20-20-20)",
                  ),
                  validator: (value) =>
                      value!.isEmpty ? "Please enter the NPK ratio" : null,
                ),
                const SizedBox(height: 16),

                // Nutrient Requirement Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Nutrient Requirements (kg/ha):",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Switch(
                      value: isCustomNutrients,
                      onChanged: (bool value) {
                        setState(() {
                          isCustomNutrients = value;
                          if (!value) {
                            // Reset to predefined values if available
                            final cropReq =
                                CropNutrientDatabase.findCropRequirements(
                                    cropController.text);
                            if (cropReq != null) {
                              nitrogenController.text =
                                  cropReq.nitrogenNeed.toString();
                              phosphorusController.text =
                                  cropReq.phosphorusNeed.toString();
                              potassiumController.text =
                                  cropReq.potassiumNeed.toString();
                            }
                          }
                        });
                      },
                    ),
                  ],
                ),
                const Text(
                  "Switch to customize nutrient requirements",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 16),

                // Nitrogen Input
                TextFormField(
                  controller: nitrogenController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Nitrogen Requirement (kg/ha)",
                    hintText: "Enter nitrogen requirement",
                  ),
                  validator: (value) => value!.isEmpty
                      ? "Please enter nitrogen requirement"
                      : null,
                  enabled: isCustomNutrients,
                ),
                const SizedBox(height: 16),

                // Phosphorus Input
                TextFormField(
                  controller: phosphorusController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Phosphorus Requirement (kg/ha)",
                    hintText: "Enter phosphorus requirement",
                  ),
                  validator: (value) => value!.isEmpty
                      ? "Please enter phosphorus requirement"
                      : null,
                  enabled: isCustomNutrients,
                ),
                const SizedBox(height: 16),

                // Potassium Input
                TextFormField(
                  controller: potassiumController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Potassium Requirement (kg/ha)",
                    hintText: "Enter potassium requirement",
                  ),
                  validator: (value) => value!.isEmpty
                      ? "Please enter potassium requirement"
                      : null,
                  enabled: isCustomNutrients,
                ),
                const SizedBox(height: 32),

                Center(
                  child: ElevatedButton(
                    onPressed: _calculateFertilizer,
                    child: const Text("Calculate"),
                  ),
                ),
                const SizedBox(height: 16),
                if (result != null)
                  Text(
                    result!,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _calculateFertilizer() {
    if (_formKey.currentState!.validate()) {
      final cropType = cropController.text.trim();
      final fieldSize = double.tryParse(fieldSizeController.text) ?? 0.0;
      final npkRatio = npkRatioController.text.trim();

      // Parse NPK values
      final npkValues =
          npkRatio.split("-").map((e) => double.tryParse(e) ?? 0.0).toList();
      if (npkValues.length != 3) {
        setState(() {
          result = "Invalid NPK ratio format. Use the format '20-20-20'.";
        });
        return;
      }

      final nitrogenPercentage = npkValues[0];
      final phosphorusPercentage = npkValues[1];
      final potassiumPercentage = npkValues[2];

      // Parse custom or predefined nutrient requirements
      final nitrogenNeed = double.tryParse(nitrogenController.text) ?? 0.0;
      final phosphorusNeed = double.tryParse(phosphorusController.text) ?? 0.0;
      final potassiumNeed = double.tryParse(potassiumController.text) ?? 0.0;

      // Fertilizer dosage calculations
      final nitrogenFertilizer =
          (nitrogenNeed / (nitrogenPercentage / 100)) * fieldSize;
      final phosphorusFertilizer =
          (phosphorusNeed / (phosphorusPercentage / 100)) * fieldSize;
      final potassiumFertilizer =
          (potassiumNeed / (potassiumPercentage / 100)) * fieldSize;

      setState(() {
        result = """
Crop: $cropType
Field Size: ${fieldSize.toStringAsFixed(2)} hectares

Nutrient Requirements:
- Nitrogen: $nitrogenNeed kg/ha
- Phosphorus: $phosphorusNeed kg/ha
- Potassium: $potassiumNeed kg/ha

Recommended Fertilizer Dosage:
- Nitrogen: ${nitrogenFertilizer.toStringAsFixed(2)} kg
- Phosphorus: ${phosphorusFertilizer.toStringAsFixed(2)} kg
- Potassium: ${potassiumFertilizer.toStringAsFixed(2)} kg

Mix fertilizers proportionally for balanced crop growth.
        """;
      });
    }
  }

  @override
  void dispose() {
    // Dispose of controllers to prevent memory leaks
    cropController.dispose();
    fieldSizeController.dispose();
    npkRatioController.dispose();
    nitrogenController.dispose();
    phosphorusController.dispose();
    potassiumController.dispose();
    super.dispose();
  }
}
