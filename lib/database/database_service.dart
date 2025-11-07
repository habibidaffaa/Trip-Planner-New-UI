import 'dart:convert';

import 'package:iterasi1/utilities/date_time_formatter.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:developer' as developer;
import '../model/itinerary.dart';
import 'package:flutter/services.dart';

class DatabaseService {
  static const _dbName = 'itinerary_db';
  static const _itinerariesTableName = "itineraries";

  static final DatabaseService _singletonInstance =
      DatabaseService._internalConstructor();
  factory DatabaseService() {
    return _singletonInstance;
  }
  DatabaseService._internalConstructor();

  Database? _database;

  Future<Database> get database async {
    _database ??= await openDatabase(
      join(await getDatabasesPath(), _dbName),
      onCreate: (database, version) async {
        await database.execute("CREATE TABLE $_itinerariesTableName("
            "id STRING PRIMARY KEY,"
            "data STRING"
            ")");
      },
      version: 1,
    );
    return _database!;
  }

  Future<void> insertItinerary(Itinerary itinerary) async {
    late Database db;
    late Map<String, String> dataMap;

    try {
      itinerary.dateModified = DateTimeFormatter.toDMY(DateTime.now());

      db = await database;
      dataMap = {"id": itinerary.id, "data": itinerary.toJsonString()};

      developer.log("Mencoba insert", name: "qqq");
      // final tables = await db.query("sqlite_master", where: "type = 'table'");
      // for (final table in tables) {
      //   developer.log("Nama Table : ${table["name"]}" , name : "qqq");
      // }

      /*await db.rawInsert(
          "INSERT OR REPLACE INTO "
              "$_itinerariesTableName(id , data) "
              "VALUES('${dataMap["id"]}' , '${dataMap["data"]}')"
      );*/

      await db.insert(_itinerariesTableName, dataMap,
          conflictAlgorithm: ConflictAlgorithm.ignore);

      await db.update(_itinerariesTableName, dataMap,
          where: "id = ?", whereArgs: [itinerary.id]);

      developer.log("Berhasil insert atau update", name: "qqq");
    } catch (e) {
      developer.log(e.toString(), name: "qqq");
    }
  }

  Future<List<Itinerary>> fetchItineraries({
    String filterItineraryName = "",
  }) async {
    try {
      final db = await database;
      print('fetch itineraries dipanggil;');
      final hasilQuery = (await db.query(_itinerariesTableName))
          .map((rawData) {
            final jsonString = rawData['data']!.toString();
            developer.log(jsonString);
            return Itinerary.fromJson(jsonDecode(jsonString));
          })
          .cast<Itinerary>()
          .toList();
      print('map selesai ${hasilQuery.length} ${hasilQuery.runtimeType}');
      // print('${hasilQuery[1].id} ${hasilQuery[1].firstDate}');
      final hasilFilter = hasilQuery.where((itinerary) {
        print('where jalan');
        return itinerary.title
            .contains(RegExp(filterItineraryName, caseSensitive: false));
      }).toList();
      print(' query');
      return hasilFilter;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteItinerary(String id) async {
    final db = await database;

    await db.delete(_itinerariesTableName, where: "id = ?", whereArgs: [id]);
  }

  Future<List<Map<String, String>>> parseCsvData() async {
    final csvData = await rootBundle.loadString('assets/Dataset.csv');
    final lines = LineSplitter.split(csvData).toList();
    final headers = lines.first.split(',');

    return lines.skip(1).map((line) {
      final values = line.split(',');
      return Map.fromIterables(headers, values);
    }).toList();
  }
}
