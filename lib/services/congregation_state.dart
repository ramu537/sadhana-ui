import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/congregation_model.dart' as congregation_model;
import 'congregation_service.dart';

/**
 * State management for current congregation context
 */
class CongregationState extends ChangeNotifier {
  static final CongregationState _instance = CongregationState._internal();
  factory CongregationState() => _instance;
  CongregationState._internal();

  final CongregationService _congregationService = CongregationService();

  // Current state
  congregation_model.Congregation? _currentCongregation;
  congregation_model.UserCongregation? _currentUserCongregation;
  List<congregation_model.UserCongregation> _userCongregations = [];
  bool _isLoading = false;
  String? _authToken;
  int? _currentUserId;
  congregation_model.Role? _userGlobalRole;

  // Getters
  congregation_model.Congregation? get currentCongregation => _currentCongregation;
  congregation_model.UserCongregation? get currentUserCongregation => _currentUserCongregation;
  List<congregation_model.UserCongregation> get userCongregations => _userCongregations;
  bool get isLoading => _isLoading;
  bool get hasValidCongregation => _currentCongregation != null;
  bool get hasCongregations => _userCongregations.isNotEmpty;
  
  // Role in current congregation
  congregation_model.Role? get currentRole => _currentUserCongregation?.roleInCongregation;
  String get currentRoleDisplayName => currentRole?.displayName ?? 'Guest';
  bool get isCongregationHead => currentRole == congregation_model.Role.congregationHead;
  bool get isSuperAdmin => currentRole == congregation_model.Role.superAdmin;
  
  // Congregation display info
  String get congregationDisplayName => _currentCongregation?.name ?? 'Local Temple ISKCON';
  String get congregationLocation => _currentCongregation?.location ?? 'ISKCON';

  /**
   * Initialize congregation state with auth token
   */
  Future<void> initialize(String authToken, int userId, [congregation_model.Role? userGlobalRole]) async {
    _authToken = authToken;
    _currentUserId = userId;
    _userGlobalRole = userGlobalRole;
    _congregationService.setAuthToken(authToken, userId);
    
    await _loadSavedCongregation();
    await loadUserCongregations();
  }

  /**
   * Load user's congregations from API
   */
  Future<void> loadUserCongregations() async {
    if (_authToken == null) return;
    
    _setLoading(true);
    try {
      List<congregation_model.UserCongregation> congregations;
      
      if (_userGlobalRole == congregation_model.Role.superAdmin) {
        // Super admin can access all congregations
        congregations = await _loadAllCongregationsForSuperAdmin();
      } else {
        // Regular users get their assigned congregations
        congregations = await _congregationService.getUserCongregations() ?? [];
      }
      
      _userCongregations = congregations;
      
      // If no current congregation is set, but user has congregations, set the first one
      if (_currentCongregation == null && _userCongregations.isNotEmpty) {
        await selectCongregation(_userCongregations.first);
      }
      
      notifyListeners();
    } catch (e) {
      print('Error loading user congregations: $e');
    } finally {
      _setLoading(false);
    }
  }

  /**
   * Load all congregations for super admin with super admin role
   */
  Future<List<congregation_model.UserCongregation>> _loadAllCongregationsForSuperAdmin() async {
    try {
      final allCongregations = await _congregationService.getAllCongregations();
      if (allCongregations == null) return [];
      
      // Create UserCongregation objects for super admin with SUPER_ADMIN role
      return allCongregations.map((congregation) => congregation_model.UserCongregation(
        id: 0, // Temporary ID for super admin access
        user: congregation_model.User(
          id: _currentUserId.toString(),
          name: 'Super Admin',
          email: '',
          globalRole: congregation_model.Role.superAdmin,
        ),
        congregation: congregation,
        roleInCongregation: congregation_model.Role.superAdmin,
        joinedAt: DateTime.now(),
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      )).toList();
    } catch (e) {
      print('Error loading all congregations for super admin: $e');
      return [];
    }
  }

  /**
   * Select a congregation as current
   */
  Future<void> selectCongregation(congregation_model.UserCongregation userCongregation) async {
    _currentCongregation = userCongregation.congregation;
    _currentUserCongregation = userCongregation;
    
    await _saveCongregationSelection();
    notifyListeners();
  }

  /**
   * Check if user needs to join a congregation
   */
  bool needsToJoinCongregation() {
    // Super admin doesn't need to join congregations
    if (_userGlobalRole == congregation_model.Role.superAdmin) {
      return false;
    }
    return _userCongregations.isEmpty;
  }

  /**
   * Get user's role in a specific congregation
   */
  congregation_model.Role? getRoleInCongregation(int congregationId) {
    final userCong = _userCongregations.firstWhere(
      (uc) => uc.congregation.id == congregationId,
      orElse: () => _userCongregations.first,
    );
    return userCong.roleInCongregation;
  }

  /**
   * Refresh congregation data
   */
  Future<void> refresh() async {
    await loadUserCongregations();
  }

  /**
   * Clear congregation state on logout
   */
  Future<void> clear() async {
    _currentCongregation = null;
    _currentUserCongregation = null;
    _userCongregations = [];
    _authToken = null;
    _currentUserId = null;
    _userGlobalRole = null;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('selected_congregation');
    await prefs.remove('selected_user_congregation');
    
    _congregationService.clearAuth();
    notifyListeners();
  }

  /**
   * Save congregation selection to local storage
   */
  Future<void> _saveCongregationSelection() async {
    if (_currentCongregation == null || _currentUserCongregation == null) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selected_congregation', jsonEncode(_currentCongregation!.toJson()));
      await prefs.setString('selected_user_congregation', jsonEncode(_currentUserCongregation!.toJson()));
    } catch (e) {
      print('Error saving congregation selection: $e');
    }
  }

  /**
   * Load saved congregation selection
   */
  Future<void> _loadSavedCongregation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final congregationJson = prefs.getString('selected_congregation');
      final userCongregationJson = prefs.getString('selected_user_congregation');
      
      if (congregationJson != null && userCongregationJson != null) {
        _currentCongregation = congregation_model.Congregation.fromJson(jsonDecode(congregationJson));
        _currentUserCongregation = congregation_model.UserCongregation.fromJson(jsonDecode(userCongregationJson));
        notifyListeners();
      }
    } catch (e) {
      print('Error loading saved congregation: $e');
    }
  }

  /**
   * Set loading state
   */
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /**
   * Update congregation list after joining a new one
   */
  Future<void> onCongregationJoined() async {
    await loadUserCongregations();
  }

  /**
   * Switch to different congregation
   */
  Future<void> switchCongregation(int congregationId) async {
    final userCong = _userCongregations.firstWhere(
      (uc) => uc.congregation.id == congregationId,
      orElse: () => _userCongregations.first,
    );
    
    if (userCong != _userCongregations.first) {
      await selectCongregation(userCong);
    }
  }
} 