import 'dart:convert';

import 'package:ai_redakcia_frontend/models/history_models/Instagram_history_model.dart';
import 'package:ai_redakcia_frontend/models/history_models/history_model.dart';
import 'package:ai_redakcia_frontend/models/history_models/tiktok_history_model.dart';
import 'package:ai_redakcia_frontend/models/history_models/youtube_history_model.dart';
import 'package:ai_redakcia_frontend/services/api_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/platform_stories_model.dart';
import '../models/profile_model.dart';
import '../models/story_model.dart';
import '../models/topic_model.dart';

final storyGenServiceProvider = Provider<StoryGenService>((ref) {
  return StoryGenService();
});

class StoryGenService {
  final ApiService _apiService;

  StoryGenService() : _apiService = ApiService(host: "https://bsec-2026.datovka.eu") {}

  Future<List<ProfileModel>> generateTopics(TopicModel topic) async {
    try {
      final response = await _apiService.postJson(
        // path: '/webhook/generate-topics',
        path: '/webhook/test', //testing url
        body: topic.toJson(),
      );

      final profilesJson = response as List<dynamic>;

      return profilesJson.map((e) => ProfileModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<StoryModel> writeStory(ProfileModel topic) async {
    final json = await _apiService.postJson(
      // path: '/webhook-test/writer',
      path: '/webhook/writer',
      body: topic.toJson(),
    );

    return StoryModel.fromJson(json);
  }

  Future<PlatformStoriesModel> createPlatformStories(StoryModel topic) async {
    final json = await _apiService.postJson(
      path: '/create-platform-stories', // change later
      body: topic.toJson(),
    );

    return PlatformStoriesModel.fromJson(json);
  }

  /// Uploads the user's history to the API.
  ///
  /// The API is expected to return a short text description of user characteristics.
  /// This method tries to extract a text field from common response shapes.
Future<String?> submitHistory(List<HistoryModel> histories) async {
  final jsonList = histories.map((history) => history.toJson()).toList();

  final resp = await _apiService.postJson(
    path: '/webhook/import_memory',
    body: jsonList,
  );

  String? extractText(dynamic v) {
    if (v == null) return null;
    if (v is String) return v;

    if (v is Map) {
      // 1. Target the 'text_goal' field
      final textGoal = v['communication_style'];

      if (textGoal is Map) {
        // 2. Extract 'description' from within 'text_goal'
        final description = textGoal['description'];
        if (description is String && description.trim().isNotEmpty) {
          return description;
        }
      } 
      
      // Optional: Fallback to top-level description if text_goal is missing
      if (v['description'] is String) return v['description'];
    }

    return null;
  }

  return extractText(resp);
}

  Future<bool> submitYoutubeHistory(List<YoutubeHistoryModel> youtube_histories) async {
    final jsonList = youtube_histories.map((history) => history.toJson()).toList();

    final json = await _apiService.postJson(
      path: '/submit_youtube_history', // change later
      body: jsonList,
    );

    return true;
  }

  Future<bool> submitTikTokHistory(List<TikTokHistoryModel> tiktok_histories) async {
    final jsonList = tiktok_histories.map((history) => history.toJson()).toList();

    final json = await _apiService.postJson(
      path: '/submit_tiktok_history', // change later
      body: jsonList,
    );

    return true;
  }

  Future<bool> submitInstagramHistory(List<InstagramHistoryModel> instagram_histories) async {
    final jsonList = instagram_histories.map((history) => history.toJson()).toList();

    final json = await _apiService.postJson(
      path: '/submit_instagram_history', // change later
      body: jsonList,
    );

    return true;
  }
}
