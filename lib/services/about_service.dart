/* import '../models/about_model.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class AboutService {
  final ApiService _api = ApiService();

  Future<AboutModel?> fetchAbout() async {
    try {
      // 🔥 Get entityId from login storage
      final entityId = await AuthService().getEntityId();

      if (entityId == null || entityId.isEmpty) {
        throw Exception("Entity ID not found");
      }

      // 🔥 Call API dynamically
      final response = await _api.get(
        '/About/Get-Entity-By-Id',
        queryParams: {'id': entityId},
      );

      return AboutModel.fromJson(response);

    } catch (e) {
      print("About API Error: $e");
      return null;
    }
  }
} */
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/about_model.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class AboutService {
  final ApiService _api = ApiService();

  static const String cacheKey = "about_cache";

  Future<AboutModel?> fetchAbout() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 🔵 STEP 1: TRY CACHE FIRST
      final cached = prefs.getString(cacheKey);

      if (cached != null) {
        print("✅ Using CACHE (About screen unchanged)");

        return AboutModel.fromJson(jsonDecode(cached));
      }

      // 🔵 STEP 2: IF NO CACHE → CALL API (your original logic)
      final entityId = await AuthService().getEntityId();

      if (entityId == null || entityId.isEmpty) {
        throw Exception("Entity ID not found");
      }

      final response = await _api.get(
        '/About/Get-Entity-By-Id',
        queryParams: {'id': entityId},
      );

      // 🔵 STEP 3: SAVE RESPONSE TO CACHE
      await prefs.setString(cacheKey, jsonEncode(response));

      print("✅ Saved to CACHE (first time only)");

      return AboutModel.fromJson(response);

    } catch (e) {
      print("About API Error: $e");
      return null;
    }
  }

  // Optional: safe reset (does NOT affect UI)
  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(cacheKey);
  }
}