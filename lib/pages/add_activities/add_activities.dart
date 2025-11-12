import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:iterasi1/resource/theme.dart';
import 'package:iterasi1/widget/location_autocomplete_field.dart';
import 'package:iterasi1/widget/text_field_wirdget.dart';

import '../../model/activity.dart';

class AddActivities extends StatefulWidget {
  final Activity? initialActivity;
  final Function(Activity) onSubmit;

  const AddActivities(
      {this.initialActivity, required this.onSubmit, super.key});

  @override
  _AddActivitiesState createState() => _AddActivitiesState();
}

class _AddActivitiesState extends State<AddActivities> {
  TimeOfDay _selectedStartTime = TimeOfDay.now();
  TimeOfDay _selectedEndTime = TimeOfDay.now();
  bool _isEndTimeValid = true;
  bool _isTitleValid = true;
  // bool _isLocationValid = true;
  bool _showTitleValidationMessage =
      false; // Variabel kontrol untuk pesan validasi judul
  bool _showLocationValidationMessage =
      false; // Variabel kontrol untuk pesan validasi lokasi

  final TextEditingController titleController = TextEditingController();
  final TextEditingController lokasiController = TextEditingController();
  final TextEditingController keteranganController = TextEditingController();

  String? lokasi;
  double? latitude;
  double? longitude;
  bool _isLokasiValid = true;
  bool _isCustomLocation = false;

  bool _isFromAutocomplete = false;

  @override
  void initState() {
    if (widget.initialActivity != null) {
      titleController.text = widget.initialActivity!.activityName;
      lokasiController.text = widget.initialActivity!.lokasi;
      keteranganController.text = widget.initialActivity!.keterangan;
      _selectedStartTime = widget.initialActivity!.startTimeOfDay;
      _isCustomLocation = widget.initialActivity!.isCustomLocation;
      print('start time : $_selectedStartTime');
      _selectedEndTime = widget.initialActivity!.endTimeOfDay;
      print('end time : $_selectedEndTime');
      super.initState();
    }
    titleController.addListener(() {
      _validateTitle(showMessage: true);
    });
    lokasiController.addListener(() {
      _validateLocation(showMessage: true);
    });
    _validateTitle();
    _validateLocation();
  }

  void _validateTitle({bool showMessage = false}) {
    setState(() {
      _isTitleValid = titleController.text.trim().isNotEmpty;
      _showTitleValidationMessage = showMessage && !_isTitleValid;
    });
  }

  void _validateLocation({bool showMessage = false}) {
    setState(() {
      _isLokasiValid = lokasiController.text.trim().isNotEmpty;
      _showLocationValidationMessage = showMessage && !_isLokasiValid;
    });
  }

  Future<void> _selectStartTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedStartTime,
    );
    if (picked != null && picked != _selectedStartTime) {
      setState(
        () {
          _selectedStartTime = picked;
          _validateEndTime();
        },
      );
    }
  }

  Future<void> _selectEndTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedEndTime,
    );
    if (picked != null && picked != _selectedEndTime) {
      setState(
        () {
          _selectedEndTime = picked;
          _validateEndTime();
        },
      );
    }
  }

  void _validateEndTime() {
    setState(
      () {
        _isEndTimeValid = _selectedEndTime.hour > _selectedStartTime.hour ||
            (_selectedEndTime.hour == _selectedStartTime.hour &&
                _selectedEndTime.minute > _selectedStartTime.minute);
      },
    );
  }

  void _submitActivity() {
    final newActivity = Activity(
      activityName: titleController.text,
      lokasi: lokasiController.text,
      startActivityTime: _selectedStartTime.format(context),
      endActivityTime: _selectedEndTime.format(context),
      keterangan: keteranganController.text,
      removedImages: widget.initialActivity?.removedImages,
      isCustomLocation: _isCustomLocation,
    );

    log(_selectedStartTime.format(context));
    log(newActivity.toJson().toString());

    widget.onSubmit(newActivity);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isFormValid = _isEndTimeValid &&
        _isTitleValid &&
        (_isCustomLocation
            ? _isLokasiValid
            : (_isLokasiValid && _isFromAutocomplete));
    return Scaffold(
      backgroundColor: CustomColor.whiteColor,
      appBar: AppBar(
        // toolbarHeight: 118,
        backgroundColor: CustomColor.primaryColor500,
        title: Text(
          'Tambah Aktivitas',
          style: primaryTextStyle.copyWith(
            fontWeight: semibold,
            fontSize: 18,
            // fontFamily: 'poppins_bold',
            color: CustomColor.whiteColor,
          ),
          // itineraryProvider.itinerary.title,
        ),
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(3.0),
          child: BackButton(
            style: IconButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: CustomColor.whiteColor,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        elevation: 0,
      ),
      body: Stack(
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Judul",
                            style: TextStyle(
                              color: CustomColor.blackColor,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: titleController,
                            decoration: InputDecoration(
                              hintStyle: const TextStyle(fontSize: 16),
                              hintText: 'Cth. Persiapan Berangkat',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide: BorderSide(
                                  color:
                                      _isTitleValid ? Colors.grey : Colors.red,
                                  width: 2,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide: BorderSide(
                                  color: _isTitleValid
                                      ? CustomColor.primary
                                      : Colors.red,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                          if (_showTitleValidationMessage)
                            const Padding(
                              padding: EdgeInsets.only(top: 4.0),
                              child: Text(
                                'Judul tidak boleh kosong',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontFamily: 'Poppins',
                                  color: Colors.red,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      LocationAutocompleteField(
                        initialIsCustomLocation: _isCustomLocation,
                        controller: lokasiController,
                        isValid: _isLokasiValid,
                        onLocationChanged: (value, isCustom,
                            {bool fromAutocomplete = false}) {
                          setState(() {
                            lokasi = value;
                            _isCustomLocation = isCustom;
                            _isFromAutocomplete = fromAutocomplete;

                            _isLokasiValid = isCustom
                                ? value.trim().isNotEmpty
                                : fromAutocomplete && value.trim().isNotEmpty;

                            log("Lokasi dipilih: $value");
                            log("isCustom: $isCustom");
                            log("fromAutocomplete: $fromAutocomplete");
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Mulai',
                                  style: TextStyle(
                                    fontFamily: 'poppins_bold',
                                    fontSize: 20,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                SizedBox(
                                  width: double.infinity,
                                  child: GestureDetector(
                                    onTap: () => _selectStartTime(context),
                                    child: Container(
                                      width: 145,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: CustomColor.borderColor,
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 10),
                                              child: Text(
                                                _selectedStartTime
                                                    .format(context),
                                                style: const TextStyle(
                                                  fontFamily: 'Poppins',
                                                  fontSize: 20,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 5),
                                          const Icon(
                                            Icons.access_time,
                                            size: 30,
                                            color: Colors.black,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Selesai',
                                  style: TextStyle(
                                    fontFamily: 'poppins_bold',
                                    fontSize: 20,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                SizedBox(
                                  width: double.infinity,
                                  child: GestureDetector(
                                    onTap: () => _selectEndTime(context),
                                    child: Container(
                                      width: 145,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: CustomColor.borderColor,
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 10),
                                              child: Text(
                                                _selectedEndTime
                                                    .format(context),
                                                style: const TextStyle(
                                                  fontFamily: 'Poppins',
                                                  fontSize: 20,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 5),
                                          const Icon(
                                            Icons.access_time,
                                            size: 30,
                                            color: Colors.black,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (!_isEndTimeValid)
                        const Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: Text(
                            'Waktu Selesai tidak boleh mendahului Waktu Mulai!',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              color: Colors.red,
                            ),
                          ),
                        ),
                      const SizedBox(height: 25),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Keterangan',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            // overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: keteranganController,
                            keyboardType: TextInputType.multiline,
                            minLines: 4,
                            maxLines: null,
                            textAlignVertical: TextAlignVertical.center,
                            decoration: InputDecoration(
                              hintStyle: const TextStyle(fontSize: 16),
                              hintText:
                                  'Cth. Pastikan semua barang tidak ada yang tertinggal',
                              hintMaxLines: 3,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Colors.black,
                                  width: 2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 20),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
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
                      onTap: isFormValid ? _submitActivity : null,
                      child: Container(
                        height: 50,
                        // width: double.infinity,
                        decoration: BoxDecoration(
                          color: isFormValid
                              ? CustomColor.primary
                              : CustomColor.hintTextColor,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(100.0),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Simpan Aktivitas',
                          style: primaryTextStyle.copyWith(
                            fontWeight: semibold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
