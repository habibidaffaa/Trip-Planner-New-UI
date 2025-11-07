import 'package:flutter/material.dart';
import 'package:iterasi1/resource/theme.dart';

class SearchField extends StatefulWidget {
  final String initialText;
  final Function(String) onSubmit;
  final Function(String) onValueChange;

  SearchField(
      {required this.initialText,
      required this.onSubmit,
      required this.onValueChange,
      Key? key})
      : super(key: key);

  @override
  State createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  late TextEditingController controller;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.initialText);
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      textInputAction: TextInputAction.done,
      controller: controller,
      onChanged: widget.onValueChange,
      onSubmitted: widget.onSubmit,
      style: primaryTextStyle.copyWith(
        fontWeight: semibold,
        color: Colors.white,
      ),
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.zero,
        suffixIcon: IconButton(
            onPressed: () {
              widget.onSubmit(controller.text);
            },
            icon: const Icon(Icons.close, color: Colors.white)),
        border: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white)),
        focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white)),
        enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white)),
      ),
    );
  }
}
