import 'package:ai_redakcia_frontend/models/history_models/history_model.dart';

class InstagramHistoryModel extends HistoryModel {
  final String description;
  final String photo_description;
  final int likes;

  InstagramHistoryModel(
      {required super.id,
      required super.date,
      required this.description,
      required this.photo_description,
      required this.likes});

  factory InstagramHistoryModel.fromJson(Map<String, dynamic> json) {
    return InstagramHistoryModel(
      id: json['ID'],
      date: HistoryModel.excelDateToDateTime(json['Datum']),
      description: json['Instagram_popis'],
      photo_description: json['Instagram_fotky'],
      likes: json['Instagram_likes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'Datum': HistoryModel.dateTimeToExcelDate(date),
      'Instagram_popis': description,
      'Instagram_fotky': photo_description,
      'Instagram_likes': likes,
    };
  }
}
