import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iterasi1/model/activity.dart';
import 'package:iterasi1/provider/itinerary_provider.dart';
import 'package:path/path.dart' as path_lib;
import 'package:path_provider/path_provider.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';

class PhotoController extends GetxController {
  RxList<File> image = <File>[].obs;
  RxBool isLoading = true.obs;
  late Activity activity;
  late String activityDate;
  late ItineraryProvider itineraryProvider =
      Provider.of<ItineraryProvider>(Get.context!, listen: false);

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> loadImage() async {
    isLoading.value = true;
    loadCachedImagesOnly();
    await syncGalleryIncremental();

    isLoading.value = false;
  }

  void loadCachedImagesOnly() {
    final imagesave = itineraryProvider.getImage(activity);
    final filteredA = imagesave
        .where((item) => !(activity.removedImages?.contains(item) ?? false))
        .toList();
    final filedb = convertPathsToFiles(filteredA);
    image.value = filedb;
  }

  DateTime? _parseActivityDate() {
    final parts = activityDate.split('/');
    if (parts.length != 3) {
      return null;
    }

    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);

    if (day == null || month == null || year == null) {
      return null;
    }

    return DateTime(year, month, day);
  }

  bool _isWithinActivityWindow(DateTime photoDateTime) {
    final selectedDate = _parseActivityDate();
    if (selectedDate == null) {
      return false;
    }

    if (photoDateTime.year != selectedDate.year ||
        photoDateTime.month != selectedDate.month ||
        photoDateTime.day != selectedDate.day) {
      return false;
    }

    final start = activity.startTimeOfDay;
    final end = activity.endTimeOfDay;

    final startMinute = (start.hour * 60) + start.minute;
    final endMinute = (end.hour * 60) + end.minute;
    final photoMinute = (photoDateTime.hour * 60) + photoDateTime.minute;

    if (endMinute < startMinute) {
      return false;
    }

    return photoMinute >= startMinute && photoMinute <= endMinute;
  }

  String _sanitizeHash(String rawHash) {
    return rawHash.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');
  }

  String _buildAssetHash(AssetEntity asset) {
    return _sanitizeHash(
      '${asset.id}_${asset.createDateTime.millisecondsSinceEpoch}',
    );
  }

  Future<void> syncGalleryIncremental({bool force = false}) async {
    try {
      final permission = await PhotoManager.requestPermissionExtend();
      if (!permission.isAuth) {
        return;
      }

      final albums = await PhotoManager.getAssetPathList(
        type: RequestType.image,
      );
      if (albums.isEmpty) {
        return;
      }

      final appDir = await getApplicationDocumentsDirectory();

      final existing = Set<String>.from(activity.images ?? const <String>[]);
      final removed =
          Set<String>.from(activity.removedImages ?? const <String>[]);
      final hiddenHashes =
          Set<String>.from(activity.hiddenPhotoHashes ?? const <String>[]);
      final lastScanEpochMs = activity.lastGalleryScanEpochMs ?? 0;
      int newestScanEpochMs = lastScanEpochMs;

      for (final album in albums) {
        final assets = await album.getAssetListPaged(page: 0, size: 1200);

        for (final asset in assets) {
          final createdAt = asset.createDateTime;
          final createdAtEpochMs = createdAt.millisecondsSinceEpoch;

          if (!force && createdAtEpochMs <= lastScanEpochMs) {
            continue;
          }

          if (createdAtEpochMs > newestScanEpochMs) {
            newestScanEpochMs = createdAtEpochMs;
          }

          if (!_isWithinActivityWindow(createdAt)) {
            continue;
          }

          final assetHash = _buildAssetHash(asset);
          if (hiddenHashes.contains(assetHash)) {
            continue;
          }

          final originalFile = await asset.originFile;
          if (originalFile == null) {
            continue;
          }

          final extension = path_lib.extension(originalFile.path).toLowerCase();
          final safeExtension = extension.isEmpty ? '.jpg' : extension;
          final internalName = 'AUTO_$assetHash$safeExtension';
          final internalPath = '${appDir.path}/$internalName';

          final internalFile = File(internalPath);
          if (!await internalFile.exists()) {
            await originalFile.copy(internalPath);
          }

          if (removed.contains(internalPath) ||
              existing.contains(internalPath)) {
            continue;
          }

          itineraryProvider.addPhotoActivity(
            activity: activity,
            pathImage: internalPath,
          );
          existing.add(internalPath);
        }
      }

      final nowEpochMs = DateTime.now().millisecondsSinceEpoch;
      final targetEpochMs =
          newestScanEpochMs > nowEpochMs ? newestScanEpochMs : nowEpochMs;
      itineraryProvider.updateLastGalleryScan(
        activity,
        targetEpochMs,
        shouldNotify: false,
      );
      loadCachedImagesOnly();
    } catch (e) {
      log('Auto import photos failed: $e');
    }
  }

  // Future<List<File>> loadNewPhotos() async {
  //   var result = await PhotoManager.requestPermissionExtend();
  //   var status = await Permission.manageExternalStorage.request();
  //   print(result);
  //   if (result.isAuth) {
  //     List<AssetPathEntity> albums = await PhotoManager.getAssetPathList();
  //     List<AssetEntity> assets =
  //         await albums.first.getAssetListPaged(page: 0, size: 100);
  //     List<File> files = [];
  //     for (var asset in assets) {
  //       bool isInDate = false;
  //       var file = await asset.originFile;
  //       if (file != null) {
  //         isInDate = await matchesActivityTime(file);
  //         if (isInDate == true) {
  //           files.add(file);
  //         }
  //       }
  //     }
  //     return files;
  //   } else {
  //     print('tidak masuk');
  //     PhotoManager.openSetting();
  //     return [];
  //   }
  // }

  List<File> convertPathsToFiles(List<String> paths) {
    log('Converting paths to files: $paths');
    List<File> files = [];
    for (String path in paths) {
      if (path.isNotEmpty) {
        // Periksa jika path tidak kosong
        File file = File(path);
        if (file.existsSync()) {
          // Pastikan file ada di lokasi yang diberikan
          files.add(file);
        } else {
          log('File does not exist at path: $path');
        }
      } else {
        log('Encountered empty path in list: $paths');
      }
    }
    return files;
  }

  Future<void> deletePhoto(File image) async {
    itineraryProvider.removePhotoActivity(
      activity: activity,
      pathImage: image.path,
    );
    loadImage();
  }

  Future<void> returnPhoto(File image) async {
    itineraryProvider.returnPhotoActivity(
      activity: activity,
      pathImage: image.path,
    );
    loadImage();
  }

  Future<void> showDeleteConfirmationDialog(
      BuildContext context, File image) async {
    bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white, // Ubah warna latar belakang
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0), // Ubah bentuk border
          ),
          title: const Text(
            'Konfirmasi Hapus Foto',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'poppins_bold',
              color: Color(0xFFC58940), // Ubah warna teks judul
              fontWeight: FontWeight.bold, // Teks judul menjadi tebal
            ),
          ),
          content: const Text(
            'Apa kamu yakin ingin menghapus foto ini?',
            textAlign: TextAlign.center,
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.green, // Ubah warna latar belakang
                      borderRadius:
                          BorderRadius.circular(8), // Ubah bentuk border
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 24), // Atur padding
                    child: const Text(
                      'Batal',
                      textAlign: TextAlign.center, // Pusatkan teks dalam tombol
                      style: TextStyle(
                        fontFamily: 'poppins_bold',
                        color: Colors.white, // Ubah warna teks
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20), // Spasi antar tombol
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.red, // Ubah warna latar belakang
                      borderRadius:
                          BorderRadius.circular(8), // Ubah bentuk border
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 24), // Atur padding
                    child: const Text(
                      'Hapus',
                      textAlign: TextAlign.center, // Pusatkan teks dalam tombol
                      style: TextStyle(
                        fontFamily: 'poppins_bold',
                        color: Colors.white, // Ubah warna teks
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      deletePhoto(image);
    }
  }

  Future<void> showReturnConfirmationDialog(
      BuildContext context, File image) async {
    bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white, // Ubah warna latar belakang
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0), // Ubah bentuk border
          ),
          title: const Text(
            'Pulihkan Foto',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'poppins_bold',
              color: Color(0xFFC58940), // Ubah warna teks judul
              fontWeight: FontWeight.bold, // Teks judul menjadi tebal
            ),
          ),
          content: const Text(
            'Apa kamu yakin ingin mengembalikan foto ini?',
            textAlign: TextAlign.center,
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.green, // Ubah warna latar belakang
                      borderRadius:
                          BorderRadius.circular(8), // Ubah bentuk border
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 24), // Atur padding
                    child: const Text(
                      'Batal',
                      textAlign: TextAlign.center, // Pusatkan teks dalam tombol
                      style: TextStyle(
                        fontFamily: 'poppins_bold',
                        color: Colors.white, // Ubah warna teks
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20), // Spasi antar tombol
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.red, // Ubah warna latar belakang
                      borderRadius:
                          BorderRadius.circular(8), // Ubah bentuk border
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 24), // Atur padding
                    child: const Text(
                      'Pulihkan',
                      textAlign: TextAlign.center, // Pusatkan teks dalam tombol
                      style: TextStyle(
                        fontFamily: 'poppins_bold',
                        color: Colors.white, // Ubah warna teks
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      returnPhoto(image);
    }
  }
}
