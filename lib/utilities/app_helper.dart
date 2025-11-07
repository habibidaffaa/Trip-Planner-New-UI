class AppHelper {
  static String formatDate(String inputDate) {
    try {
      // Split the input date by "/"
      List<String> dateParts = inputDate.split('/');

      if (dateParts.length != 3) {
        return 'Invalid date format';
      }

      // Extract day, month, and year
      String day = dateParts[0];
      String month = dateParts[1];
      String year = dateParts[2];

      // Convert month number to month name abbreviation
      List<String> months = [
        'JAN',
        'FEB',
        'MAR',
        'APR',
        'MAY',
        'JUN',
        'JUL',
        'AUG',
        'SEP',
        'OCT',
        'NOV',
        'DEC'
      ];

      // Parse month as integer and subtract 1 for zero-based index
      int monthIndex = int.parse(month) - 1;

      // Check if month index is valid
      if (monthIndex < 0 || monthIndex >= months.length) {
        return 'Invalid month';
      }

      String monthName = months[monthIndex];

      // Format the output
      return '$day $monthName $year';
    } catch (e) {
      return 'Error: $e';
    }
  }

  static int calculateDurationInMinutes(String startTime, String endTime) {
    try {
      // Split the time strings to get hours and minutes
      List<String> startParts = startTime.split('.');
      List<String> endParts = endTime.split('.');

      if (startParts.length != 2 || endParts.length != 2) {
        throw FormatException('Invalid time format. Expected HH:MM');
      }

      // Parse hours and minutes to integers
      int startHour = int.parse(startParts[0]);
      int startMinute = int.parse(startParts[1]);
      int endHour = int.parse(endParts[0]);
      int endMinute = int.parse(endParts[1]);

      // Validate time values
      if (startHour < 0 ||
          startHour > 23 ||
          endHour < 0 ||
          endHour > 23 ||
          startMinute < 0 ||
          startMinute > 59 ||
          endMinute < 0 ||
          endMinute > 59) {
        throw FormatException(
            'Hours must be between 0-23 and minutes between 0-59');
      }

      // Convert both times to minutes since midnight
      int startTotalMinutes = (startHour * 60) + startMinute;
      int endTotalMinutes = (endHour * 60) + endMinute;

      // Handle cases where end time is on the next day
      if (endTotalMinutes < startTotalMinutes) {
        endTotalMinutes += 24 * 60; // Add 24 hours in minutes
      }

      // Calculate the difference
      return endTotalMinutes - startTotalMinutes;
    } catch (e) {
      print('Error calculating duration: $e');
      return -1; // Return -1 to indicate an error
    }
  }
}
