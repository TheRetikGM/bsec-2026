import 'package:ai_redakcia_frontend/models/history_models/history_model.dart';

class TikTokHistoryModel extends HistoryModel {
  final String description;
  final String scenario;
  final int views;

  TikTokHistoryModel(
      {required super.id,
      required super.date,
      required this.description,
      required this.scenario,
      required this.views});

  factory TikTokHistoryModel.fromJson(Map<String, dynamic> json) {
    return TikTokHistoryModel(
      id: json['ID'],
      date: HistoryModel.excelDateToDateTime(json['Datum']),
      description: json['TikTok_popis'],
      scenario: json['TikTok_scénář'],
      views: json['TikTok_views'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'Datum': HistoryModel.dateTimeToExcelDate(date),
      'TikTok_popis': description,
      'TikTok_scénář': scenario,
      'TikTok_views': views,
    };
  }
}
