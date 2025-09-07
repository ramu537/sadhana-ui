import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'api_service.dart';
import 'congregation_state.dart';
import '../models/congregation_model.dart';

class User {
  final String id;
  final String name;
  final String email;
  final String photoUrl;
  final String? profilePictureBase64;
  final Role globalRole;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.photoUrl,
    this.profilePictureBase64,
    this.globalRole = Role.guest,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'profilePictureBase64': profilePictureBase64,
      'globalRole': globalRole.value,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      photoUrl: json['photoUrl'],
      profilePictureBase64: json['profilePictureBase64'],
      globalRole: Role.fromString(json['globalRole'] ?? 'GUEST'),
    );
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? photoUrl,
    String? profilePictureBase64,
    Role? globalRole,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      profilePictureBase64: profilePictureBase64 ?? this.profilePictureBase64,
      globalRole: globalRole ?? this.globalRole,
    );
  }

  // Helper methods for role checking
  bool get isSuperAdmin => globalRole == Role.superAdmin;
  bool get isCongregationHead => globalRole == Role.congregationHead;
  bool get isGuest => globalRole == Role.guest;
}

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
    ],
    // Updated client ID for production deployment on Vercel
    clientId: '165916648872-o1ocb648u4lguef15nq2u9qj5t03j8ov.apps.googleusercontent.com',
  );

  User? _currentUser;
  bool _isLoading = false;
  String? _authToken;
  int? _currentUserId;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;
  String? get authToken => _authToken;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Check if user was previously signed in
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('current_user');
      final authToken = prefs.getString('auth_token');
      final userId = prefs.getInt('user_id');
      
      if (userJson != null) {
        try {
          // Load saved user data
          final userData = _decodeJson(userJson);
          _currentUser = User.fromJson(userData);
          
          // Restore API authentication if token exists
          if (authToken != null && userId != null) {
            final apiService = ApiService();
            apiService.setAuthToken(authToken, userId);
            _authToken = authToken;
            _currentUserId = userId;
          }
        } catch (e) {
          // If decoding fails, try to silently sign in with Google
          final account = await _googleSignIn.signInSilently();
          if (account != null) {
            // Try to authenticate with backend API
            final apiService = ApiService();
            final apiResponse = await apiService.signInWithGoogle(
              googleId: account.id,
              email: account.email,
              name: account.displayName ?? '',
            );
            
            if (apiResponse != null && apiResponse['token'] != null) {
              final userData = apiResponse['user'];
              final token = apiResponse['token'];
              
                        _currentUser = User(
            id: userData['id'].toString(),
            name: userData['name'] ?? '',
            email: userData['email'] ?? '',
            photoUrl: account.photoUrl ?? '',
            globalRole: Role.fromString(userData['globalRole'] ?? 'GUEST'),
          );
              
              apiService.setAuthToken(token, userData['id']);
              
              // Save updated data
              await prefs.setString('current_user', _encodeJson(_currentUser!.toJson()));
              await prefs.setString('auth_token', token);
              await prefs.setInt('user_id', userData['id']);
            }
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing auth: $e');
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    notifyListeners();

    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      
      if (account != null) {
        // Try to authenticate with backend API
        final apiService = ApiService();
        final apiResponse = await apiService.signInWithGoogle(
          googleId: account.id,
          email: account.email,
          name: account.displayName ?? '',
        );
        
        if (apiResponse != null && apiResponse['token'] != null) {
          // Extract user data and token from API response
          final userData = apiResponse['user'];
          final token = apiResponse['token'];
          
                        _currentUser = User(
                id: userData['id'].toString(),
                name: userData['name'] ?? '',
                email: userData['email'] ?? '',
                photoUrl: account.photoUrl ?? '',
                globalRole: Role.fromString(userData['globalRole'] ?? 'GUEST'),
              );

                        // Set the auth token in API service
              apiService.setAuthToken(token, userData['id']);
              
              // Store token locally
              _authToken = token;
              _currentUserId = userData['id'];

              // Save user data and token locally
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('current_user', _encodeJson(_currentUser!.toJson()));
              await prefs.setString('auth_token', token);
              await prefs.setInt('user_id', userData['id']);

          _isLoading = false;
          notifyListeners();
          return true;
        } else {
          // API authentication failed, fall back to demo mode
          return await signInDemo();
        }
      }
    } catch (error) {
      if (kDebugMode) {
        print('Google Sign-In Error: $error');
      }
      
      // If Google Sign-In fails (missing client ID, popup closed, etc.), offer demo mode
      if (error.toString().contains('ClientID not set') || 
          error.toString().contains('appClientId != null') ||
          error.toString().contains('popup_closed') ||
          error.toString().contains('popup_blocked_by_browser')) {
        return await signInDemo();
      }
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // Demo sign-in for testing without Google OAuth setup
  Future<bool> signInDemo() async {
    try {
      // Try to authenticate with backend API using demo credentials
      final apiService = ApiService();
      final apiResponse = await apiService.signInWithGoogle(
        googleId: 'demo_user_123',
        email: 'demo@sadhana.app',
        name: 'Demo Devotee',
      );
      
      if (apiResponse != null && apiResponse['token'] != null) {
        // Extract user data and token from API response
        final userData = apiResponse['user'];
        final token = apiResponse['token'];
        
        _currentUser = User(
          id: userData['id'].toString(),
          name: userData['name'] ?? 'Demo Devotee',
          email: userData['email'] ?? 'demo@sadhana.app',
          photoUrl: '',
          globalRole: Role.fromString(userData['globalRole'] ?? 'GUEST'),
        );

                      // Set the auth token in API service
              apiService.setAuthToken(token, userData['id']);
              
              // Store token locally
              _authToken = token;
              _currentUserId = userData['id'];

              // Save demo user data and token locally
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('current_user', _encodeJson(_currentUser!.toJson()));
              await prefs.setString('auth_token', token);
              await prefs.setInt('user_id', userData['id']);
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        // Fallback to local demo mode if API is not available
        _currentUser = User(
          id: 'demo_user_123',
          name: 'Demo Devotee',
          email: 'demo@sadhana.app',
          photoUrl: '',
          globalRole: Role.guest,
        );

        // Save demo user data locally
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('current_user', _encodeJson(_currentUser!.toJson()));

        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Demo sign-in error: $e');
      }
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _googleSignIn.signOut();
      _currentUser = null;
      _authToken = null;
      _currentUserId = null;

      // Clear API authentication
      final apiService = ApiService();
      apiService.clearAuth();
      
      // Clear congregation state
      final congregationState = CongregationState();
      await congregationState.clear();

      // Clear all local storage including JWT token
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('current_user');
      await prefs.remove('auth_token');
      await prefs.remove('user_id');
    } catch (e) {
      if (kDebugMode) {
        print('Error signing out: $e');
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  String _encodeJson(Map<String, dynamic> json) {
    return jsonEncode(json);
  }

  Map<String, dynamic> _decodeJson(String jsonString) {
    return jsonDecode(jsonString);
  }

  Future<bool> updateUserProfilePicture(String base64Image) async {
    if (_currentUser == null) return false;

    try {
      _currentUser = _currentUser!.copyWith(profilePictureBase64: base64Image);
      
      // Save updated user data
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('current_user', _encodeJson(_currentUser!.toJson()));
      
      notifyListeners();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error updating profile picture: $e');
      }
      return false;
    }
  }

  Future<bool> updateUserProfile(String name, String email) async {
    if (_currentUser == null) return false;

    try {
      _currentUser = _currentUser!.copyWith(name: name, email: email);
      
      // Save updated user data
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('current_user', _encodeJson(_currentUser!.toJson()));
      
      notifyListeners();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error updating user profile: $e');
      }
      return false;
    }
  }
} 