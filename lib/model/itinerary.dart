import 'dart:convert';

import 'package:uuid/uuid.dart';

import 'activity.dart';
import 'day.dart';

class Itinerary {
  late String id;
  String title;
  String dateModified;
  List<Day> days;

  Itinerary(
      {String? id,
      required this.title,
      required this.dateModified,
      List<Day>? days})
      : id = id ?? const Uuid().v1(),
        days = days ?? [];

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "title": title,
      "days": days.map((day) => day.toJson()).toList(),
      "date_modified": dateModified,
    };
  }

  factory Itinerary.fromJsonGPT(Map<String, dynamic> json) {
    // Parse days dan gabungkan aktivitas dengan tanggal yang sama
    final Map<String, List<Activity>> activitiesByDate = {};
    
    for (var dayJson in json['itinerary'] as List) {
      final date = dayJson['date'] as String;
      final activities = (dayJson['activities'] as List)
          .map((activityJson) => Activity.fromJsonGPT(activityJson))
          .toList();
      
      if (activitiesByDate.containsKey(date)) {
        // Gabungkan aktivitas jika tanggal sudah ada
        activitiesByDate[date]!.addAll(activities);
      } else {
        activitiesByDate[date] = activities;
      }
    }
    
    // Buat list Day dari map yang sudah digabung
    List<Day> days = activitiesByDate.entries.map((entry) {
      return Day(date: entry.key, activities: entry.value);
    }).toList();
    
    // Sort days berdasarkan tanggal
    days.sort((a, b) => a.getDatetime().compareTo(b.getDatetime()));
    
    return Itinerary(
      title: 'HASIL ',
      days: days,
      dateModified: DateTime.now().toString(),
    );
  }

  factory Itinerary.fromJson(Map<String, dynamic> json) {
    return Itinerary(
        id: json['id'],
        title: json['title'],
        days: json['days'].map((day) => Day.fromJson(day)).toList().cast<Day>(),
        dateModified: json['date_modified']);
  }

  Itinerary copy(
          {String? id, String? title, List<Day>? days, String? dateModified}) =>
      Itinerary(
          id: id ?? this.id,
          title: title ?? this.title,
          days: days ?? this.days.map((e) => e.copy()).toList(),
          dateModified: dateModified ?? this.dateModified);

  String toJsonString() => jsonEncode(toJson());

  String get firstDate => days[0].date;
}
