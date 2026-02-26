abstract class HistoryModel {
  final int id;
  final DateTime date;

  HistoryModel({required this.id, required this.date});

  static DateTime excelDateToDateTime(int excelDate) {
    // Excel dates are days since 1899-12-30
    return DateTime(1899, 12, 30).add(Duration(days: excelDate));
  }

  static int dateTimeToExcelDate(DateTime date) {
    return date.difference(DateTime(1899, 12, 30)).inDays;
  }
}
