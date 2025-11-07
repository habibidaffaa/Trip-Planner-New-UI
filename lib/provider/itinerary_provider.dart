import 'dart:convert';
import 'dart:developer';

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:iterasi1/model/activity.dart';
import 'package:iterasi1/model/day.dart';
import 'package:iterasi1/model/itinerary.dart';
import 'package:iterasi1/service/itinerary_service.dart';

class ItineraryProvider extends ChangeNotifier {
  final ItineraryService _itineraryService = ItineraryService();
  late Itinerary _itinerary;
  late Itinerary initialItinerary;
  bool _isLoading = false;
  Itinerary get itinerary => _itinerary;

  bool get isDataChanged =>
      _itinerary.toJsonString() != initialItinerary.toJsonString();

  void initItinerary(Itinerary newItinerary) {
    _itinerary = newItinerary.copy();
    initialItinerary = newItinerary.copy();
    notifyListeners();
  }

  void setNewItineraryTitle(String newTitle) {
    _itinerary.title = newTitle;
  }

  void addDay(Day newDay) {
    try {
      _itinerary.days = [..._itinerary.days, newDay];
    } catch (e) {
      log("$e", name: 'qqq');
    }
    notifyListeners();
  }

  void initializeDays(List<DateTime> dates) {
    List<DateTime> sortedNewDates = dates..sort();

    List<DateTime> currentDates =
        _itinerary.days.map((e) => e.getDatetime()).toList();

    List<Day> finalDays = [];

    var i = 0;
    var j = 0;
    // Push semua currentDates yang gak ada di sortedNewDates
    while (i < sortedNewDates.length && j < currentDates.length) {
      if (currentDates[j].isBefore(sortedNewDates[i])) {
        j++;
      } else if (currentDates[j].isAfter(sortedNewDates[i]))
        finalDays.add(Day.from(sortedNewDates[i++]));
      else {
        finalDays.add(_itinerary.days[j].copy());
        j++;
        i++;
      }
    }
    while (i < sortedNewDates.length) {
      finalDays.add(Day.from(sortedNewDates[i++]));
    }

    _itinerary.days = finalDays;
    log('final : ${_itinerary.days[0].date}');

    notifyListeners();
  }

  List<Day> getDateTime() {
    return _itinerary.days;
  }

  // String convertDateTimeToString({required DateTime dateTime}) =>
  //     "${dateTime.day}/" "${dateTime.month}/" "${dateTime.year}";

  void updateActivity({
    required int updatedDayIndex,
    required int updatedActivityIndex,
    required Activity newActivity,
  }) {
    _itinerary = itinerary.copy(
        days: itinerary.days.mapIndexed((index, day) {
      if (index == updatedDayIndex) {
        return day.copy(
            activities: day.activities.mapIndexed((index, activity) {
          if (index == updatedActivityIndex) {
            return newActivity;
          }
          return activity;
        }).toList());
      }
      return day;
    }).toList());
    notifyListeners();
  }

  void insertNewActivity(
      {required List<Activity> activities, required Activity newActivity}) {
    print('new activity :${newActivity.endDateTime}');
    activities.add(newActivity);
    notifyListeners();
  }

  void removeActivity(
      {required List<Activity> activities, required int removedHashCode}) {
    activities.removeWhere((element) => element.hashCode == removedHashCode);
    notifyListeners();
  }

  void addPhotoActivity(
      {required Activity activity, required String pathImage}) {
    activity.images!.add(pathImage);
    log("ADD IMAGE $pathImage");
    notifyListeners();
  }

  void removePhotoActivity({
    required Activity activity,
    required String pathImage,
  }) {
    activity.removedImages!.add(pathImage);
    log("ADD TO REMOVED IMAGE $pathImage");
    log("removed images" + activity.removedImages.toString());
    notifyListeners();
  }

  void returnPhotoActivity({
    required Activity activity,
    required String pathImage,
  }) {
    activity.removedImages!.remove(pathImage);
    log("RETURN IMAGE $pathImage");
    log("removed images${activity.removedImages}");
    notifyListeners();
  }

  void cleanPhotoActivity({
    required Activity activity,
  }) {
    activity.images = [];
    log("CLEANING");
    notifyListeners();
  }

  Future<List<Activity>> getSortedActivity(List<Activity> activities) async {
    return activities
      ..sort((a, b) {
        return a.startDateTime.compareTo(b.startDateTime);
      });
  }

  List<String> getImage(Activity activity) {
    return activity.images!;
  }

  Future<List<Itinerary>> parseJsonToItinerary(
      String asal, String tujuan, int jumlahHari) async {
    // Baca file JSON dari assets
    final rawData = await rootBundle.loadString('assets/data.json');

    // Parse JSON
    Map<String, dynamic> jsonData = jsonDecode(rawData);
    List<dynamic> itinerariesJson = jsonData['itineraries'];

    List<Itinerary> itineraries = [];

    // Gabungkan asal dan tujuan menjadi satu string format "asal-tujuan"
    String asalTujuan = "$asal-$tujuan";

    // Loop untuk mencari kecocokan lokasi di JSON
    for (var itineraryJson in itinerariesJson) {
      String location = itineraryJson['ASAL'];

      // Cek apakah lokasi dalam format asal-tujuan cocok
      if (asalTujuan == location) {
        String hasilItineraryKeyA = 'HASIL $jumlahHari HARI - A';
        String hasilItineraryKeyB = 'HASIL $jumlahHari HARI - B';

        // Mengambil hasil itinerary yang sesuai berdasarkan jumlahHari
        String hasilItinerary1 = itineraryJson[hasilItineraryKeyA] ?? '';
        String hasilItinerary2 = itineraryJson[hasilItineraryKeyB] ?? '';

        // Pisahkan hasil itinerary menjadi List<Day>
        List<Day> days1 = splitItineraryToDays(hasilItinerary1);
        List<Day> days2 = splitItineraryToDays(hasilItinerary2);

        // Menambahkan itinerary pertama dan kedua
        itineraries.add(Itinerary(
          title: 'Rekomendasi A',
          dateModified: DateTime.now().toString(),
          days: days1,
        ));

        itineraries.add(Itinerary(
          title: 'Rekomendasi B',
          dateModified: DateTime.now().toString(),
          days: days2,
        ));
      }
    }

    return itineraries;
  }

  List<Day> splitItineraryToDays(String itinerary) {
    List<Day> days = [];

    // Pisahkan berdasarkan HARI KE-X (menggunakan regex untuk menangkap setiap hari)
    final dayRegex =
        RegExp(r'HARI KE-(\d+)[\s\S]+?(?=HARI KE-\d+|$)', caseSensitive: false);
    final matches = dayRegex.allMatches(itinerary);

    for (final match in matches) {
      final dayActivitiesText = match.group(0) ?? '';

      // Pisahkan setiap aktivitas dalam hari ini dengan regex yang lebih spesifik
      final activityRegex = RegExp(
          r'Judul: (.*?)\nMulai: (.*?)\nEstimasi Selesai: (.*?)\nTempat: (.*?)\nInformasi Tambahan: (.*?)\n',
          caseSensitive: false);

      List<Activity> activities = [];
      final activityMatches = activityRegex.allMatches(dayActivitiesText);

      // Proses setiap aktivitas
      for (final activityMatch in activityMatches) {
        final activityName = activityMatch.group(1)?.trim() ?? '';
        final startActivityTime = activityMatch.group(2)?.trim() ?? '';
        final endActivityTime = activityMatch.group(3)?.trim() ?? '';
        final lokasi = activityMatch.group(4)?.trim() ?? '';
        final keterangan = activityMatch.group(5)?.trim() ?? '';
        // log('cok $activityName');
        Activity activity = Activity(
          activityName: activityName,
          isCustomLocation: true,
          startActivityTime: convertTo12HourFormat(startActivityTime),
          endActivityTime: convertTo12HourFormat(endActivityTime),
          lokasi: lokasi,
          keterangan: keterangan,
        );
        activities.add(activity);
        log(activity.startActivityTime);
      }

      // Menggunakan nama hari berdasarkan urutan
      String dayName = 'HARI KE-${days.length + 1}';
      days.add(Day(date: dayName, activities: activities));
    }

    return days;
  }

  String convertTo12HourFormat(String time) {
    // Pisahkan jam dan menit
    List<String> parts = time.split('.');
    int hour = int.parse(parts[0]);
    String minutes = parts[1];

    // Tentukan AM atau PM
    String period = hour >= 12 ? 'PM' : 'AM';

    // Ubah jam ke format 12 jam
    hour = hour % 12;
    if (hour == 0) {
      hour = 12; // Jam 0 harus menjadi 12 pada format 12 jam
    }

    // Format waktu dengan AM/PM tanpa angka nol di depan
    return '$hour:$minutes $period';
  }

  Future<List<Itinerary>> generateItineraryByAi({
    required String departure,
    required String destination,
    required List<DateTime> dates,
  }) async {
    _isLoading = false;
    notifyListeners();

    try {
      Itinerary itinerary1 = await _itineraryService.fetchItinerary(
          departure: departure,
          destination: destination,
          dates: dates
              .map(
                (e) => formatDateToDDMMYYYY(e),
              )
              .toList());
      Itinerary itinerary2 = await _itineraryService.fetchItinerary(
          departure: departure,
          destination: destination,
          dates: dates
              .map(
                (e) => formatDateToDDMMYYYY(e),
              )
              .toList());
      return [itinerary1, itinerary2];
    } catch (e) {
      log(e.toString());
      throw 'Somethign went wrong, try again later';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String formatDateToDDMMYYYY(DateTime date) {
    // Mengambil hari, bulan, dan tahun dari DateTime
    String day = date.day
        .toString()
        .padLeft(2, '0'); // Tambahkan nol di depan jika kurang dari 10
    String month = date.month
        .toString()
        .padLeft(2, '0'); // Tambahkan nol di depan jika kurang dari 10
    String year = date.year.toString();

    // Menggabungkan menjadi format DD/MM/YYYY
    return "$day/$month/$year";
  }

  void main() {
    // Contoh penggunaan
    String time1 = '06.00'; // Output: 6:00 AM
    String time2 = '19.30'; // Output: 7:30 PM

    print(convertTo12HourFormat(time1)); // 6:00 AM
    print(convertTo12HourFormat(time2)); // 7:30 PM
  }
}
