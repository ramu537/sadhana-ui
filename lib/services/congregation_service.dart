import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/congregation_model.dart';

/**
 * Service for managing congregation-related API calls
 */
class CongregationService {
  static const String baseUrl = 'https://sadhana-api.onrender.com/api';

  // Singleton pattern
  static final CongregationService _instance = CongregationService._internal();
  factory CongregationService() => _instance;
  CongregationService._internal();

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

  // Congregation Management APIs
  
  /**
   * Get all active congregations (for search)
   */
  Future<List<Congregation>?> getAllCongregations() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/congregations'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Congregation.fromJson(json)).toList();
      }
      return null;
    } catch (e) {
      print('Error getting congregations: $e');
      return null;
    }
  }

  /**
   * Search congregations by name or location
   */
  Future<List<Congregation>?> searchCongregations(String searchTerm, {int page = 0, int size = 20}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/congregations/search?searchTerm=$searchTerm&page=$page&size=$size'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> content = data['content'];
        return content.map((json) => Congregation.fromJson(json)).toList();
      }
      return null;
    } catch (e) {
      print('Error searching congregations: $e');
      return null;
    }
  }

  /**
   * Get congregation by ID
   */
  Future<Congregation?> getCongregationById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/congregations/$id'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return Congregation.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      print('Error getting congregation: $e');
      return null;
    }
  }

  /**
   * Create a join request to a congregation
   */
  Future<JoinRequest?> createJoinRequest(int congregationId, String message) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/congregations/$congregationId/join-request'),
        headers: _headers,
        body: jsonEncode({
          'message': message,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return JoinRequest.fromJson(data['joinRequest']);
      }
      return null;
    } catch (e) {
      print('Error creating join request: $e');
      return null;
    }
  }

  /**
   * Get user's congregations
   */
  Future<List<UserCongregation>?> getUserCongregations() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/congregations/my-congregations'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => UserCongregation.fromJson(json)).toList();
      }
      return null;
    } catch (e) {
      print('Error getting user congregations: $e');
      return null;
    }
  }

  /**
   * Get pending join requests for managed congregations (for congregation heads)
   */
  Future<List<JoinRequest>?> getPendingJoinRequests() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/congregations/join-requests/pending'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => JoinRequest.fromJson(json)).toList();
      }
      return null;
    } catch (e) {
      print('Error getting pending requests: $e');
      return null;
    }
  }

  /**
   * Get all join requests (for super admin)
   */
  Future<List<JoinRequest>?> getAllJoinRequests() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/congregations/join-requests'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => JoinRequest.fromJson(json)).toList();
      }
      return null;
    } catch (e) {
      print('Error getting all join requests: $e');
      return null;
    }
  }

  /**
   * Approve a join request
   */
  Future<UserCongregation?> approveJoinRequest(int requestId, {String? reviewNotes, Role? assignedRole}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/congregations/join-requests/$requestId/approve'),
        headers: _headers,
        body: jsonEncode({
          'reviewNotes': reviewNotes ?? '',
          'assignedRole': assignedRole?.value ?? Role.guest.value,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return UserCongregation.fromJson(data['membership']);
      }
      return null;
    } catch (e) {
      print('Error approving join request: $e');
      return null;
    }
  }

  /**
   * Reject a join request
   */
  Future<JoinRequest?> rejectJoinRequest(int requestId, {String? reviewNotes}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/congregations/join-requests/$requestId/reject'),
        headers: _headers,
        body: jsonEncode({
          'reviewNotes': reviewNotes ?? '',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return JoinRequest.fromJson(data['joinRequest']);
      }
      return null;
    } catch (e) {
      print('Error rejecting join request: $e');
      return null;
    }
  }

  /**
   * Create a new congregation (Super Admin only)
   */
  Future<Congregation?> createCongregation({
    required String name,
    required String description,
    required String location,
    String? address,
    String? contactNumber,
    String? contactEmail,
    required int headUserId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/congregations'),
        headers: _headers,
        body: jsonEncode({
          'name': name,
          'description': description,
          'location': location,
          'address': address,
          'contactNumber': contactNumber,
          'contactEmail': contactEmail,
          'headUserId': headUserId,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return Congregation.fromJson(data['congregation']);
      }
      return null;
    } catch (e) {
      print('Error creating congregation: $e');
      return null;
    }
  }

  /**
   * Update user role in congregation
   */
  Future<UserCongregation?> updateUserRole(int congregationId, int userId, Role newRole) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/congregations/$congregationId/members/$userId/role'),
        headers: _headers,
        body: jsonEncode({
          'role': newRole.value,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return UserCongregation.fromJson(data['membership']);
      }
      return null;
    } catch (e) {
      print('Error updating user role: $e');
      return null;
    }
  }

  /**
   * Get congregation members with their roles
   */
  Future<List<Map<String, dynamic>>?> getCongregationMembersWithRoles(int congregationId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/congregations/$congregationId/members/with-roles'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
      return null;
    } catch (e) {
      print('Error getting congregation members with roles: $e');
      return null;
    }
  }

  /**
   * Get congregations managed by current user
   */
  Future<List<Congregation>?> getManagedCongregations() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/congregations/managed'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Congregation.fromJson(json)).toList();
      }
      return null;
    } catch (e) {
      print('Error getting managed congregations: $e');
      return null;
    }
  }

  /**
   * Get congregation members
   */
  Future<List<UserCongregation>?> getCongregationMembers(int congregationId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/congregations/$congregationId/members'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => UserCongregation.fromJson(json)).toList();
      }
      return null;
    } catch (e) {
      print('Error getting congregation members: $e');
      return null;
    }
  }
} 