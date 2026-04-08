import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_masonry_view/flutter_masonry_view.dart';
import 'package:get/get.dart';
import 'package:iterasi1/model/activity.dart';
import 'package:iterasi1/pages/activity_photo_controller.dart';

class ActivityTrashPhotoPage extends StatefulWidget {
  final Activity activity;
  const ActivityTrashPhotoPage({
    Key? key,
    required this.activity,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ActivityTrashPhotoPageState createState() => _ActivityTrashPhotoPageState();
}

class _ActivityTrashPhotoPageState extends State<ActivityTrashPhotoPage> {
  final controller = Get.put(PhotoController());

  List<File> get removedImages => (widget.activity.removedImages ?? const [])
      .where((path) => path.isNotEmpty)
      .map((path) => File(path))
      .toList();

  Future<void> _confirmRestorePhoto(File file) async {
    final shouldRestore = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          title: const Text(
            'Pulihkan Foto',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'poppins_bold',
              color: Color(0xFFC58940),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Apa kamu yakin ingin mengembalikan foto ini?',
            textAlign: TextAlign.center,
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 24),
                    child: const Text(
                      'Batal',
                      style: TextStyle(
                        fontFamily: 'poppins_bold',
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 24),
                    child: const Text(
                      'Pulihkan',
                      style: TextStyle(
                        fontFamily: 'poppins_bold',
                        color: Colors.white,
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

    if (shouldRestore == true) {
      await controller.returnPhoto(file);
      if (mounted) {
        setState(() {});
      }
    }
  }

  void _showImageDialog(File imageFile) {
    final image = Image.file(imageFile);
    image.image.resolve(const ImageConfiguration()).addListener(
      ImageStreamListener(
        (ImageInfo info, bool _) {
          final imageWidth = info.image.width;
          final imageHeight = info.image.height;
          final aspectRatio = imageWidth / imageHeight;
          final maxDialogWidth = MediaQuery.of(context).size.width * 0.9;
          final maxDialogHeight = MediaQuery.of(context).size.height * 0.8;

          double dialogWidth, dialogHeight;
          if (aspectRatio > 1) {
            // Landscape
            dialogWidth = maxDialogWidth;
            dialogHeight = dialogWidth / aspectRatio;
          } else {
            // Portrait
            dialogHeight = maxDialogHeight;
            dialogWidth = dialogHeight * aspectRatio;
          }

          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                elevation: 0,
                backgroundColor: Colors.transparent,
                contentPadding: EdgeInsets.zero,
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: SizedBox(
                        width: dialogWidth,
                        height: dialogHeight,
                        child: Ink(
                          color: Colors.transparent,
                          child: image,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Gambar Dihapus",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'poppins_bold',
            fontSize: 24,
            fontWeight: FontWeight.normal,
            color: Color(0xFFC58940),
          ),
        ),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Column(
                //   children: [
                //     // ElevatedButton(
                //     //   onPressed: () async {
                //     //     var files = await loadPhotos();
                //     //     if (files.isNotEmpty) {
                //     //       setState(() {
                //     //         image = files;
                //     //       });
                //     //     }
                //     //   },
                //     //   style: ButtonStyle(
                //     //       // backgroundColor: MaterialStateProperty<Colors.black>
                //     //       //     WidgetStateProperty.resolveWith<Color?>(
                //     //       //   (Set<WidgetState> states) {
                //     //       //     if (states.contains(WidgetState.pressed)) {
                //     //       //       return Colors.grey[100];
                //     //       //     }
                //     //       //     return Colors.grey;
                //     //       //   },
                //     //       // ),
                //     //       ),
                //     //   child: const Text(
                //     //     'Gallery',
                //     //     style: TextStyle(
                //     //       color: Colors.white,
                //     //     ),
                //     //   ),
                //     // )
                //   ],
                // ),
                const SizedBox(
                  height: 6,
                ),
                MasonryView(
                  listOfItem: removedImages,
                  numberOfColumn: 2,
                  itemBuilder: (item) {
                    final file = item as File;
                    return GestureDetector(
                      onTap: () {
                        _showImageDialog(file);
                      },
                      onLongPress: () {
                        _confirmRestorePhoto(file);
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.file(
                          file,
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
