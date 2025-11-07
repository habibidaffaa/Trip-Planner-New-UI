import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:iterasi1/model/activity.dart';
import 'package:iterasi1/model/day.dart';
import 'package:iterasi1/provider/itinerary_provider.dart';
import 'package:native_exif/native_exif.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';

class PhotoController extends GetxController {
  RxList<File> image = <File>[].obs;
  List<File> files = <File>[].obs;
  RxBool isLoading = true.obs;
  late Activity activity;
  late List<Day> day;
  int dateIndex = 0;
  // late ItineraryProvider itineraryProvider;
  late ItineraryProvider itineraryProvider =
      Provider.of<ItineraryProvider>(Get.context!, listen: false);

  @override
  void onInit() {
    loadImage();
    super.onInit();
  }

  Future<void> loadImage() async {
    isLoading.value = true;
    List<File> filedb = <File>[];
    var imagesave = itineraryProvider.getImage(activity);
    List<String> filteredA = imagesave
        .where((item) => !(activity.removedImages?.contains(item) ?? false))
        .toList();
    log(filteredA.length.toString());
    for (var i = 0; i < filteredA.length; i++) {
      log(filteredA[i]);
      filedb.add(File(filteredA[i]));
    }
    if (filedb.isNotEmpty) {
      image.value = filedb;
      print("filedb");
    } else {
      var files = await loadNewPhotos();
      log('files : $files');
      if (files.isNotEmpty) {
        log('files not empty');
        image.value = files;
        for (var i = 0; i < files.length; i++) {
          itineraryProvider.addPhotoActivity(
            activity: activity,
            pathImage: image[i].path,
          );
        }
      }
    }

    isLoading.value = false;
  }

  Future<List<File>> loadNewPhotos() async {
    isLoading.value = true;
    var result = await PhotoManager.requestPermissionExtend();
    if (result.isAuth) {
      List<AssetPathEntity> albums = await PhotoManager.getAssetPathList();
      List<AssetEntity> assets =
          await albums.first.getAssetListPaged(page: 0, size: 200);
      List<File> files = [];
      for (var asset in assets) {
        var file = await asset.originFile;
        if (file != null &&
            !(activity.removedImages?.contains(file.path) ?? false) &&
            await matchesActivityTime(file)) {
          files.add(file);
        }
      }
      isLoading.value = false;
      return files;
    } else {
      isLoading.value = false;
      print('tidak masuk');
      PhotoManager.openSetting();
      return [];
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

  Future<bool> matchesActivityTime(File image) async {
    var metadata = await Exif.fromPath(image.path);
    DateTime? photoDate = await metadata.getOriginalDate();
    String start = "${day[dateIndex].date} ${activity.startActivityTime}";
    DateTime startTime = DateFormat("d/M/yyyy HH:mm").parse(start);

    String end = "${day[dateIndex].date} ${activity.endActivityTime}";
    DateTime endTime = DateFormat("d/M/yyyy HH:mm").parse(end);

    DateTime activityStart = startTime;
    DateTime activityEnd = endTime;
    print('date : $photoDate , start : $activityStart, end : $activityEnd');
    if (photoDate != null &&
        photoDate.isAfter(activityStart) &&
        photoDate.isBefore(activityEnd)) {
      return true;
    } else {
      return false;
    }
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
