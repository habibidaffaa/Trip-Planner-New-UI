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
  List<String>? hiddenPhotoHashes;
  int? lastGalleryScanEpochMs;

  static final _formatter24 = DateFormat('HH.mm', 'id_ID');
  static final _formatter12 = DateFormat('h:mm a', 'en_US');

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
    List<String>? hiddenPhotoHashes,
    int? lastGalleryScanEpochMs,
  })  : id = id ?? const Uuid().v4(),
        images = images ?? [],
        removedImages = removedImages ?? [],
        hiddenPhotoHashes = hiddenPhotoHashes ?? [],
        lastGalleryScanEpochMs = lastGalleryScanEpochMs;

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
      'hidden_photo_hashes': hiddenPhotoHashes,
      'last_gallery_scan_epoch_ms': lastGalleryScanEpochMs,
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
        hiddenPhotoHashes: json['hidden_photo_hashes'] != null
            ? List<String>.from(json['hidden_photo_hashes'])
            : [],
        lastGalleryScanEpochMs: json['last_gallery_scan_epoch_ms'],
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
    List<String>? hiddenPhotoHashes,
    int? lastGalleryScanEpochMs,
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
        longtitude: longtitude ?? this.longtitude,
        images: images ?? List<String>.from(this.images ?? []),
        removedImages:
            removedImages ?? List<String>.from(this.removedImages ?? []),
        hiddenPhotoHashes: hiddenPhotoHashes ??
            List<String>.from(this.hiddenPhotoHashes ?? []),
        lastGalleryScanEpochMs:
            lastGalleryScanEpochMs ?? this.lastGalleryScanEpochMs,
      );

  TimeOfDay get startTimeOfDay => _parseTimeOfDay(startActivityTime);

  TimeOfDay get endTimeOfDay => _parseTimeOfDay(endActivityTime);

  DateTime get startDateTime => _parseDateTime(startActivityTime);

  DateTime get endDateTime => _parseDateTime(endActivityTime);

  DateTime _parseDateTime(String rawValue) {
    final normalized = rawValue.trim();
    try {
      return _formatter24.parseStrict(normalized);
    } catch (_) {
      return _formatter12.parseStrict(normalized.toUpperCase());
    }
  }

  TimeOfDay _parseTimeOfDay(String rawValue) {
    final dateTime = _parseDateTime(rawValue);
    return TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
  }
}
