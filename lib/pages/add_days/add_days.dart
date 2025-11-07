// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:iterasi1/model/alert_save_dialog_result.dart';
import 'package:iterasi1/pages/activity_photo_page.dart';
import 'package:iterasi1/pages/add_activities/add_activities.dart';
import 'package:iterasi1/pages/add_days/app_bar_itinerary_title.dart';
import 'package:iterasi1/pages/add_days/search_field.dart';
import 'package:iterasi1/pages/datepicker/select_date.dart';
import 'package:iterasi1/pages/itinerary_list.dart';
import 'package:iterasi1/pages/pdf/preview_pdf_page.dart';
import 'package:iterasi1/provider/database_provider.dart';
import 'package:iterasi1/resource/theme.dart';
import 'package:iterasi1/widget/activity_card.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';

import '../../model/activity.dart';
import '../../provider/itinerary_provider.dart';

class AddDays extends StatefulWidget {
  const AddDays({Key? key}) : super(key: key);

  @override
  State<AddDays> createState() => _AddDaysState();
}

class _AddDaysState extends State<AddDays> {
  // Provider
  late ItineraryProvider itineraryProvider;
  late DatabaseProvider databaseProvider;

  // State
  int selectedDayIndex = 0;
  bool isEditing = false;
  late Widget appBarTitle;
  late List<Widget> actionIcon;

  late ScaffoldMessengerState snackbarHandler;

// Fungsi untuk meminta permission galeri dan navigasi jika izin diberikan
  Future<void> requestGalleryPermission(Activity activity) async {
    var result = await PhotoManager
        .requestPermissionExtend(); // Langsung meminta permission dan mendapatkan hasilnya
    if (result.isAuth) {
      // Jika izin diberikan, navigasi ke ActivityPhotoPage
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ActivityPhotoPage(
              dayIndex: selectedDayIndex,
              activity:
                  activity), // Pastikan class ActivityPhotoPage menerima parameter activity
        ),
      );
    } else {
      // Tampilkan dialog jika izin tidak diberikan
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

  @override
  Widget build(BuildContext context) {
    snackbarHandler = ScaffoldMessenger.of(context);

    itineraryProvider = Provider.of(context, listen: true);
    databaseProvider = Provider.of(context, listen: true);

    if (isEditing) {
      appBarTitle = SearchField(
        initialText: itineraryProvider.itinerary.title,
        onSubmit: (String newTitle) {
          setState(
            () {
              itineraryProvider.setNewItineraryTitle(newTitle);
              isEditing = false;
            },
          );
        },
        onValueChange: (newTitle) {
          itineraryProvider.setNewItineraryTitle(newTitle);
        },
      );

      actionIcon = [];
    } else {
      appBarTitle =
          AppBarItineraryTitle(title: itineraryProvider.itinerary.title);

      actionIcon = [
        IconButton(
          icon: Icon(
            Icons.mode_edit_outlined,
            color: CustomColor.whiteColor,
          ),
          onPressed: () {
            setState(
              () {
                isEditing = true;
              },
            );
          },
        )
      ];
    }

    return LoaderOverlay(
      child: WillPopScope(
        onWillPop: handleBackBehaviour,
        child: Scaffold(
          backgroundColor: CustomColor.primary,
          appBar: AppBar(
            surfaceTintColor: CustomColor.transparentColor,
            title: appBarTitle,
            actions: actionIcon,
            centerTitle: true,
            leading: Padding(
              padding: const EdgeInsets.all(3.0),
              child: BackButton(
                style: IconButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: CustomColor.whiteColor,
                ),
                onPressed: () {
                  handleBackBehaviour().then(
                    (shouldPop) {
                      if (shouldPop) {
                        Navigator.popUntil(
                          context,
                          ModalRoute.withName(ItineraryList.route),
                        );
                      }
                    },
                  );
                },
              ),
            ),
            backgroundColor: CustomColor.primary,
            elevation: 0,
          ),
          body: Stack(
            children: [
              Container(
                color: CustomColor.whiteColor,
                // padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        SizedBox(
                          height: 60,
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                            ),
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                              return KartuTanggal(index,
                                  itineraryProvider.itinerary.days[index].date);
                            },
                            itemCount: itineraryProvider.itinerary.days.length,
                            separatorBuilder:
                                (BuildContext context, int index) {
                              return const SizedBox(
                                // height: 24,
                                width: 40,
                              );
                            },
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: InkWell(
                            onTap: () {
                              log(itineraryProvider.itinerary.days
                                  .map((e) => e.getDatetime())
                                  .toList()
                                  .toString());
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) {
                                    return SelectDate(
                                      isNewItinerary: false,
                                      initialDates: itineraryProvider
                                          .itinerary.days
                                          .map((e) => e.getDatetime())
                                          .toList(),
                                    );
                                  },
                                ),
                              );
                            },
                            child: Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(80),
                              ),
                              child: const Padding(
                                padding: EdgeInsets.all(1.0),
                                child: Icon(Icons.add),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    Divider(
                      height: 0,
                      color: CustomColor.subtitleTextColor,
                      thickness: 0.5,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 65),
                        child: FutureBuilder<List<Activity>>(
                          future: itineraryProvider.getSortedActivity(
                              itineraryProvider
                                  .itinerary.days[selectedDayIndex].activities),
                          builder: (context, snapshot) {
                            final data = snapshot.data;
                            if (data != null) {
                              return ListView.separated(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 24, 20, 0),
                                scrollDirection: Axis.vertical,
                                physics: const BouncingScrollPhysics(),
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  final currentActivity = data[index].copy();
                                  print(
                                      'activity card : ${data[index].startDateTime}');
                                  return ActivityCard(
                                    snackbarHandler: snackbarHandler,
                                    data: data[index],
                                    selectedDayIndex: selectedDayIndex,
                                    activityIndex: index,
                                    onUndo: () {
                                      itineraryProvider.insertNewActivity(
                                          activities: data,
                                          newActivity: currentActivity);
                                    },
                                    onDismiss: () {
                                      itineraryProvider.removeActivity(
                                          activities: data,
                                          removedHashCode:
                                              data[index].hashCode);
                                    },
                                  );
                                },
                                separatorBuilder:
                                    (BuildContext context, int index) {
                                  return const SizedBox(
                                    height: 24,
                                  );
                                },
                                itemCount: data.length,
                              );
                            } else {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                          },
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: CustomColor.whiteColor,
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x26000000),
                        blurRadius: 12,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  print(itineraryProvider.itinerary
                                      .days[selectedDayIndex].activities);
                                  return AddActivities(
                                    onSubmit: (newActivity) {
                                      itineraryProvider.insertNewActivity(
                                          activities: itineraryProvider
                                              .itinerary
                                              .days[selectedDayIndex]
                                              .activities,
                                          newActivity: newActivity);
                                      log("${itineraryProvider.itinerary.days[selectedDayIndex].activities.length}");
                                    },
                                  );
                                },
                              ),
                            );
                          },
                          child: Container(
                            height: 50,
                            // width: double.infinity,
                            decoration: BoxDecoration(
                              color: CustomColor.primaryColor500,
                              borderRadius: const BorderRadius.all(
                                Radius.circular(100.0),
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Tambah Aktivitas',
                              style: primaryTextStyle.copyWith(
                                fontWeight: semibold,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (builder) => PdfPreviewPage(
                                  itinerary: itineraryProvider.itinerary),
                            ),
                          );
                        },
                        customBorder: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            color: CustomColor.primaryColor500,
                            borderRadius: const BorderRadius.all(
                              Radius.circular(100.0),
                            ),
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.print,
                            size: 20,
                            color: CustomColor.surface,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      InkWell(
                        onTap: saveCurrentItinerary,
                        customBorder: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            color: CustomColor.primaryColor500,
                            borderRadius: const BorderRadius.all(
                              Radius.circular(100.0),
                            ),
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.save,
                            size: 20,
                            color: CustomColor.surface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget KartuTanggal(int index, String tanggal) {
    // Split the date string into day, month, and year components
    List<String> dateComponents = tanggal.split('/');
    int day = int.parse(dateComponents[0]);
    int month = int.parse(dateComponents[1]);
    int year = int.parse(dateComponents[2]);

    // Construct a DateTime object from the components
    final parsedDate = DateTime(year, month, day);

    final formattedDate = DateFormat("dd MMM yyyy").format(parsedDate);

    return InkWell(
      onTap: () {
        setState(() {
          selectedDayIndex = index;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          border: index == selectedDayIndex
              ? const Border(
                  bottom: BorderSide(
                    width: 3.0,
                    color: CustomColor.buttonColor,
                  ),
                )
              : null,
        ),
        child: Container(
          margin: const EdgeInsets.all(10),
          child: Column(
            children: [
              Text(
                'Hari ${index + 1}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'poppins_bold',
                  color: index == selectedDayIndex
                      ? CustomColor.buttonColor
                      : CustomColor.disabledColor,
                ),
              ),
              Text(
                formattedDate, // Use the formatted date
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'poppins_regular',
                  color: index == selectedDayIndex
                      ? CustomColor.buttonColor
                      : CustomColor.disabledColor,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  String getMonthString(int intMonth) {
    switch (intMonth) {
      case 1:
        return "Januari";
      case 2:
        return "Februari";
      default:
        return "Desember";
    }
  }


  Future<AlertSaveDialogResult?> showAlertSaveDialog(BuildContext context) {
    return showDialog<AlertSaveDialogResult?>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white, // Ubah warna latar belakang
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0), // Ubah bentuk border
          ),
          title: Column(
            children: [
              Container(
                // alignment: Alignment.center,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(100.0),
                  ),
                  color: CustomColor.warningColor.withOpacity(0.2),
                ),
                child: Icon(
                  Icons.warning_rounded,
                  size: 40,
                  color: CustomColor.warningColor,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                "Konfirmasi Perubahan Itinerary",
                textAlign: TextAlign.center,
                style: primaryTextStyle.copyWith(
                  // fontFamily: 'poppins_bold',
                  color: CustomColor.blackColor, // Ubah warna teks judul
                  fontSize: 16,
                  fontWeight: FontWeight.bold, // Teks judul menjadi tebal
                ),
              ),
            ],
          ),
          content: Text(
            "Itinerary Anda telah diubah. Simpan sebelum keluar?",
            style: primaryTextStyle.copyWith(
              fontSize: 14,
              color: CustomColor.subtitleTextColor,
            ),
            textAlign: TextAlign.center,
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: InkWell(
                    borderRadius: const BorderRadius.all(
                      Radius.circular(12.0),
                    ),
                    onTap: () {
                      Navigator.of(context)
                          .pop(AlertSaveDialogResult.saveWithoutQuit);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: CustomColor
                            .warningColor, // Ubah warna latar belakang
                        borderRadius:
                            BorderRadius.circular(8), // Ubah bentuk border
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                      ), // Atur padding
                      child: Text(
                        "Keluar Tanpa Menyimpan",
                        textAlign:
                            TextAlign.center, // Pusatkan teks dalam tombol
                        style: primaryTextStyle.copyWith(
                          // fontFamily: 'poppins_bold',
                          fontSize: 12,
                          fontWeight: semibold,
                          color: Colors.white, // Ubah warna teks
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context)
                          .pop(AlertSaveDialogResult.saveAndQuit);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color(0xFF4FD968), // Ubah warna latar belakang
                        borderRadius:
                            BorderRadius.circular(8), // Ubah bentuk border
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 4,
                      ), // Atur padding
                      child: Text(
                        "Simpan dan Keluar",
                        textAlign:
                            TextAlign.center, // Pusatkan teks dalam tombol
                        style: primaryTextStyle.copyWith(
                          // fontFamily: 'poppins_bold',
                          fontSize: 12,
                          fontWeight: semibold,
                          color: Colors.white, // Ubah warna teks
                        ),
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
  }

  Future<void> saveCurrentItinerary() {
    context.loaderOverlay.show();
    return databaseProvider
        .insertItinerary(itinerary: itineraryProvider.itinerary)
        .whenComplete(
      () {
        Navigator.popUntil(context, ModalRoute.withName(ItineraryList.route));
        context.loaderOverlay.hide();
      },
    );
  }

  Future<bool> handleBackBehaviour() async {
    if (itineraryProvider.isDataChanged) {
      final resultSaveDialog = await showAlertSaveDialog(context);

      late bool shouldPop;

      if (resultSaveDialog == AlertSaveDialogResult.saveWithoutQuit) {
        shouldPop = true;
      } else if (resultSaveDialog == AlertSaveDialogResult.saveAndQuit) {
        await saveCurrentItinerary();
        shouldPop = true;
      } else {
        shouldPop = false;
      }
      if (shouldPop) {
        snackbarHandler.removeCurrentSnackBar();
      }
      return shouldPop;
    } else {
      snackbarHandler.removeCurrentSnackBar();
      return true;
    }
  }
}
