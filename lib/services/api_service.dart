import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/sadhana_model.dart';

class ApiService {
  static const String baseUrl = 'https://sadhana-api.onrender.com/api';
  
  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? _authToken;
  int? _currentUserId;

  // Headers for authenticated requests
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_authToken != null) 'Authorization': 'Bearer $_authToken',
  };

  void setAuthToken(String token, int userId) {
    _authToken = token;
    _currentUserId = userId;
  }

  void clearAuth() {
    _authToken = null;
    _currentUserId = null;
  }

  // User Management APIs
  Future<Map<String, dynamic>?> signInWithGoogle({
    required String googleId,
    required String email,
    required String name,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/google-signin'),
        headers: _headers,
        body: jsonEncode({
          'googleId': googleId,
          'email': email,
          'name': name,
        }),
      );

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        _currentUserId = userData['id'];
        return userData;
      }
      return null;
    } catch (e) {
      print('Error signing in with Google: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getUserProfile(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/$userId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> updateUserProfile({
    required int userId,
    String? name,
    String? location,
    String? temple,
    String? profilePictureBase64,
    int? targetRounds,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (location != null) body['location'] = location;
      if (temple != null) body['temple'] = temple;
      if (profilePictureBase64 != null) body['profilePictureBase64'] = profilePictureBase64;
      if (targetRounds != null) body['targetRounds'] = targetRounds;

      final response = await http.put(
        Uri.parse('$baseUrl/users/$userId/profile'),
        headers: _headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('Error updating user profile: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> toggleAdminStatus(int userId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/users/$userId/admin-toggle'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('Error toggling admin status: $e');
      return null;
    }
  }

  // Sadhana APIs
  Future<Map<String, dynamic>?> createOrUpdateSadhanaEntry({
    required int userId,
    required DateTime date,
    required int japaMalaCount,
    required int readingMinutes,
    required int hearingMinutes,
    required int serviceHours,
    bool morningProgram = false,
    bool eveningProgram = false,
    Map<String, int>? japaByTimeOfDay,
    String notes = '',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/sadhana/users/$userId/entries'),
        headers: _headers,
        body: jsonEncode({
          'entryDate': date.toIso8601String().split('T')[0],
          'japaMalaCount': japaMalaCount,
          'readingMinutes': readingMinutes,
          'hearingMinutes': hearingMinutes,
          'serviceHours': serviceHours,
          'morningProgram': morningProgram,
          'eveningProgram': eveningProgram,
          'morningJapa': japaByTimeOfDay?['morning'] ?? 0,
          'afternoonJapa': japaByTimeOfDay?['afternoon'] ?? 0,
          'eveningJapa': japaByTimeOfDay?['evening'] ?? 0,
          'nightJapa': japaByTimeOfDay?['night'] ?? 0,
          'notes': notes,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('Error creating/updating sadhana entry: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getTodaySadhana(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/sadhana/users/$userId/today'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('Error getting today\'s sadhana: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> getUserSadhanaEntries(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/sadhana/users/$userId/entries'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
      return null;
    } catch (e) {
      print('Error getting user sadhana entries: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getMonthlyAnalytics(int userId, {int? year, int? month}) async {
    try {
      final now = DateTime.now();
      final targetYear = year ?? now.year;
      final targetMonth = month ?? now.month;

      final response = await http.get(
        Uri.parse('$baseUrl/sadhana/users/$userId/analytics/monthly?year=$targetYear&month=$targetMonth'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('Error getting monthly analytics: $e');
      return null;
    }
  }

  Future<int?> getCurrentStreak(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/sadhana/users/$userId/streak'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['currentStreak'];
      }
      return null;
    } catch (e) {
      print('Error getting current streak: $e');
      return null;
    }
  }

  // Event APIs
  Future<List<Map<String, dynamic>>?> getUpcomingEvents() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/events/upcoming'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
      return null;
    } catch (e) {
      print('Error getting upcoming events: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> createEventRsvp({
    required int eventId,
    required int userId,
    required int attendeeCount,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/events/$eventId/rsvp'),
        headers: _headers,
        body: jsonEncode({
          'userId': userId,
          'attendeeCount': attendeeCount,
        }),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('Error creating event RSVP: $e');
      return null;
    }
  }

  Future<bool> cancelEventRsvp(int eventId, int userId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/events/$eventId/rsvp/$userId'),
        headers: _headers,
      );

      return response.statusCode == 204;
    } catch (e) {
      print('Error cancelling event RSVP: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>?> getEventAttendees(int eventId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/events/$eventId/attendees'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
      return null;
    } catch (e) {
      print('Error getting event attendees: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getEventStatistics(int eventId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/events/$eventId/statistics'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('Error getting event statistics: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getUserRsvpForEvent(int eventId, int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/events/$eventId/users/$userId/rsvp'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('Error getting user RSVP for event: $e');
      return null;
    }
  }

  // Quote APIs
  Future<Map<String, dynamic>?> getTodayQuote() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/quotes/today'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('Error getting today\'s quote: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getQuoteByDate(DateTime date) async {
    try {
      final dateStr = date.toIso8601String().split('T')[0];
      final response = await http.get(
        Uri.parse('$baseUrl/quotes/date/$dateStr'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('Error getting quote by date: $e');
      return null;
    }
  }

  // Health check
  Future<bool> isApiHealthy() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/actuator/health'),
        headers: {'Content-Type': 'application/json'},
      );
      return response.statusCode == 200;
    } catch (e) {
      print('API health check failed: $e');
      return false;
    }
  }
} 