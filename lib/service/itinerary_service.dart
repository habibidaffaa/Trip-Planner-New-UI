import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:iterasi1/model/itinerary.dart';
import 'package:iterasi1/utilities/app_env.dart';

class ItineraryService {
  final String apiUrl = "https://api.openai.com/v1/chat/completions";

  Future<Itinerary> fetchItinerary({
    required String departure,
    required String destination,
    required List<String> dates,
  }) async {
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${AppEnv.gptKey}',
    };

    String content =
        """Buatkan itinerary untuk liburan pada tanggal ${dates.toString()} dari kota $departure ke kota $destination.
        Untuk outputnya harus memperhatikan aturan berikut:
        - wajib menggunakan bahasa indonesia
        - tanggal pada field date harus dalam format 'DD/MM/YYYY'
        - Untuk aktivitas di tempat wisata, sertakan `latitude` dan `longitude` (contoh: Kebun Binatang Surabaya 7.2962, 112.7366)
        - Untuk aktivitas seperti check-in hotel atau perjalanan, isi `latitude` dan `longitude` dengan `null`
        - Untuk `lokasi` pada aktivitas wajib menggunakan alamat lengkap nama tempat tersebut dengan format (nama tempat, kota)
        - activities berisikan title, location, start_time ('HH.mm'), end_time ('HH.mm') dan description
        """;

    final body = jsonEncode({
      "model": "gpt-4o-2024-08-06",
      "messages": [
        {
          "role": "system",
          "content": "You are a helpful travel itinerary assistant."
        },
        {"role": "user", "content": content}
      ],
      "response_format": {
        "type": "json_schema",
        "json_schema": {
          "name": "create_itinerary",
          "strict": true,
          "schema": {
            "type": "object",
            "properties": {
              "itinerary": {
                "type": "array",
                "items": {
                  "type": "object",
                  "properties": {
                    "date": {"type": "string"},
                    "activities": {
                      "type": "array",
                      "items": {
                        "type": "object",
                        "properties": {
                          "title": {"type": "string"},
                          "location": {"type": "string"},
                          "start_time": {"type": "string"},
                          "end_time": {"type": "string"},
                          "description": {"type": "string"},
                          "latitude": {
                            "type": ["number", "null"]
                          },
                          "longitude": {
                            "type": ["number", "null"]
                          }
                        },
                        "required": [
                          "title",
                          "location",
                          "start_time",
                          "end_time",
                          "description",
                          "latitude",
                          "longitude"
                        ],
                        "additionalProperties": false
                      }
                    }
                  },
                  "required": ["date", "activities"],
                  "additionalProperties": false
                }
              }
            },
            "required": ["itinerary"],
            "additionalProperties": false
          }
        }
      }
    });

    try {
      final response =
          await http.post(Uri.parse(apiUrl), headers: headers, body: body);
      // final rawData = await rootBundle.loadString('assets/response.json');
      // log('raw data: $rawData');
      // final jsonResponse = jsonDecode(rawData);
      // final content =
      //     jsonDecode(jsonResponse['choices'][0]['message']['content']);
      // log('isi itinerary data: ${content['itinerary']}');
      // return Itinerary.fromJsonGPT(content);
      log(response.body);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        // log(jsonResponse['choices'][0]['message']['content']);
        final content =
            jsonDecode(jsonResponse['choices'][0]['message']['content']);
        return Itinerary.fromJsonGPT(content);
      } else {
        throw Exception("Failed to fetch itinerary: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }
}
