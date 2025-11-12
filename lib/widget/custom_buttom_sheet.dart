import 'package:flutter/material.dart';
import 'package:iterasi1/resource/theme.dart';

class CustomBottomSheet extends StatefulWidget {
  const CustomBottomSheet({
    super.key,
  });

  @override
  State<CustomBottomSheet> createState() => _CustomBottomSheetState();
}

class _CustomBottomSheetState extends State<CustomBottomSheet> {
  TextEditingController titleController = TextEditingController();
  // Mendapatkan instance FirebaseAuth

  bool isEnable = false;
  bool _isLoading = false;

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(builder: (BuildContext context,
        StateSetter setModalState /*You can rename this!*/) {
      return Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Buat Itinerary Baru',
                      style: primaryTextStyle.copyWith(
                        fontSize: 16,
                        fontWeight: semibold,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(
                    Icons.close,
                    size: 20,
                    color: CustomColor.subtitleTextColor,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            TextField(
              controller: titleController,
              maxLength: 25,
              keyboardType: TextInputType.name,
              maxLines: 1,
              decoration: InputDecoration(
                isDense: true,
                counterText: "",
                contentPadding: const EdgeInsets.all(15),
                hintText: 'Masukan Nama Trip Anda',
                errorText: titleController.text.isEmpty ? null : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),
                errorBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.white, width: 2.0),
                  borderRadius: BorderRadius.circular(5.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: CustomColor.primaryColor600, width: 2.0),
                  borderRadius: BorderRadius.circular(5.0),
                ),
              ),
              style: primaryTextStyle.copyWith(
                fontSize: 14.0,
                // height: 1.5, // Tinggi baris ganda untuk mempertahankan tinggi 50
              ),
              onChanged: (value) {
                if (value.isNotEmpty) {
                  setModalState(() {
                    isEnable = true;
                  });
                } else {
                  setModalState(() {
                    isEnable = false;
                  });
                }
              },
            ),
            const SizedBox(
              height: 5,
            ),
            Text(
              'Maksimal 25 karakter ',
              style: primaryTextStyle.copyWith(
                  fontSize: 12,
                  fontWeight: regular,
                  color: CustomColor.subtitleTextColor),
            ),
            const SizedBox(
              height: 10,
            ),
            SizedBox(
              height: 45,
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isEnable
                      ? CustomColor.primaryColor500
                      : CustomColor.disabledColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100.0),
                  ),
                ),
                onPressed: isEnable
                    ? () async {
                        if (titleController.text.isEmpty) {
                          // setState(() {
                          //   showError = true;
                          // });
                        } else {
                          setModalState(() {
                            _isLoading = true;
                          });
                          Navigator.of(context).pop(titleController.text);
                        }
                      }
                    : () {},
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : Text(
                        "SELANJUTNYA",
                        style: primaryTextStyle.copyWith(
                          color: CustomColor.whiteColor,
                          fontWeight: semibold,
                        ),
                      ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      );
    });
  }
}
