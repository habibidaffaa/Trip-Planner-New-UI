import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:iterasi1/model/itinerary.dart';
import 'package:iterasi1/pages/add_activities/suggestion_page.dart';
import 'package:iterasi1/provider/itinerary_provider.dart';
import 'package:iterasi1/resource/theme.dart';
import 'package:provider/provider.dart';

class FormSuggestion extends StatefulWidget {
  final List<DateTime> selectedDays;

  const FormSuggestion({super.key, required this.selectedDays});

  @override
  FormSuggestionState createState() => FormSuggestionState();
}

class FormSuggestionState extends State<FormSuggestion> {
  bool _isLoading = false;
  // Daftar lokasi statis untuk dropdown
  final List<String> _locations = [
    "Surabaya",
    "Mojokerto",
    "Malang",
    "Kediri",
    "Blitar",
    "Pacitan",
    "Banyuwangi",
    "Probolinggo",
    "Jember",
    "Lumajang",
  ];

  String? _selectedDepartureLocation; // Lokasi Berangkat terpilih
  String? _selectedDestinationLocation; // Lokasi Tujuan terpilih

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColor.whiteColor,
      appBar: AppBar(
        // toolbarHeight: 118,
        backgroundColor: CustomColor.primaryColor500,
        title: Column(
          children: [
            Text(
              'Pilih Lokasi Asal-Tujuan',
              style: primaryTextStyle.copyWith(
                fontWeight: semibold,
                fontSize: 18,
                // fontFamily: 'poppins_bold',
                color: CustomColor.whiteColor,
              ),
              // itineraryProvider.itinerary.title,
            ),
            Text(
              '${DateFormat('dd MMM').format(widget.selectedDays.first)} - ${DateFormat('dd MMM').format(widget.selectedDays.last)}',
              style: primaryTextStyle.copyWith(
                fontSize: 14,
                // fontFamily: 'poppins_bold',
                color: CustomColor.whiteColor,
              ),
              // itineraryProvider.itinerary.title,
            ),
          ],
        ),
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(3.0),
          child: BackButton(
            style: IconButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: CustomColor.whiteColor,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        elevation: 0,
      ),
      body: Container(
        // margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 20,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                scrollDirection: Axis.vertical,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Lokasi Berangkat",
                        style: primaryTextStyle.copyWith(
                          // fontFamily: 'poppins_bold',
                          // fontWeight: semibold,
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 10),
                      PhysicalModel(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                        elevation: 1.0,
                        shadowColor: CustomColor.subtitleTextColor,
                        child: DropdownButtonFormField<String>(
                          value: _selectedDepartureLocation,
                          isExpanded: true,
                          hint: Text(
                            'Pilih Lokasi Berangkat',
                            style: primaryTextStyle.copyWith(
                              color: CustomColor.subtitleTextColor,
                              // fontWeight: semibold,
                              fontSize: 12,
                            ),
                          ),
                          style: primaryTextStyle.copyWith(
                            fontWeight: semibold,
                          ),
                          dropdownColor: CustomColor.whiteColor,
                          items: _locations
                              .map(
                                (location) => DropdownMenuItem<String>(
                                  value: location,
                                  child: Text(
                                    location,
                                    overflow: TextOverflow.ellipsis,
                                    style: primaryTextStyle.copyWith(
                                      fontSize: 12,
                                      // fontWeight: semibold,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(
                              () {
                                _selectedDepartureLocation = value;
                              },
                            );
                          },
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: CustomColor.whiteColor,
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: CustomColor.subtitleTextColor,
                                width: 0.5,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            enabled: !_isLoading,
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: CustomColor.primaryColor600,
                                width: 1,
                              ),
                            ),
                            disabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: CustomColor.subtitleTextColor,
                                width: 0.5,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Lokasi Berangkat",
                        style: primaryTextStyle.copyWith(
                          // fontFamily: 'poppins_bold',
                          // fontWeight: semibold,
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 10),
                      PhysicalModel(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                        elevation: 1.0,
                        shadowColor: CustomColor.subtitleTextColor,
                        child: DropdownButtonFormField<String>(
                          value: _selectedDestinationLocation,
                          isExpanded: true,
                          hint: Text(
                            'Pilih Lokasi Tujuan',
                            style: primaryTextStyle.copyWith(
                              color: CustomColor.subtitleTextColor,
                              // fontWeight: semibold,
                              fontSize: 12,
                            ),
                          ),
                          style: primaryTextStyle.copyWith(
                            fontWeight: semibold,
                          ),
                          dropdownColor: CustomColor.whiteColor,
                          items: _locations
                              .map(
                                (location) => DropdownMenuItem<String>(
                                  value: location,
                                  child: Text(
                                    location,
                                    overflow: TextOverflow.ellipsis,
                                    style: primaryTextStyle.copyWith(
                                      fontSize: 12,
                                      // fontWeight: semibold,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(
                              () {
                                _selectedDestinationLocation = value;
                              },
                            );
                          },
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: CustomColor.whiteColor,
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: CustomColor.subtitleTextColor,
                                width: 0.5,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            enabled: !_isLoading,
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: CustomColor.primaryColor600,
                                width: 1,
                              ),
                            ),
                            disabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: CustomColor.subtitleTextColor,
                                width: 0.5,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  InkWell(
                    onTap: !_isLoading
                        ? (_selectedDepartureLocation != null &&
                                _selectedDestinationLocation != null)
                            ? () async {
                                setState(() {
                                  _isLoading = true;
                                });
                                List<Itinerary> results = await context
                                    .read<ItineraryProvider>()
                                    .generateItineraryByAi(
                                      departure: _selectedDepartureLocation!,
                                      destination:
                                          _selectedDestinationLocation!,
                                      dates: widget.selectedDays,
                                    );

                                setState(() {
                                  _isLoading = false;
                                });
                                Navigator.pop(context);
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => SuggestionPage(
                                      itineraries: results,
                                      // selectedDays: widget.selectedDays,
                                    ),
                                  ),
                                );
                              }
                            : null
                        : null,
                    child: Container(
                      height: 50,
                      // width: 270,
                      decoration: BoxDecoration(
                        color: _isLoading
                            ? CustomColor.disabledColor
                            : CustomColor.primaryColor500,
                        borderRadius: const BorderRadius.all(
                          Radius.circular(100.0),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: _isLoading
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    color: CustomColor.whiteColor,
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  "Loading",
                                  style: primaryTextStyle.copyWith(
                                    color: CustomColor.whiteColor,
                                    fontWeight: semibold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              "SUBMIT",
                              style: primaryTextStyle.copyWith(
                                color: CustomColor.whiteColor,
                                fontWeight: semibold,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                  // TextButton(
                  //   style: TextButton.styleFrom(
                  //     backgroundColor: !_isLoading
                  //         ? (_selectedDepartureLocation != null &&
                  //                 _selectedDestinationLocation != null)
                  //             ? CustomColor.buttonColor
                  //             : Colors.grey
                  //         : Colors.grey,
                  //     shape: RoundedRectangleBorder(
                  //       borderRadius: BorderRadius.circular(12),
                  //     ),
                  //     minimumSize: const Size(double.infinity, 60),
                  //   ),
                  //   onPressed: !_isLoading
                  //       ? (_selectedDepartureLocation != null &&
                  //               _selectedDestinationLocation != null)
                  //           ? () async {
                  //               setState(() {
                  //                 _isLoading = true;
                  //               });
                  //               List<Itinerary> results = await context
                  //                   .read<ItineraryProvider>()
                  //                   .generateItineraryByAi(
                  //                     departure: _selectedDepartureLocation!,
                  //                     destination:
                  //                         _selectedDestinationLocation!,
                  //                     dates: widget.selectedDays,
                  //                   );

                  //               setState(() {
                  //                 _isLoading = false;
                  //               });
                  //               Navigator.pop(context);
                  //               Navigator.of(context).push(
                  //                 MaterialPageRoute(
                  //                   builder: (context) => SuggestionPage(
                  //                     itineraries: results,
                  //                     // selectedDays: widget.selectedDays,
                  //                   ),
                  //                 ),
                  //               );
                  //             }
                  //           : null
                  //       : null,
                  //   child: Text(
                  //     !_isLoading ? 'Submit' : "Loading",
                  //     style: const TextStyle(
                  //       fontFamily: 'poppins_bold',
                  //       fontSize: 20,
                  //       color: Color(0xFFFFFFFF),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
