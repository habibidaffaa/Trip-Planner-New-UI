// 'AIzaSyCe96AAiABekFCX0Dq5kIsKDUAK6bhtIwg'; // Ganti dengan API Key Anda

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;

class LocationAutocompleteField extends StatefulWidget {
  final Function(String location, bool isCustom, {bool fromAutocomplete})
      onLocationChanged;

  final bool isValid;
  final TextEditingController controller;

  const LocationAutocompleteField({
    Key? key,
    required this.onLocationChanged,
    required this.isValid,
    required this.controller,
  }) : super(key: key);

  @override
  State<LocationAutocompleteField> createState() =>
      _LocationAutocompleteFieldState();
}

class _LocationAutocompleteFieldState extends State<LocationAutocompleteField> {
  final String _apiKey = 'AIzaSyCe96AAiABekFCX0Dq5kIsKDUAK6bhtIwg';
  bool isCustomLocation = false;

  Future<List<Map<String, dynamic>>> _getSuggestions(String query) async {
    final url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&key=$_apiKey&language=id';
    final response = await http.get(Uri.parse(url));
    final predictions = json.decode(response.body)['predictions'] as List;

    return predictions.map<Map<String, dynamic>>((p) {
      return {
        'description': p['description'],
        'place_id': p['place_id'],
      };
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() {
      setState(() {}); // untuk update tombol clear
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Lokasi",
          style: TextStyle(
            fontFamily: 'poppins_bold',
            fontSize: 20,
            color: Colors.black,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Switch(
              value: isCustomLocation,
              onChanged: (value) {
                setState(() {
                  isCustomLocation = value;
                  widget.controller.clear();
                  widget.onLocationChanged(
                      '', value); // kosongkan saat ganti mode
                });
              },
              activeColor: const Color(0xFF305A5A),
            ),
            Text(
              "Gunakan lokasi manual",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        isCustomLocation ? _buildManualField() : _buildAutocompleteField(),
      ],
    );
  }

  Widget _buildManualField() {
    return TextField(
      controller: widget.controller,
      onChanged: (value) {
        widget.onLocationChanged(value, true, fromAutocomplete: false);
      },
      decoration: InputDecoration(
        hintText: 'Contoh: Rumah Nenek, Rest Area KM 57',
        hintStyle: const TextStyle(fontSize: 16),
        suffixIcon: widget.controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  widget.controller.clear();
                  widget.onLocationChanged('', true, fromAutocomplete: false);
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: widget.isValid ? Colors.grey : Colors.red,
            width: 2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: widget.isValid ? const Color(0xFF305A5A) : Colors.red,
            width: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildAutocompleteField() {
    return TypeAheadField<Map<String, dynamic>>(
      controller: widget.controller,
      suggestionsCallback: _getSuggestions,
      itemBuilder: (context, suggestion) {
        return ListTile(
          title: Text(suggestion['description']),
        );
      },
      onSelected: (suggestion) {
        widget.controller.text = suggestion['description'];
        widget.onLocationChanged(
          suggestion['description'],
          false,
          fromAutocomplete: true, // ✅ ditambahkan
        );
      },
      builder: (context, child, focusNode) {
        return TextField(
          controller: widget.controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            hintText: 'Cth. Bandara Juanda, Monas, Hotel Majapahit',
            hintStyle: const TextStyle(fontSize: 16),
            suffixIcon: widget.controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      widget.controller.clear();
                      widget.onLocationChanged('', false,
                          fromAutocomplete: false);
                    },
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: widget.isValid ? Colors.grey : Colors.red,
                width: 2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: widget.isValid ? const Color(0xFF305A5A) : Colors.red,
                width: 2,
              ),
            ),
          ),
        );
      },
    );
  }
}
