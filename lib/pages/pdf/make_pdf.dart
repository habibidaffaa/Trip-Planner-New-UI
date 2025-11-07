import 'dart:typed_data';

import 'package:iterasi1/model/itinerary.dart';
import 'package:pdf/widgets.dart';

Future<Uint8List> makePdf(Itinerary itinerary) async {
  final pdf = Document();

  final List<Widget> activitiesTable = _buildActivitiesTable(itinerary);

  pdf.addPage(MultiPage(
    build: (context) => [
      Align(
          alignment: Alignment.center,
          child: Text(itinerary.title,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              textAlign: TextAlign.center)),
      ...activitiesTable
    ],
  ));
  return pdf.save();
}

List<Widget> _buildActivitiesTable(Itinerary itinerary) {
  final List<Widget> widgets = [];

  itinerary.days.forEach(
    (day) {
      widgets.add(
        SizedBox(height: 30),
      );

      widgets.add(
        Text(
          day.date,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      );

      widgets.add(
        SizedBox(height: 10),
      );

      widgets.add(
        Table.fromTextArray(
          headerAlignment: Alignment.center,
          cellAlignments: {
            0: Alignment.center,
            1: Alignment.center,
            2: Alignment.center,
            3: Alignment.topLeft
          },
          columnWidths: {
            0: const FlexColumnWidth(2),
            1: const FlexColumnWidth(3),
            2: const FlexColumnWidth(3),
            3: const FlexColumnWidth(3)
          },
          headerStyle: TextStyle(fontWeight: FontWeight.bold),
          cellStyle: const TextStyle(height: 1.5),
          data: [
            ['Waktu', 'Aktivitas', 'Lokasi', 'Keterangan'],
            ...day.activities.map(
              (activity) => [
                "${activity.startActivityTime} - ${activity.endActivityTime}",
                activity.activityName,
                activity.lokasi,
                activity.keterangan
              ],
            )
          ],
        ),
      );
    },
  );

  return widgets;
}
