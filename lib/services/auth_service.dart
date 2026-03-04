import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:school_management_system/services/api_service.dart';

/// Manages authentication state: login, register, token storage, user data.
///
/// Security policy:
///   - JWT token → FlutterSecureStorage (encrypted keychain/keystore)
///   - Non-sensitive data (student name, id, login flag) → SharedPreferences
///
/// Login response structure (from API):
/// ```json
/// {
///   "student": {
///     "res": { "token": "...", "expiryTime": 123456789, "userId": 792 },
///     "permission": [],
///     "studentId": 792,
///     "userName": "Royal"
///   }
/// }
/// ```
class AuthService {
  // ─── Storage Keys ─────────────────────────────────────────
  static const String _tokenKey = 'jwt_token';
  static const String _userDataKey = 'user_data';
  static const String _studentIdKey = 'student_id';
  static const String _studentNameKey = 'student_name';
  static const String _isLoggedInKey = 'isLoggedIn';

  // ─── Singleton ────────────────────────────────────────────
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final ApiService _api = ApiService();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  static get to => null;

  // ─── Login ───────────────────────────────────────────────

  /// Authenticate user with the API.
  /// Parses nested response: student.res.token, student.studentId, student.userName
  Future<Map<String, dynamic>> login(String userName, String password) async {
    final response = await _api.post(
      '/Auth/Login',
      body: {'userName': userName, 'password': password},
      requiresAuth: false,
    );

    if (response is Map<String, dynamic>) {
      // Check for error response: {"message": "Invalid Username or Password"}
      if (response.containsKey('message') && !response.containsKey('student')) {
        throw ApiException(response['message'], statusCode: 400);
      }

      // Extract nested data: response → student → res → token
      final student = response['student'] as Map<String, dynamic>?;
      if (student == null) {
        throw ApiException('Invalid login response format', statusCode: 400);
      }

      final res = student['res'] as Map<String, dynamic>?;
      final token = res?['token']?.toString();
      final studentId = student['studentId']?.toString() ?? '';
      final studentName = (student['userName']?.toString() ?? '').trim();

      // Store JWT token in SECURE storage
      if (token != null && token.isNotEmpty) {
        await _secureStorage.write(key: _tokenKey, value: token);
      }

      // Store non-sensitive data in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userDataKey, jsonEncode(student));
      await prefs.setBool(_isLoggedInKey, true);

      if (studentId.isNotEmpty) {
        await prefs.setString(_studentIdKey, studentId);
      }

      if (studentName.isNotEmpty) {
        await prefs.setString(_studentNameKey, studentName);
      }

      return student;
    }

    throw ApiException(response?.toString() ?? 'Login failed', statusCode: 400);
  }

  // ─── Register ────────────────────────────────────────────

  Future<dynamic> register(Map<String, dynamic> registerData) async {
    return await _api.post(
      '/Auth/Register',
      body: registerData,
      requiresAuth: false,
    );
  }

  // ─── Update Password ────────────────────────────────────

  Future<dynamic> updatePassword(String studentId, String newPassword) async {
    return await _api.post(
      '/Auth/Update-Password',
      body: {'studentId': studentId, 'newPassword': newPassword},
    );
  }

  // ─── Token (Secure Storage) ─────────────────────────────

  Future<String?> getToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }

  Future<void> setToken(String token) async {
    await _secureStorage.write(key: _tokenKey, value: token);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, true);
  }

  Future<bool> isTokenExpired() async {
    final token = await getToken();
    if (token == null || token.isEmpty) return true;

    final payload = decodeToken(token);
    if (payload == null || !payload.containsKey('exp')) return false;

    final exp = payload['exp'] as int;
    final expiryDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
    return DateTime.now().isAfter(expiryDate);
  }

  // ─── Session Data (SharedPreferences) ───────────────────

  Future<String?> getStudentId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_studentIdKey);
  }

  Future<void> setStudentId(String studentId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_studentIdKey, studentId);
  }

  Future<String?> getStudentName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_studentNameKey);
  }

  Future<void> setStudentName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_studentNameKey, name);
  }

  Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_userDataKey);
    if (data != null) {
      return jsonDecode(data) as Map<String, dynamic>;
    }
    return null;
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final loggedIn = prefs.getBool(_isLoggedInKey) ?? false;
    if (!loggedIn) return false;

    final token = await _secureStorage.read(key: _tokenKey);
    return token != null && token.isNotEmpty;
  }

  // ─── Logout ─────────────────────────────────────────────

  Future<void> logout() async {
    await _secureStorage.delete(key: _tokenKey);

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userDataKey);
    await prefs.remove(_studentIdKey);
    await prefs.remove(_studentNameKey);
    await prefs.setBool(_isLoggedInKey, false);
  }

  // ─── Helpers ────────────────────────────────────────────

  Map<String, dynamic>? decodeToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      return jsonDecode(decoded) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }
}
