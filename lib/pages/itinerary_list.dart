import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iterasi1/pages/add_days/add_days.dart';
import 'package:iterasi1/pages/datepicker/select_date.dart';
import 'package:iterasi1/provider/database_provider.dart';
import 'package:iterasi1/provider/itinerary_provider.dart';
import 'package:iterasi1/resource/theme.dart';
import 'package:iterasi1/utilities/date_time_formatter.dart';
import 'package:iterasi1/widget/custom_buttom_sheet.dart';
import 'package:iterasi1/widget/itinerary_card.dart';
import 'package:provider/provider.dart';

import '../model/itinerary.dart';

class ItineraryList extends StatefulWidget {
  static const route = "/ItineraryListRoute";

  const ItineraryList({Key? key}) : super(key: key);

  @override
  State<ItineraryList> createState() => _ItineraryListState();
}

class _ItineraryListState extends State<ItineraryList> {
  late ScaffoldMessengerState snackbarHandler;
  TextEditingController searchController = TextEditingController();
  late DatabaseProvider dbProvider;

  @override
  void initState() {
    super.initState();
    dbProvider = Provider.of<DatabaseProvider>(context, listen: false);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _refreshData() {
    setState(() {
      dbProvider.refreshData(filterItineraryName: searchController.text);
    });
  }

  void _unfocusTextField() {
    FocusScope.of(context).unfocus(); // Menghapus fokus dari TextField
  }

  @override
  Widget build(BuildContext context) {
    snackbarHandler = ScaffoldMessenger.of(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Color(0xFFF1F2F6),
      ),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        floatingActionButton: FloatingActionButton(
          elevation: 2,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(100.0))),
          backgroundColor: CustomColor.primary,
          onPressed: () {
            getItineraryTitle(context);
          },
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
        backgroundColor: CustomColor.whiteColor,
        appBar: AppBar(
          centerTitle: false,
          backgroundColor: CustomColor.primary,
          elevation: 0,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Trip Planner',
                style: TextStyle(
                  fontFamily: 'poppins_bold',
                  color: CustomColor.whiteColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 3),
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                color: CustomColor.whiteColor,
                child: const Text(
                  'TRIP SERU, PLANNING GAMPANG',
                  style: TextStyle(
                    fontFamily: 'poppins_bold',
                    color: CustomColor.primary,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        ),
        body: Container(
          margin: const EdgeInsets.only(bottom: 20),
          child: Column(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                color: CustomColor.primaryColor500,
                child: TextFormField(
                  controller: searchController,
                  style: primaryTextStyle.copyWith(
                    fontSize: 14,
                  ),
                  cursorColor: CustomColor.primaryColor500,
                  onChanged: (value) {
                    _refreshData(); // Refresh dengan filter pencarian
                    log('Search input: $value');
                  },
                  decoration: InputDecoration(
                    fillColor: CustomColor.whiteColor,
                    filled: true,
                    hintText: 'Cari Trip Anda',
                    hintStyle: primaryTextStyle.copyWith(
                      color: CustomColor.subtitleTextColor,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius:
                          const BorderRadius.all(Radius.circular(8.0)),
                      borderSide: BorderSide(color: CustomColor.disabledColor),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      borderSide: BorderSide(color: CustomColor.primary),
                    ),
                    prefixIcon: const Padding(
                      padding: EdgeInsets.only(left: 12.0, right: 8),
                      child: Icon(Icons.search),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: FutureBuilder<List<Itinerary>>(
                  future: dbProvider.itineraryDatas,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (snapshot.hasData) {
                      final itineraries = snapshot.data!;
                      if (itineraries.isEmpty) {
                        return const Center(
                            child: Text('Anda belum mempunyai trip.'));
                      }

                      return ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                            vertical: 20, horizontal: 12),
                        itemCount: itineraries.length,
                        separatorBuilder: (context, index) => const SizedBox(
                          height: 20,
                        ),
                        itemBuilder: (context, index) {
                          final itinerary = itineraries[index];
                          return ItineraryCard(
                            parentContext: context,
                            snackbarHandler: snackbarHandler,
                            itinerary: itinerary,
                            dbProvider: dbProvider,
                            onDelete:
                                _refreshData, // Panggil refresh setelah hapus
                          );
                        },
                      );
                    }
                    return const Center(child: Text('No itineraries found'));
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> getItineraryTitle(BuildContext context) async {
    _unfocusTextField(); // Tutup keyboard dan hapus fokus
    final result = await showModalBottomSheet<String>(
      backgroundColor: CustomColor.whiteColor,
      shape: const ContinuousRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(12.0),
        ),
      ),
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return const CustomBottomSheet();
      },
    );

    if (result != null && context.mounted) {
      if (result.isNotEmpty) {
        final today = DateTime.now();

        Provider.of<ItineraryProvider>(context, listen: false).initItinerary(
            Itinerary(
                title: result, dateModified: DateTimeFormatter.toDMY(today)));

        snackbarHandler.removeCurrentSnackBar();

        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) {
              return SelectDate(
                isNewItinerary: true,
              );
            },
          ),
        );
        if (context.mounted) {
          _refreshData(); // Refresh setelah balik dari SelectDate
        }
      }
    }
  }
}
