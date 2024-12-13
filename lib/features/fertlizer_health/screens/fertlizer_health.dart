import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AIScheduling extends StatefulWidget {
  const AIScheduling({super.key});

  @override
  State<AIScheduling> createState() => _AISchedulingState();
}

class _AISchedulingState extends State<AIScheduling>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late DateTime _selectedDateTime;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
    );
    _selectedDateTime = DateTime.now();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      );
      if (pickedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fertlizer Health'),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(30),
              ),
              child: TabBar(
                dividerColor: Colors.transparent,
                controller: _tabController,
                indicator: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(30),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.black,
                labelPadding: EdgeInsets.zero,
                padding: const EdgeInsets.all(4),
                tabs: [
                  _buildTab(AppLocalizations.of(context)!.fertilizer_health),
                  _buildTab(AppLocalizations.of(context)!.manual),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          height: 190,
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          decoration: ShapeDecoration(
                            color: const Color(0xBAF6E764),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    AppLocalizations.of(context)!.progress,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                      color: Colors.black,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Container(
                                    width: 45,
                                    height: 45,
                                    decoration: const ShapeDecoration(
                                        color: Colors.white,
                                        shape: OvalBorder(),
                                        image: DecorationImage(
                                          image: AssetImage(
                                              'assets/Ai_scheduling/icon.png'),
                                        )),
                                  )
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    '65 %',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                      color: const Color(0xFF3962CA),
                                      fontSize: 36,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 16,
                                  ),
                                  Text(
                                    AppLocalizations.of(context)!
                                        .fertilizer_health_healthy,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  )
                                ],
                              ),
                              Container(
                                width: 354,
                                height: 12,
                                decoration: ShapeDecoration(
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 60,
                                        child: Container(
                                          color: Colors.blue,
                                        ),
                                      ),
                                      Expanded(
                                        flex: 40,
                                        child: Container(),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    AppLocalizations.of(context)!
                                        .organic_matter,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                      color: Colors.black,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 8,
                                  ),
                                  // Text(
                                  //   'Watering in progress 💧',
                                  //   textAlign: TextAlign.center,
                                  //   style: GoogleFonts.poppins(
                                  //     color: Colors.black,
                                  //     fontSize: 13,
                                  //     fontWeight: FontWeight.w400,
                                  //     height: 0.09,
                                  //   ),
                                  // )
                                ],
                              ),
                              Text(
                                AppLocalizations.of(context)!.next_schedule,
                                style: GoogleFonts.poppins(
                                  color: Colors.black,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w400,
                                ),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              AppLocalizations.of(context)!.usage,
                              style: GoogleFonts.poppins(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: width * 0.41,
                                height: 145,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 6,
                                ),
                                decoration: ShapeDecoration(
                                  color: const Color(0xFFFBF2E6),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    const Text(
                                      '📈',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 40,
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    Text(
                                      '20%',
                                      style: GoogleFonts.poppins(
                                        color: Colors.black,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      AppLocalizations.of(context)!.yield_inc,
                                      style: GoogleFonts.poppins(
                                        color: Colors.black,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Container(
                                width: width * 0.41,
                                height: 140,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 10,
                                ),
                                decoration: ShapeDecoration(
                                  color: const Color(0xFFF1F4FF),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      '🌱',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 40,
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    Text(
                                      AppLocalizations.of(context)!.yield,
                                      style: GoogleFonts.poppins(
                                        color: Colors.black,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      AppLocalizations.of(context)!
                                          .fertilizer_efficiency,
                                      style: GoogleFonts.poppins(
                                        color: Colors.black,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 24,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          height: 202,
                          decoration: ShapeDecoration(
                            color: const Color(0x70AFF5CF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    AppLocalizations.of(context)!
                                        .fertilizer_healthsection,
                                    style: GoogleFonts.poppins(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      height: 0,
                                    ),
                                  ),
                                  Container(
                                    width: 45,
                                    height: 45,
                                    decoration: const ShapeDecoration(
                                      color: Colors.white,
                                      shape: OvalBorder(),
                                      image: DecorationImage(
                                        image: AssetImage(
                                          'assets/Ai_scheduling/icon.png',
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                width: 338,
                                height: 100,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 16,
                                ),
                                decoration: ShapeDecoration(
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Time & Date',
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.poppins(
                                            color: Colors.black,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: _selectDateTime,
                                          child: Container(
                                            width: 40,
                                            height: 40,
                                            margin: const EdgeInsets.only(
                                                right: 16),
                                            decoration: const ShapeDecoration(
                                              color: Color(0x91D9D9D9),
                                              shape: OvalBorder(),
                                              image: DecorationImage(
                                                image: AssetImage(
                                                  'assets/Ai_scheduling/edit_icon.png',
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Row(
                                          children: [
                                            Image.asset(
                                              'assets/Ai_scheduling/clock_icon.png',
                                            ),
                                            const SizedBox(
                                              width: 8,
                                            ),
                                            Text(
                                              DateFormat('hh:mm')
                                                  .format(_selectedDateTime),
                                              textAlign: TextAlign.center,
                                              style: GoogleFonts.poppins(
                                                color: const Color(0xFF494E54),
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 4,
                                            ),
                                            Text(
                                              DateFormat('a')
                                                  .format(_selectedDateTime),
                                              textAlign: TextAlign.center,
                                              style: GoogleFonts.poppins(
                                                color: const Color(0xFF494E54),
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          width: 24,
                                        ),
                                        Text(
                                          DateFormat('dd MMM, yyyy')
                                              .format(_selectedDateTime),
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.poppins(
                                            color: const Color(0xFF494E54),
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            height: 0.09,
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  // Content for 'Manual' tab
                  const Center(
                    child: Text(
                      'Manual tab content',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String text) {
    return Container(
      height: 40,
      alignment: Alignment.center,
      child: Text(text),
    );
  }
}
