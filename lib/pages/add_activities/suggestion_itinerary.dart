import 'package:flutter/material.dart';
import 'package:iterasi1/model/day.dart';
import 'package:iterasi1/utilities/date_time_formatter.dart';
import 'package:provider/provider.dart';
import 'package:iterasi1/model/activity.dart';
import 'package:iterasi1/model/itinerary.dart';
import 'package:iterasi1/pages/add_days/add_days.dart';
import 'package:iterasi1/provider/itinerary_provider.dart';
import 'package:iterasi1/resource/theme.dart';

class SuggestionItinerary extends StatefulWidget {
  final List<Itinerary> itineraries;
  final List<DateTime> selectedDays;
  const SuggestionItinerary({
    super.key,
    required this.itineraries,
    required this.selectedDays,
  });

  @override
  _SuggestionItineraryState createState() => _SuggestionItineraryState();
}

class _SuggestionItineraryState extends State<SuggestionItinerary>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColor.whiteColor,
      appBar: AppBar(
        backgroundColor: CustomColor.primary,
        title: const Text(
          "Rekomendasi Itinerary",
          style: TextStyle(
            fontFamily: 'poppins_bold',
            fontSize: 20,
            color: CustomColor.surface,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            color: CustomColor.surface,
            child: TabBar(
              controller: _tabController,
              indicatorColor: CustomColor.buttonColor,
              indicatorWeight: 3,
              labelColor: CustomColor.buttonColor,
              unselectedLabelColor: Colors.black,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              tabs: const [
                Tab(text: "Rekomendasi 1"),
                Tab(text: "Rekomendasi 2"),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildItineraryContent(index: _tabController.index),
                _buildItineraryContent(
                    index:
                        _tabController.index), // Ganti konten jika diperlukan
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: CustomColor.buttonColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
                minimumSize: const Size(double.infinity, 48),
              ),
              onPressed: () {
                for (var i = 0; i < widget.selectedDays.length; i++) {
                  String date = DateTimeFormatter.toDMY(widget.selectedDays[i],
                      separator: "/");
                  Day newDay = Day(
                    date: date,
                    activities: widget
                        .itineraries[_tabController.index].days[i].activities,
                  );
                  context.read<ItineraryProvider>().addDay(newDay);
                }
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AddDays(),
                  ),
                );
              },
              child: const Text(
                "Pilih",
                style: TextStyle(
                  fontFamily: 'poppins_bold',
                  fontSize: 20,
                  color: CustomColor.surface,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildActivityCard(
    BuildContext context,
    Activity activity, {
    required int dayIndex,
    required int activityIndex,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: CustomColor.primary,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        activity.activityName,
                        textAlign: TextAlign.left,
                        style: const TextStyle(
                          fontFamily: 'poppins_bold',
                          fontSize: 16,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          IconData(0xe055, fontFamily: 'MaterialIcons'),
                          color: Colors.white,
                          size: 14,
                        ),
                        const SizedBox(
                          width: 9,
                        ),
                        Expanded(
                          child: Text(
                            activity.lokasi,
                            textAlign: TextAlign.left,
                            style: const TextStyle(
                              fontFamily: 'poppins_bold',
                              fontSize: 14,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Column(
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time_outlined,
                          color: Colors.white,
                          size: 14,
                        ),
                        const SizedBox(
                          width: 9,
                        ),
                        Text(
                          "${activity.startActivityTime} - ${activity.endActivityTime}",
                          style: const TextStyle(
                            fontFamily: 'poppins_bold',
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        )
                      ],
                    ),
                  ],
                ),
                Text(
                  activity.keterangan,
                  style: const TextStyle(
                    fontFamily: 'poppins_regular',
                    fontSize: 10,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItineraryContent({required int index}) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: ListView.separated(
        shrinkWrap:
            true, // ListView ini akan menyesuaikan ukurannya dengan konten
        itemCount: widget.itineraries[index].days.length,
        separatorBuilder: (context, index) {
          return Divider(
            height: 5,
          );
        },
        itemBuilder: (context, indexDay) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'HARI KE-${indexDay + 1}, ${widget.selectedDays[indexDay]}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              // Gunakan shrinkWrap: true untuk ListView.builder
              ListView.separated(
                physics: NeverScrollableScrollPhysics(),
                separatorBuilder: (context, index) {
                  return SizedBox(
                    height: 10,
                  );
                },
                shrinkWrap: true, // Menyesuaikan ukuran berdasarkan konten
                itemCount:
                    widget.itineraries[index].days[indexDay].activities.length,
                itemBuilder: (context, indexActivity) {
                  List<Activity> activities =
                      widget.itineraries[index].days[indexDay].activities;
                  return buildActivityCard(
                    context,
                    activities[indexActivity],
                    dayIndex: indexDay,
                    activityIndex: indexActivity,
                  );
                },
              ),
              SizedBox(
                height: 10,
              ),
            ],
          );
        },
      ),
    );
  }
}
