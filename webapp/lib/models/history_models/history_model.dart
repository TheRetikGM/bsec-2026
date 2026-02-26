import 'package:ai_redakcia_frontend/models/history_models/Instagram_history_model.dart';
import 'package:ai_redakcia_frontend/models/history_models/tiktok_history_model.dart';
import 'package:ai_redakcia_frontend/models/history_models/youtube_history_model.dart';
import 'package:ai_redakcia_frontend/models/story_model.dart';

class HistoryModel {
  final int id;
  final DateTime date;
  final String topic;
  final String? promptText;
  final StoryModel? story;
  final YoutubeHistoryModel yt_model;
  final InstagramHistoryModel insta_model;
  final TikTokHistoryModel tiktokmodel;

  HistoryModel(
      {required this.id,
      required this.date,
      required this.topic,
      required this.yt_model,
      required this.insta_model,
      required this.tiktokmodel,
      this.promptText,
      this.story});

  static DateTime excelDateToDateTime(int excelDate) {
    // Excel dates are days since 1899-12-30
    return DateTime(1899, 12, 30).add(Duration(days: excelDate));
  }

  static int dateTimeToExcelDate(DateTime date) {
    return date.difference(DateTime(1899, 12, 30)).inDays;
  }

  factory HistoryModel.fromJson(Map<String, dynamic> json) {
    return HistoryModel(
      id: json['ID'] as int,
      date: excelDateToDateTime(json['Datum'] as int),
      topic: json['Téma'] ?? '',
      yt_model: YoutubeHistoryModel.fromJson(json),
      insta_model: InstagramHistoryModel.fromJson(json),
      tiktokmodel: TikTokHistoryModel.fromJson(json),
    );
  }

  /// TO JSON
  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'Datum': dateTimeToExcelDate(date),
      'Téma': topic,
      ...yt_model.toJson(),
      ...insta_model.toJson(),
      ...tiktokmodel.toJson(),
    };
  }
}
