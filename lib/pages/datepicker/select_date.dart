import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:iterasi1/pages/add_activities/form_suggestion.dart';
import 'package:iterasi1/pages/add_days/add_days.dart';
import 'package:iterasi1/provider/database_provider.dart';
import 'package:iterasi1/resource/theme.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../provider/itinerary_provider.dart';

// ignore: must_be_immutable
class SelectDate extends StatefulWidget {
  final bool isNewItinerary;
  List<DateTime> initialDates;
  SelectDate(
      {Key? key, this.initialDates = const [], required this.isNewItinerary})
      : super(key: key);

  @override
  State<SelectDate> createState() => _SelectDateState();
}

class _SelectDateState extends State<SelectDate> {
  late ItineraryProvider itineraryProvider;

  late DatabaseProvider databaseProvider;

  List<DateTime> selectedDates = [];

  @override
  void initState() {
    super.initState();
    // Inisialisasi selectedDates dengan rentang awal

    if (widget.initialDates.isNotEmpty && widget.initialDates.length >= 2) {
      DateTime startDate = widget.initialDates.first;
      DateTime endDate = widget.initialDates.last;
      if (startDate.isBefore(endDate) &&
          startDate.isAfter(DateTime.now().subtract(const Duration(days: 1)))) {
        for (DateTime date = startDate;
            date.isBefore(endDate.add(const Duration(days: 1)));
            date = date.add(const Duration(days: 1))) {
          selectedDates.add(date);
        }
        selectedDates = selectedDates
            .where((date) =>
                date.isAfter(DateTime.now().subtract(const Duration(days: 1))))
            .toList();
      }
    }
  }

  onSimpanDate() {
    if (selectedDates.isNotEmpty) {
      itineraryProvider.initializeDays(selectedDates);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const AddDays(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Pilih Tanggal setelah Hari Ini!"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    itineraryProvider = Provider.of(context, listen: true);
    databaseProvider = Provider.of(context, listen: true);

    return LoaderOverlay(
      child: Scaffold(
        // extendBodyBehindAppBar: true,
        backgroundColor: CustomColor.whiteColor,
        appBar: AppBar(
          // toolbarHeight: 118,
          backgroundColor: CustomColor.primaryColor500,
          title: Text(
            'Pilih Tanggal',
            style: primaryTextStyle.copyWith(
              fontWeight: semibold,
              fontSize: 18,
              // fontFamily: 'poppins_bold',
              color: CustomColor.whiteColor,
            ),
            // itineraryProvider.itinerary.title,
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
        body: Stack(
          children: [
            Column(
              children: [
                Container(
                  color: CustomColor.whiteColor,
                  // padding: const EdgeInsets.only(top: 140),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(15.0),
                        child: SfDateRangePicker(
                          initialDisplayDate: widget.initialDates.isNotEmpty
                              ? widget.initialDates.first
                              : null,
                          initialSelectedRange: widget.initialDates.length >=
                                      2 &&
                                  widget.initialDates.first.isAfter(
                                      DateTime.now()
                                          .subtract(const Duration(days: 1))) &&
                                  widget.initialDates.first
                                      .isBefore(widget.initialDates.last)
                              ? PickerDateRange(
                                  widget.initialDates.first,
                                  widget.initialDates.last,
                                )
                              : null,
                          selectionColor: CustomColor.primaryColor500,
                          startRangeSelectionColor: CustomColor.primaryColor500,
                          endRangeSelectionColor: CustomColor.primaryColor500,
                          rangeSelectionColor: CustomColor.primaryColor100,
                          backgroundColor: CustomColor.whiteColor,
                          todayHighlightColor: CustomColor.subtitleTextColor,
                          selectionTextStyle: const TextStyle(
                            color: Colors.black,
                          ),
                          selectionMode: DateRangePickerSelectionMode.range,
                          showNavigationArrow: true,
                          selectionRadius: 20,
                          minDate: DateTime.now(),
                          onSelectionChanged:
                              (DateRangePickerSelectionChangedArgs? args) {
                            if (args?.value is PickerDateRange) {
                              final PickerDateRange range =
                                  args!.value as PickerDateRange;
                              final DateTime? startDate = range.startDate;
                              final DateTime? endDate = range.endDate;

                              // Jika ada startDate dan endDate, buat daftar tanggal dalam rentang
                              if (startDate != null && endDate != null) {
                                List<DateTime> datesInRange = [];
                                for (DateTime date = startDate;
                                    date.isBefore(
                                        endDate.add(const Duration(days: 1)));
                                    date = date.add(const Duration(days: 1))) {
                                  datesInRange.add(date);
                                }

                                setState(() {
                                  selectedDates = datesInRange
                                      .where(
                                        (date) => date.isAfter(
                                          DateTime.now().subtract(
                                              const Duration(days: 1)),
                                        ),
                                      )
                                      .toList();
                                  log(selectedDates.toString());
                                });
                              } else if (startDate != null) {
                                // Jika hanya startDate yang dipilih (belum ada endDate)
                                setState(() {
                                  selectedDates = [startDate]
                                      .where(
                                        (date) => date.isAfter(
                                          DateTime.now().subtract(
                                              const Duration(days: 1)),
                                        ),
                                      )
                                      .toList();
                                  log(selectedDates.toString());
                                });
                              }
                            }
                          },
                          headerStyle: DateRangePickerHeaderStyle(
                            backgroundColor: CustomColor.whiteColor,
                            textAlign: TextAlign.center,
                            textStyle: primaryTextStyle.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // onSelectionChanged:
            //     (DateRangePickerSelectionChangedArgs? args) {
            //   if (args?.value is List<DateTime>) {
            //     final dates = args?.value as List<Date>Time>;
            //     selectedDates = dates;
            //   }
            // },
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12)),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x19000000),
                      blurRadius: 24,
                      offset: Offset(0, 0),
                    ),
                  ],
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      InkWell(
                        onTap: () {
                          if (widget.isNewItinerary) {
                            if (selectedDates.isNotEmpty) {
                              if (selectedDates.length <= 3) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FormSuggestion(
                                      selectedDays: selectedDates,
                                    ),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        "Tidak dapat menampilkan rekomendasi lebih dari 3 hari!"),
                                  ),
                                );
                              }
                              // itineraryProvider.initializeDays(selectedDates);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text("Pilih Tanggal setelah Hari Ini!"),
                                ),
                              );
                            }
                          } else {
                            onSimpanDate();
                          }
                        },
                        child: Container(
                          height: 50,
                          // width: 270,
                          decoration: BoxDecoration(
                            color: CustomColor.primaryColor500,
                            borderRadius: const BorderRadius.all(
                              Radius.circular(100.0),
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            widget.isNewItinerary
                                ? 'Rekomendasi Itinerary By AI'
                                : 'Simpan',
                            style: primaryTextStyle.copyWith(
                              fontWeight: semibold,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      if (widget.isNewItinerary) const SizedBox(height: 10),
                      if (widget.isNewItinerary)
                        InkWell(
                          onTap: onSimpanDate,
                          child: Container(
                            height: 20,
                            // width: 270,
                            margin: const EdgeInsets.only(bottom: 5, top: 2),
                            decoration: BoxDecoration(
                              color: CustomColor.transparentColor,
                              borderRadius: const BorderRadius.all(
                                Radius.circular(100.0),
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Buat Rencana Sendiri',
                              style: primaryTextStyle.copyWith(
                                decoration: widget.isNewItinerary
                                    ? TextDecoration.underline
                                    : null,
                                fontWeight: regular,
                                fontSize: 12,
                                color: CustomColor.subtitleTextColor,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
