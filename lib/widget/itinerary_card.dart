// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:iterasi1/model/itinerary.dart';
import 'package:iterasi1/pages/add_days/add_days.dart';
import 'package:iterasi1/provider/database_provider.dart';
import 'package:iterasi1/provider/itinerary_provider.dart';
import 'package:iterasi1/resource/theme.dart';
import 'package:iterasi1/utilities/app_helper.dart';

class ItineraryCard extends StatelessWidget {
  final DatabaseProvider dbProvider;
  final ScaffoldMessengerState snackbarHandler;
  final Itinerary itinerary;
  final VoidCallback? onDelete;
  final BuildContext parentContext;

  const ItineraryCard({
    Key? key,
    required this.dbProvider,
    required this.snackbarHandler,
    required this.itinerary,
    this.onDelete,
    required this.parentContext,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      customBorder: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(16), // naikkan sedikit untuk lebih halus
      ),
      onTap: () {
        FocusScope.of(parentContext).unfocus();
        final itineraryProvider =
            Provider.of<ItineraryProvider>(context, listen: false);
        itineraryProvider.initItinerary(itinerary);

        snackbarHandler.removeCurrentSnackBar();
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return const AddDays();
        }));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 8), // jarak antar card
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: CustomColor.primaryColor50,
          border: Border.all(
            color: Colors.grey.shade300,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(20), // sudah 20 dp, tetap lega
            color: CustomColor.primaryColor50,
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: CustomColor.primaryColor300,
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(50.0),
                                ),
                              ),
                              child: Text(
                                itinerary.days.length > 1
                                    ? '${itinerary.days.length} Days'
                                    : '${itinerary.days.length} Day',
                                style: primaryTextStyle.copyWith(
                                  fontWeight: semibold,
                                  color: CustomColor.whiteColor,
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              itinerary.title,
                              style: primaryTextStyle.copyWith(
                                fontWeight: semibold,
                                fontSize: 24,
                                color: CustomColor.primaryColor900,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                      const VerticalDivider(
                        width: 50,
                        thickness: 1,
                        indent: 10,
                        endIndent: 10,
                        color: Colors.grey,
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
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
                                  AppHelper.formatDate(
                                      itinerary.days.first.date),
                                  style: primaryTextStyle.copyWith(
                                    fontWeight: regular,
                                    fontSize: 16,
                                    color: CustomColor.subtitleTextColor,
                                  ),
                                ),
                              ],
                            ),
                            if (itinerary.days.length > 1)
                              const SizedBox(height: 20),
                            if (itinerary.days.length > 1)
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
                                    AppHelper.formatDate(
                                        itinerary.days.last.date),
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
                      ),
                      InkWell(
                        onTap: () {
                          snackbarHandler.removeCurrentSnackBar();
                          final itineraryCopy = itinerary.copy();
                          dbProvider
                              .deleteItinerary(itinerary: itinerary)
                              .whenComplete(() {
                            onDelete?.call();
                            snackbarHandler.showSnackBar(
                              SnackBar(
                                content: const Text("Item dihapus!"),
                                action: SnackBarAction(
                                  label: "Undo",
                                  onPressed: () {
                                    dbProvider.insertItinerary(
                                        itinerary: itineraryCopy);
                                    onDelete?.call();
                                    snackbarHandler.removeCurrentSnackBar();
                                  },
                                ),
                              ),
                            );
                          });
                        },
                        child: Icon(
                          Icons.delete,
                          size: 18,
                          color: CustomColor.primaryColor900,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
