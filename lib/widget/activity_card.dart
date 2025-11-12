import 'package:flutter/material.dart';
import 'package:iterasi1/model/activity.dart';
import 'package:iterasi1/pages/activity_photo_page.dart';
import 'package:iterasi1/pages/add_activities/add_activities.dart';
import 'package:iterasi1/provider/itinerary_provider.dart';
import 'package:iterasi1/resource/theme.dart';
import 'package:iterasi1/utilities/app_helper.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ActivityCard extends StatelessWidget {
  final Activity data;
  final int selectedDayIndex;
  final int activityIndex;
  final void Function() onDismiss;
  final void Function() onUndo;
  final ScaffoldMessengerState snackbarHandler;
  const ActivityCard({
    super.key,
    required this.data,
    required this.selectedDayIndex,
    required this.activityIndex,
    required this.onDismiss,
    required this.onUndo,
    required this.snackbarHandler,
  });

  @override
  Widget build(BuildContext context) {
    Future<void> openGoogleMaps(String placeName) async {
      // Encode nama tempat untuk URL
      String query = Uri.encodeComponent(placeName);
      String googleMapsUrl =
          "https://www.google.com/maps/search/?api=1&query=$query";

      final Uri url = Uri.parse(googleMapsUrl);
      if (await canLaunchUrl(url)) {
        await launchUrl(
          url,
          mode: LaunchMode.externalApplication,
        );
      } else {
        throw 'Could not launch $url';
      }
    }

    Future<void> requestGalleryPermission(Activity activity) async {
      var result = await PhotoManager.requestPermissionExtend();
      if (result.isAuth) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ActivityPhotoPage(
              dayIndex: selectedDayIndex,
              activity: activity,
            ),
          ),
        );
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Perizinan Ditolak"),
            content:
                const Text("Aplikasi memerlukan izin untuk mengakses galeri."),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
    }

    void showActivityDetailDialog() {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: CustomColor.whiteColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            titlePadding: EdgeInsets.zero,
            title: Container(
              alignment: Alignment.center,
              height: 118,
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                // color: CustomColor.primaryColor500,
                image: DecorationImage(
                  image: AssetImage(
                    'assets/images/dialog_background.png',
                  ),
                  fit: BoxFit.cover,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8.0),
                  topRight: Radius.circular(8.0),
                ),
              ),
              child: Text(
                'DETAIL AKTIVITAS',
                style: primaryTextStyle.copyWith(
                  fontFamily: 'poppins_bold',
                  fontSize: 18,
                  fontWeight: semibold,
                  color: CustomColor.whiteColor,
                ),
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    data.activityName,
                    style: primaryTextStyle.copyWith(
                      fontSize: 20,
                      fontWeight: semibold,
                      color: CustomColor.primaryColor900,
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.place,
                        color: CustomColor.subtitleTextColor,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Lokasi',
                        style: primaryTextStyle.copyWith(
                          fontSize: 12,
                          fontWeight: semibold,
                          color: CustomColor.subtitleTextColor,
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data.lokasi,
                    textAlign: TextAlign.left,
                    style: primaryTextStyle.copyWith(
                      fontSize: 14,
                      fontWeight: regular,
                      color: CustomColor.subtitleTextColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(
                        Icons.watch_later,
                        color: CustomColor.subtitleTextColor,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Waktu',
                        style: primaryTextStyle.copyWith(
                          fontSize: 12,
                          fontWeight: semibold,
                          color: CustomColor.subtitleTextColor,
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  Text(
                    '${data.startActivityTime} - ${data.endActivityTime}',
                    style: primaryTextStyle.copyWith(
                      fontWeight: medium,
                      fontSize: 16,
                      color: CustomColor.subtitleTextColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(
                        Icons.description,
                        color: CustomColor.subtitleTextColor,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Keterangan',
                        style: primaryTextStyle.copyWith(
                          fontSize: 12,
                          fontWeight: semibold,
                          color: CustomColor.subtitleTextColor,
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data.keterangan,
                    style: primaryTextStyle.copyWith(
                      fontWeight: regular,
                      fontSize: 14,
                      color: CustomColor.subtitleTextColor,
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        // mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.pop(context);
                              requestGalleryPermission(data);
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.perm_media,
                                  color: CustomColor.primaryColor900,
                                  size: 18,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  'Galeri',
                                  style: primaryTextStyle.copyWith(
                                    fontWeight: semibold,
                                    fontSize: 16,
                                    color: CustomColor.primaryColor900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (!data.isCustomLocation) ...[
                            VerticalDivider(),
                            InkWell(
                              onTap: () {
                                Navigator.pop(context);
                                openGoogleMaps(data.lokasi);
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.map_outlined,
                                    color: CustomColor.primaryColor900,
                                    size: 18,
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    'Map',
                                    style: primaryTextStyle.copyWith(
                                      fontWeight: semibold,
                                      fontSize: 16,
                                      color: CustomColor.primaryColor900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              const SizedBox(
                height: 8,
              ),
              InkWell(
                customBorder: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
                onTap: () {
                  Navigator.of(context).pop(); // Tutup dialog
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        return AddActivities(
                          initialActivity: data,
                          onSubmit: (newActivity) {
                            context.read<ItineraryProvider>().updateActivity(
                                  updatedDayIndex: selectedDayIndex,
                                  updatedActivityIndex: activityIndex,
                                  newActivity: newActivity,
                                );
                          },
                        );
                      },
                    ),
                  );
                },
                child: Container(
                  height: 50,
                  // width: 270,
                  decoration: BoxDecoration(
                    color: CustomColor.primaryColor500,
                    borderRadius: const BorderRadius.all(
                      Radius.circular(100.0),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Edit Aktivitas',
                    style: primaryTextStyle.copyWith(
                      fontWeight: semibold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      );
    }

    final currentActivity = data.copy();

    return Stack(
      children: [
        InkWell(
          onTap: showActivityDetailDialog,
          child: Container(
            decoration: BoxDecoration(
              color: CustomColor.primaryColor50,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                Column(
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
                              Icon(
                                const IconData(0xe055,
                                    fontFamily: 'MaterialIcons'),
                                color: CustomColor.subtitleTextColor,
                                size: 15,
                              ),
                              const SizedBox(width: 9),
                              Expanded(
                                child: Text(
                                  data.lokasi,
                                  textAlign: TextAlign.left,
                                  style: primaryTextStyle.copyWith(
                                    fontSize: 14,
                                    fontWeight: semibold,
                                    color: CustomColor.subtitleTextColor,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            data.activityName,
                            textAlign: TextAlign.left,
                            style: primaryTextStyle.copyWith(
                              fontSize: 20,
                              fontWeight: semibold,
                              color: CustomColor.primaryColor900,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'MULAI',
                                    style: primaryTextStyle.copyWith(
                                      fontWeight: regular,
                                      fontSize: 12,
                                      color: CustomColor.subtitleTextColor,
                                    ),
                                  ),
                                  Text(
                                    data.startActivityTime,
                                    style: primaryTextStyle.copyWith(
                                      fontWeight: regular,
                                      fontSize: 16,
                                      color: CustomColor.subtitleTextColor,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: CustomColor.primaryColor300,
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(50.0),
                                  ),
                                ),
                                child: Text(
                                  '${AppHelper.calculateDurationInMinutes(data.startActivityTime, data.endActivityTime)} Mins',
                                  style: primaryTextStyle.copyWith(
                                    fontWeight: semibold,
                                    color: CustomColor.whiteColor,
                                    fontSize: 10,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'SELESAI',
                                    style: primaryTextStyle.copyWith(
                                      fontWeight: regular,
                                      fontSize: 12,
                                      color: CustomColor.subtitleTextColor,
                                    ),
                                  ),
                                  Text(
                                    data.endActivityTime,
                                    style: primaryTextStyle.copyWith(
                                      fontWeight: regular,
                                      fontSize: 16,
                                      color: CustomColor.subtitleTextColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Ikon Delete (menggantikan Dismissible)
        Positioned(
          top: 8,
          right: 8,
          child: InkWell(
            onTap: () {
              snackbarHandler.removeCurrentSnackBar();
              onDismiss();

              snackbarHandler.showSnackBar(
                SnackBar(
                  content: const Text("Item dihapus!"),
                  action: SnackBarAction(
                    label: "Undo",
                    onPressed: () {
                      onUndo();
                      snackbarHandler.removeCurrentSnackBar();
                    },
                  ),
                ),
              );
            },
            child: Icon(
              Icons.delete,
              size: 18,
              color: CustomColor.primaryColor900,
            ),
          ),
        ),
      ],
    );
  }
}
