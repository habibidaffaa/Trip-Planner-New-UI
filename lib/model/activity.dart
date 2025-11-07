import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class Activity {
  String? id;
  String activityName;
  String lokasi;
  String startActivityTime;
  String endActivityTime;
  String keterangan;
  String? latitude;
  String? longtitude;
  bool isCustomLocation;
  List<String>? images; // Nullable List<String>
  List<String>? removedImages; // Nullable List<String>

  static final _formatter = DateFormat('HH.mm', 'id_ID');

  Activity({
    String? id,
    required this.activityName,
    required this.lokasi,
    required this.startActivityTime,
    required this.endActivityTime,
    required this.keterangan,
    required this.isCustomLocation,
    String? latitude,
    String? longtitude,
    List<String>? removedImages,
    List<String>? images,
  })  : id = id ?? const Uuid().v4(),
        images = images ?? [],
        removedImages = removedImages ?? [];

  Map<String, dynamic> toJson() {
    return {
      'activity_name': activityName,
      'lokasi': lokasi,
      'start_activity_time': startActivityTime,
      'end_activity_time': endActivityTime,
      'keterangan': keterangan,
      'latitude': latitude,
      'longtitude': longtitude,
      'is_custom_location': isCustomLocation,
      'images': images, // Sertakan data images dalam JSON
      'removed_images': removedImages, // Sertakan data images dalam JSON
    };
  }

  factory Activity.fromJson(Map<String, dynamic> json) => Activity(
        activityName: json['activity_name'],
        lokasi: json['lokasi'],
        startActivityTime: json['start_activity_time'],
        endActivityTime: json['end_activity_time'],
        keterangan: json['keterangan'],
        latitude: json['latitude'],
        longtitude: json['longtitude'],
        isCustomLocation: json['is_custom_location'],
        images: json['images'] != null
            ? List<String>.from(
                json['images']) // Ubah List<dynamic> menjadi List<String>
            : [], // Atur images ke List kosong jika null
        removedImages: json['removed_images'] != null
            ? List<String>.from(json[
                'removed_images']) // Ubah List<dynamic> menjadi List<String>
            : [], // Atur images ke List kosong jika null
      );

  factory Activity.fromJsonGPT(Map<String, dynamic> json) {
    return Activity(
      activityName: json['title'] as String,
      lokasi: json['location'] as String,
      startActivityTime: json['start_time'] as String,
      endActivityTime: json['end_time'] as String,
      keterangan: json['description'] as String,
      isCustomLocation: json['is_custom_location'] ?? false,
      latitude: (json['latitude']).toString(),
      longtitude: (json['longtitude']).toString(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Activity &&
          runtimeType == other.runtimeType &&
          activityName == other.activityName &&
          lokasi == other.lokasi &&
          startActivityTime == other.startActivityTime &&
          endActivityTime == other.endActivityTime &&
          latitude == other.latitude &&
          isCustomLocation == other.isCustomLocation &&
          longtitude == other.longtitude &&
          images == other.images && // Termasuk images dalam operator ==
          removedImages ==
              other.removedImages; // Termasuk images dalam operator ==

  Activity copy({
    String? activityName,
    String? lokasi,
    String? startActivityTime,
    String? endActivityTime,
    String? keterangan,
    bool? isCustomLocation,
    String? latitude,
    String? longtitude,
    List<String>? images, // Tambahkan parameter images ke dalam metode copy
    List<String>?
        removedImages, // Tambahkan parameter images ke dalam metode copy
  }) =>
      Activity(
        id: id,
        activityName: activityName ?? this.activityName,
        lokasi: lokasi ?? this.lokasi,
        startActivityTime: startActivityTime ?? this.startActivityTime,
        endActivityTime: endActivityTime ?? this.endActivityTime,
        keterangan: keterangan ?? this.keterangan,
        isCustomLocation: isCustomLocation ?? this.isCustomLocation,
        latitude: latitude ?? this.latitude,
        longtitude: keterangan ?? this.keterangan,
        images: images ??
            this.images, // Set images ke nilai yang diberikan atau biarkan seperti sebelumnya jika null
        removedImages: removedImages ??
            this.removedImages, // Set images ke nilai yang diberikan atau biarkan seperti sebelumnya jika null
      );

  TimeOfDay get startTimeOfDay =>
      TimeOfDay.fromDateTime(_formatter.parse(startActivityTime));

  TimeOfDay get endTimeOfDay =>
      TimeOfDay.fromDateTime(_formatter.parse(endActivityTime));

  DateTime get startDateTime => _formatter.parse(startActivityTime);

  DateTime get endDateTime => _formatter.parse(endActivityTime);
}
