import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:iterasi1/model/activity.dart';
import 'package:iterasi1/model/day.dart';
import 'package:iterasi1/model/itinerary.dart';
import 'package:iterasi1/pages/add_days/add_days.dart';
import 'package:iterasi1/provider/itinerary_provider.dart';
import 'package:iterasi1/resource/theme.dart';
import 'package:iterasi1/utilities/app_helper.dart';
import 'package:iterasi1/widget/recommendaation_activity_card.dart';
import 'package:provider/provider.dart';

class SuggestionPage extends StatefulWidget {
  final List<Itinerary> itineraries;
  const SuggestionPage({
    super.key,
    required this.itineraries,
  });

  @override
  _SuggestionPageState createState() => _SuggestionPageState();
}

class _SuggestionPageState extends State<SuggestionPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.itineraries.length < 2) {
      return const Scaffold(
        body: Center(child: Text("Data itinerary tidak cukup")),
      );
    }

    return Scaffold(
      backgroundColor: CustomColor.whiteColor,
      appBar: AppBar(
        backgroundColor: CustomColor.primary,
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
        title: Text(
          "Rekomendasi Itinerary",
          style: primaryTextStyle.copyWith(
            fontSize: 18,
            fontWeight: semibold,
            color: CustomColor.surface,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            color: CustomColor.whiteColor,
            child: TabBar(
              controller: _tabController,
              indicatorColor: CustomColor.primaryColor600,
              indicatorWeight: 3,
              labelColor: CustomColor.primaryColor600,
              unselectedLabelColor: CustomColor.subtitleTextColor,
              labelStyle: primaryTextStyle.copyWith(
                fontWeight: semibold,
              ),
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
                _buildItineraryContent(index: 0),
                _buildItineraryContent(index: 1),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: CustomColor.whiteColor,
          boxShadow: const [
            BoxShadow(
              color: Color(0x19000000),
              blurRadius: 24,
              offset: Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: CustomColor.primaryColor500,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100),
            ),
            // padding: const EdgeInsets.symmetric(vertical: 16),
            minimumSize: const Size(double.infinity, 48),
          ),
          onPressed: () {
            log('Itinerary terpilih: ${_tabController.index}');
            for (var i = 0;
                i < widget.itineraries[_tabController.index].days.length;
                i++) {
              Day newDay = widget.itineraries[_tabController.index].days[i];
              context.read<ItineraryProvider>().addDay(newDay);
            }
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const AddDays(),
              ),
            );
          },
          child: Text(
            "PILIH",
            style: primaryTextStyle.copyWith(
              fontSize: 18,
              fontWeight: semibold,
              color: CustomColor.surface,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItineraryContent({required int index}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shrinkWrap: true,
        itemCount: widget.itineraries[index].days.length,
        separatorBuilder: (context, index) {
          return const SizedBox(height: 10);
        },
        itemBuilder: (context, indexDay) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: CustomColor.disabledColor,
                  borderRadius: const BorderRadius.all(
                    Radius.circular(100.0),
                  ),
                ),
                child: Text(
                  "Hari ke-${indexDay + 1} ${AppHelper.formatDate(widget.itineraries[index].days[indexDay].date)}",
                  style: primaryTextStyle.copyWith(
                    fontSize: 14,
                    color: CustomColor.blackColor,
                    // fontWeight: semibold,
                    // fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 10),
              ListView.separated(
                physics: NeverScrollableScrollPhysics(),
                separatorBuilder: (context, index) {
                  return SizedBox(height: 10);
                },
                shrinkWrap: true,
                itemCount:
                    widget.itineraries[index].days[indexDay].activities.length,
                itemBuilder: (context, indexActivity) {
                  List<Activity> activities =
                      widget.itineraries[index].days[indexDay].activities;
                  return RecommendaationActivityCard(
                    data: activities[indexActivity],
                  );
                },
              ),
              SizedBox(height: 10),
            ],
          );
        },
      ),
    );
  }
}
