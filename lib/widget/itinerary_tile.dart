import 'package:flutter/material.dart';
import 'package:iterasi1/model/itinerary.dart';
import 'package:iterasi1/pages/add_days/add_days.dart';
import 'package:iterasi1/provider/database_provider.dart';
import 'package:iterasi1/provider/itinerary_provider.dart';
import 'package:iterasi1/resource/theme.dart';
import 'package:provider/provider.dart';

class ItineraryTile extends StatelessWidget {
  final DatabaseProvider dbProvider;
  final ScaffoldMessengerState snackbarHandler;
  final Itinerary itinerary;
  final VoidCallback? onDelete; // Callback untuk refresh

  const ItineraryTile({
    super.key,
    required this.dbProvider,
    required this.snackbarHandler,
    required this.itinerary,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      customBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      onTap: () {
        final itineraryProvider =
            Provider.of<ItineraryProvider>(context, listen: false);
        itineraryProvider.initItinerary(itinerary);

        snackbarHandler.removeCurrentSnackBar();
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return const AddDays();
        }));
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(12.0)),
          // boxShadow: const [
          //   BoxShadow(
          //     color: Color(0x19000000),
          //     blurRadius: 8,
          //     offset: Offset(0, 2),
          //   ),
          // ],
          color: CustomColor.greyBackgroundColor,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    '${itinerary.days.length} Days Trip',
                    style: primaryTextStyle.copyWith(
                      fontWeight: semibold,
                      fontSize: 12,
                      color: CustomColor.subtitleTextColor,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    snackbarHandler.removeCurrentSnackBar();
                    final itineraryCopy = itinerary.copy();
                    dbProvider
                        .deleteItinerary(itinerary: itinerary)
                        .whenComplete(
                      () {
                        onDelete?.call(); // Refresh daftar setelah hapus
                        snackbarHandler.showSnackBar(
                          SnackBar(
                            content: const Text("Item dihapus!"),
                            action: SnackBarAction(
                              label: "Undo",
                              onPressed: () {
                                dbProvider.insertItinerary(
                                    itinerary: itineraryCopy);
                                onDelete?.call(); // Refresh setelah undo
                                snackbarHandler.removeCurrentSnackBar();
                              },
                            ),
                          ),
                        );
                      },
                    );
                  },
                  child: Icon(
                    Icons.cancel,
                    size: 16,
                    color: CustomColor.primaryColor500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              itinerary.title,
              style: primaryTextStyle.copyWith(
                fontWeight: semibold,
                color: CustomColor.blackColor,
                fontSize: 20,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            itinerary.days.isNotEmpty
                ? Row(
                    children: [
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            // color: CustomColor.primaryColor200,
                            color: Color(0xFF305A5A),
                            borderRadius: const BorderRadius.all(
                              Radius.circular(8.0),
                            ),
                          ),
                          child: Text(
                            itinerary.days.first.date,
                            style: primaryTextStyle.copyWith(
                              fontWeight: semibold,
                              color: CustomColor.whiteColor,
                              fontSize: 8,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      if (itinerary.days.length != 1)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                            '-',
                            style: primaryTextStyle.copyWith(
                              fontSize: 8,
                              color: CustomColor.subtitleTextColor,
                            ),
                          ),
                        ),
                      if (itinerary.days.length != 1)
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Color(0xFF305A5A),
                              borderRadius: const BorderRadius.all(
                                Radius.circular(8.0),
                              ),
                            ),
                            child: Text(
                              itinerary.days.last.date,
                              style: primaryTextStyle.copyWith(
                                fontWeight: semibold,
                                color: CustomColor.whiteColor,
                                fontSize: 8,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  )
                : Text(
                    'No dates set',
                    style: primaryTextStyle.copyWith(
                      fontWeight: semibold,
                      color: CustomColor.subtitleTextColor,
                      fontSize: 8,
                    ),
                  ),
            const SizedBox(
              height: 10,
            ),
            Text(
              'Terakhir diubah: ${itinerary.dateModified}',
              style: primaryTextStyle.copyWith(
                fontWeight: regular,
                fontSize: 12,
                color: CustomColor.subtitleTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
