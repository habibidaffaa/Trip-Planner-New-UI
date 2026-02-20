import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart'; // Tambahkan package ini
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:iterasi1/model/itinerary.dart';
import 'package:iterasi1/pages/add_activities/suggestion_page.dart';
import 'package:iterasi1/provider/itinerary_provider.dart';
import 'package:iterasi1/resource/theme.dart';
import 'package:provider/provider.dart';

import '../../widget/loading_overlay.dart';

class FormSuggestion extends StatefulWidget {
  final List<DateTime> selectedDays;

  const FormSuggestion({super.key, required this.selectedDays});

  @override
  FormSuggestionState createState() => FormSuggestionState();
}

class FormSuggestionState extends State<FormSuggestion> {
  final TextEditingController _departureController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();


  final String _googleMapsApiKey = 'AIzaSyCe96AAiABekFCX0Dq5kIsKDUAK6bhtIwg';

  // Fungsi untuk mengambil saran dari Google Maps API
  Future<List<Map<String, dynamic>>> _getSuggestions(String query) async {
    if (query.isEmpty) return [];

    final url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&key=$_googleMapsApiKey&components=country:id';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final predictions = json.decode(response.body)['predictions'] as List;
        return predictions.map<Map<String, dynamic>>((p) {
          return {
            'description': p['description'],
            'place_id': p['place_id'],
          };
        }).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  void dispose() {
    _departureController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColor.whiteColor,
      appBar: AppBar(
        backgroundColor: CustomColor.primaryColor500,
        title: Column(
          children: [
            Text(
              'Pilih Lokasi Asal-Tujuan',
              style: primaryTextStyle.copyWith(
                fontWeight: semibold,
                fontSize: 18,
                color: CustomColor.whiteColor,
              ),
            ),
            Text(
              '${DateFormat('dd MMM').format(widget.selectedDays.first)} - ${DateFormat('dd MMM').format(widget.selectedDays.last)}',
              style: primaryTextStyle.copyWith(
                fontSize: 14,
                color: CustomColor.whiteColor,
              ),
            ),
          ],
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
      body: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 20,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                scrollDirection: Axis.vertical,
                children: [
                  // --- INPUT LOKASI BERANGKAT ---
                  _buildInputLabel("Lokasi Berangkat"),
                  const SizedBox(height: 10),
                  _buildAutocompleteField(
                      _departureController, 'Masukkan Lokasi Berangkat'),

                  const SizedBox(height: 20),

                  // --- INPUT LOKASI TUJUAN ---
                  _buildInputLabel("Lokasi Tujuan"),
                  const SizedBox(height: 10),
                  _buildAutocompleteField(
                      _destinationController, 'Masukkan Lokasi Tujuan'),

                  const SizedBox(height: 40),

                  // --- TOMBOL SUBMIT ---
                  _buildSubmitButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget Label agar code lebih bersih
  Widget _buildInputLabel(String label) {
    return Text(
      label,
      style: primaryTextStyle.copyWith(
        fontSize: 14,
        color: Colors.black,
      ),
    );
  }

  // Widget Autocomplete yang mengadopsi dekorasi asli Anda
  Widget _buildAutocompleteField(
      TextEditingController controller, String hint) {
    return PhysicalModel(
      borderRadius: BorderRadius.circular(8),
      color: Colors.white,
      shadowColor: CustomColor.subtitleTextColor,
      child: TypeAheadField<Map<String, dynamic>>(
        controller: controller,
        suggestionsCallback: _getSuggestions,
        itemBuilder: (context, suggestion) {
          return ListTile(
            title: Text(
              suggestion['description'],
              style: primaryTextStyle.copyWith(fontSize: 12),
            ),
          );
        },
        onSelected: (suggestion) {
          setState(() {
            controller.text = suggestion['description'];
          });
        },
        // Bagian builder ini memungkinkan kita menggunakan dekorasi asli Anda
        builder: (context, child, focusNode) {
          return TextField(
            controller: controller,
            focusNode: focusNode,
            onChanged: (value) => setState(() {}),
            style: primaryTextStyle.copyWith(
              fontWeight: semibold,
              fontSize: 12,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: primaryTextStyle.copyWith(
                color: CustomColor.subtitleTextColor,
                fontSize: 12,
              ),
              filled: true,
              fillColor: CustomColor.whiteColor,
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: CustomColor.subtitleTextColor,
                  width: 0.5,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: CustomColor.primaryColor600,
                  width: 1,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              suffixIcon: controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        setState(() {
                          controller.clear();
                        });
                      },
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }

  Widget _buildSubmitButton() {
    bool isFormValid = _departureController.text.isNotEmpty &&
        _destinationController.text.isNotEmpty;

    return InkWell(
      onTap: isFormValid
          ? () async {
              LoadingOverlay.show(context);
              try {
                List<Itinerary> results = await context
                    .read<ItineraryProvider>()
                    .generateItineraryByAi(
                      departure: _departureController.text,
                      destination: _destinationController.text,
                      dates: widget.selectedDays,
                    );

                LoadingOverlay.hide();
                if (mounted) {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => SuggestionPage(
                        itineraries: results,
                      ),
                    ),
                  );
                }
              } catch (err) {
                LoadingOverlay.hide();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(err.toString())),
                );
              }
            }
          : null,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: isFormValid ? CustomColor.primaryColor500 : Colors.grey,
          borderRadius: const BorderRadius.all(Radius.circular(100.0)),
        ),
        alignment: Alignment.center,
        child: Text(
          "SUBMIT",
          style: primaryTextStyle.copyWith(
            color: CustomColor.whiteColor,
            fontWeight: semibold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
