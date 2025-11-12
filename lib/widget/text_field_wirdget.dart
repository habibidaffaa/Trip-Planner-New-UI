// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../resource/theme.dart';

class TextFieldWidget extends StatelessWidget {
  final String? label;
  final String? hintText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final bool required;
  final bool readonly;
  final bool obscureText;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final TextStyle? errorStyle;
  final TextStyle? hintStyle;
  final int? maxLines;
  final int? minLines;
  final FontWeight? fontWeight;
  final Color? color;
  final Color? cursorColor;
  final int? maxCharValidation;
  final int? minCharValidation;
  final Color? fillColor;
  final TextAlign? textAlign;
  final Color? labelColor;
  final InputBorder? border;
  final InputBorder? defaultBorder;
  final InputBorder? focusedBorder;
  final InputBorder? errorBorder;
  final Function(String value)? onChanged;
  final FocusNode? focusNode;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;
  final AutovalidateMode? autovalidateMode;
  final GlobalKey<FormFieldState>? formFieldKey;
  final GlobalKey? scrollAnchorKey;
  final VoidCallback? onFieldTap;
  final EdgeInsetsGeometry? contentPadding;
  final String? requiredMark;
  final TextInputAction? textInputAction;
  const TextFieldWidget({
    super.key,
    this.label,
    this.hintText,
    this.controller,
    this.validator,
    required this.required,
    this.readonly = false,
    this.obscureText = false,
    this.suffixIcon,
    this.errorStyle,
    this.hintStyle,
    this.maxLines = 1,
    this.minLines,
    this.fontWeight,
    this.cursorColor,
    this.color,
    this.maxCharValidation,
    this.minCharValidation,
    this.fillColor,
    this.textAlign,
    this.labelColor,
    this.border,
    this.onChanged,
    this.focusNode,
    this.inputFormatters,
    this.keyboardType,
    this.autovalidateMode,
    this.formFieldKey,
    this.scrollAnchorKey,
    this.onFieldTap,
    this.contentPadding,
    this.requiredMark,
    this.prefixIcon,
    this.textInputAction,
    this.focusedBorder,
    this.errorBorder,
    this.defaultBorder,
  });

  @override
  Widget build(BuildContext context) {
    Color defaultColor = CustomColor.blackColor;

    // InputBorder? inputBorder = OutlineInputBorder(
    //   borderRadius: const BorderRadius.all(Radius.circular(15)),
    //   borderSide: BorderSide(color: defaultColor, width: 1),
    // );
    InputBorder? inputBorder = border ??
        OutlineInputBorder(
          borderSide: BorderSide(
            width: 1.0,
            // color: CustomColor.disabledColor,
          ),
          borderRadius: BorderRadius.circular(5.0),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Container(
            key: scrollAnchorKey,
            margin: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                Text(
                  label ?? '',
                  style: TextStyle(
                    color: labelColor ?? CustomColor.blackColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  requiredMark ?? (required ? ' *' : ''),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        TextFormField(
          cursorColor: cursorColor ?? CustomColor.primary,
          textInputAction: textInputAction,
          onTap: onFieldTap,
          key: formFieldKey,
          controller: controller,
          obscureText: obscureText,
          focusNode: focusNode,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          onChanged: onChanged,
          maxLines: maxLines,
          readOnly: readonly,
          minLines: minLines,
          autovalidateMode: autovalidateMode,
          validator: validator ??
              (value) {
                final normalized = normalizeSpaces(value);

                if (normalized.isEmpty && required) {
                  return '${(label ?? 'input')} field is required.';
                }

                if (minCharValidation != null &&
                    normalized.length < minCharValidation!) {
                  return 'Must be at least $minCharValidation characters.';
                }

                if (maxCharValidation != null &&
                    normalized.length > maxCharValidation!) {
                  return 'Must not exceed $maxCharValidation characters.';
                }

                return null;
              },
          textAlign: textAlign ?? TextAlign.start,
          style: TextStyle(
            color: color ?? defaultColor,
            fontWeight: fontWeight ?? FontWeight.w600,
          ),
          decoration: InputDecoration(
            contentPadding: contentPadding,
            isDense: true, // Added this
            suffixIcon: suffixIcon,
            prefixIcon: prefixIcon,
            hintText: hintText,
            hintStyle: hintStyle ??
                TextStyle(
                  color: CustomColor.hintTextColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
            errorStyle: errorStyle ??
                TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontWeight: FontWeight.w500,
                  fontSize: 10,
                ),
            fillColor: fillColor ?? Colors.grey.shade200,
            filled: true,
            focusedBorder: focusedBorder ?? inputBorder,
            errorBorder: errorBorder ?? inputBorder,
            focusedErrorBorder: inputBorder,
            enabledBorder: inputBorder,
            border: defaultBorder ?? inputBorder,
          ),
        ),
      ],
    );
  }

  String normalizeSpaces(String? input) {
    if (input == null) return '';
    return input
        .trim() // hapus spasi depan & belakang
        .replaceAll(RegExp(r'\s+'), ' '); // jadikan spasi antar kata = 1
  }
}
