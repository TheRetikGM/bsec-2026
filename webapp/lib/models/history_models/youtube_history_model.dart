import 'package:ai_redakcia_frontend/models/history_models/history_model.dart';

class YoutubeHistoryModel extends HistoryModel {
  final String topic;
  final String story;
  final int views;

  YoutubeHistoryModel({
    required super.id,
    required super.date,
    required this.topic,
    required this.story,
    required this.views,
  });

  factory YoutubeHistoryModel.fromJson(Map<String, dynamic> json) {
    return YoutubeHistoryModel(
      id: json['ID'],
      date: HistoryModel.excelDateToDateTime(json['Datum']),
      topic: json['Téma'],
      story: json['YouTube_scénář'],
      views: json['YouTube_views'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'Datum': HistoryModel.dateTimeToExcelDate(date),
      'Téma': topic,
      'YouTube_scénář': story,
      'YouTube_views': views,
    };
  }
}
