import 'package:flutter/material.dart';
import 'package:iterasi1/model/activity.dart';
import 'package:iterasi1/resource/theme.dart';
import 'package:iterasi1/utilities/app_helper.dart';
import 'package:url_launcher/url_launcher.dart';

class RecommendaationActivityCard extends StatelessWidget {
  final Activity data;
  const RecommendaationActivityCard({
    super.key,
    required this.data,
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
                  fit: BoxFit.fitWidth,
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
                  const SizedBox(height: 4),
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      openGoogleMaps(data.lokasi);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: CustomColor.disabledColor,
                        borderRadius: BorderRadius.all(
                          Radius.circular(100.0),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.map_outlined,
                            color: CustomColor.whiteColor,
                            size: 12,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            'Map',
                            style: primaryTextStyle.copyWith(
                              fontWeight: semibold,
                              fontSize: 10,
                              color: CustomColor.whiteColor,
                            ),
                          ),
                        ],
                      ),
                    ),
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
                ],
              ),
            ),
          );
        },
      );
    }

    final currentActivity = data.copy();

    return InkWell(
      onTap: showActivityDetailDialog, // Panggil modal saat card di-tap
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
                            const IconData(0xe055, fontFamily: 'MaterialIcons'),
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
                            margin: const EdgeInsets.symmetric(horizontal: 20),
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
    );
  }
}
