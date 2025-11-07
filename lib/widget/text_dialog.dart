import 'package:flutter/material.dart';
import 'package:iterasi1/resource/theme.dart';

Future<T?> showTextDialog<T>(
  BuildContext context, {
  required String title,
  required String value,
}) =>
    showDialog<T>(
      context: context,
      builder: (context) => TextDialogWidget(
        title: title,
        value: value,
      ),
    );

class TextDialogWidget extends StatefulWidget {
  final String title;
  final String value;
  const TextDialogWidget({Key? key, required this.title, required this.value})
      : super(key: key);

  @override
  State<TextDialogWidget> createState() => _TextDialogWidgetState();
}

class _TextDialogWidgetState extends State<TextDialogWidget> {
  late TextEditingController controller;
  String? errorText;
  bool isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.value);
    isButtonEnabled = _isInputValid(widget.value);
  }

  bool _isInputValid(String input) {
    return input.trim().isNotEmpty;
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        titlePadding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        backgroundColor:
            CustomColor.backgroundColor, // Background untuk content
        title: Container(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          decoration: BoxDecoration(
            color: CustomColor.primary, // Background untuk title
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12.0),
              topRight: Radius.circular(12.0),
            ),
          ),
          child: Text(
            widget.title,
            style: primaryTextStyle.copyWith(
              fontSize: 16,
              fontWeight: semibold,
              color: CustomColor.whiteColor, // Warna teks title
            ),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: controller,
              onChanged: (value) {
                setState(() {
                  isButtonEnabled = _isInputValid(value);
                  if (!isButtonEnabled) {
                    errorText = "Judul tidak boleh kosong!";
                  } else {
                    errorText = null;
                  }
                });
              },
              decoration: InputDecoration(
                filled: true,
                hintStyle: primaryTextStyle.copyWith(
                  fontSize: 14,
                  color: CustomColor.subtitleTextColor,
                ),
                hintText: 'Masukan Judul Perjalanan Anda',
                errorText: errorText,
                fillColor: CustomColor.whiteColor,
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: CustomColor.primary,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(
              height: 14,
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith<Color>(
                    (Set<WidgetState> states) {
                      if (states.contains(WidgetState.disabled)) {
                        return Colors.grey;
                      }
                      return CustomColor.buttonColor; // Warna tombol default
                    },
                  ),
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                onPressed: isButtonEnabled
                    ? () {
                        Navigator.of(context).pop(controller.text);
                      }
                    : null,
                child: const Text(
                  'Selesai',
                  style: TextStyle(color: CustomColor.surface),
                ),
              ),
            ),
          ],
        ),
      );
}
