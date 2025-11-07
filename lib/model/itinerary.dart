import 'dart:convert';

import 'package:uuid/uuid.dart';

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
    List<Day> days = (json['itinerary'] as List)
        .map((dayJson) => Day.fromJsonGPT(dayJson))
        .toList();
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
