import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../services/api_service.dart';

class SadhanaData {
  final DateTime date;
  final int japaMalaCount;
  final int readingMinutes;
  final int hearingMinutes;
  final int serviceHours;
  final bool morningProgram;
  final bool eveningProgram;
  final Map<String, int> japaByTimeOfDay; // morning, afternoon, evening, night
  final String notes;

  SadhanaData({
    required this.date,
    this.japaMalaCount = 0,
    this.readingMinutes = 0,
    this.hearingMinutes = 0,
    this.serviceHours = 0,
    this.morningProgram = false,
    this.eveningProgram = false,
    this.japaByTimeOfDay = const {'morning': 0, 'afternoon': 0, 'evening': 0, 'night': 0},
    this.notes = '',
  });

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'japaMalaCount': japaMalaCount,
    'readingMinutes': readingMinutes,
    'hearingMinutes': hearingMinutes,
    'serviceHours': serviceHours,
    'morningProgram': morningProgram,
    'eveningProgram': eveningProgram,
    'japaByTimeOfDay': japaByTimeOfDay,
    'notes': notes,
  };

  factory SadhanaData.fromJson(Map<String, dynamic> json) => SadhanaData(
    date: DateTime.parse(json['date']),
    japaMalaCount: json['japaMalaCount'] ?? 0,
    readingMinutes: json['readingMinutes'] ?? 0,
    hearingMinutes: json['hearingMinutes'] ?? 0,
    serviceHours: json['serviceHours'] ?? 0,
    morningProgram: json['morningProgram'] ?? false,
    eveningProgram: json['eveningProgram'] ?? false,
    japaByTimeOfDay: Map<String, int>.from(json['japaByTimeOfDay'] ?? {'morning': 0, 'afternoon': 0, 'evening': 0, 'night': 0}),
    notes: json['notes'] ?? '',
  );
}

class UserProfile {
  final String name;
  final String location;
  final String temple;
  final DateTime joinDate;
  final bool isAdmin;

  UserProfile({
    this.name = 'Devotee',
    this.location = 'Local Temple',
    this.temple = 'ISKCON',
    DateTime? joinDate,
    this.isAdmin = false,
  }) : joinDate = joinDate ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'name': name,
    'location': location,
    'temple': temple,
    'joinDate': joinDate.toIso8601String(),
    'isAdmin': isAdmin,
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    name: json['name'] ?? 'Devotee',
    location: json['location'] ?? 'Local Temple',
    temple: json['temple'] ?? 'ISKCON',
    joinDate: json['joinDate'] != null ? DateTime.parse(json['joinDate']) : DateTime.now(),
    isAdmin: json['isAdmin'] ?? false,
  );

  UserProfile copyWith({
    String? name,
    String? location,
    String? temple,
    DateTime? joinDate,
    bool? isAdmin,
  }) {
    return UserProfile(
      name: name ?? this.name,
      location: location ?? this.location,
      temple: temple ?? this.temple,
      joinDate: joinDate ?? this.joinDate,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }
}

class DailyQuote {
  final String quote;
  final String author;
  final String source;
  final DateTime date;

  DailyQuote({
    required this.quote,
    required this.author,
    required this.source,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
    'quote': quote,
    'author': author,
    'source': source,
    'date': date.toIso8601String(),
  };

  factory DailyQuote.fromJson(Map<String, dynamic> json) => DailyQuote(
    quote: json['quote'],
    author: json['author'],
    source: json['source'],
    date: DateTime.parse(json['date']),
  );
}

class SadhanaModel extends ChangeNotifier {
  UserProfile _userProfile = UserProfile();
  SadhanaData _todaySadhana = SadhanaData(date: DateTime.now());
  List<SadhanaData> _sadhanaHistory = [];
  int _currentStreak = 0;
  int _targetRounds = 16;
  DailyQuote? _todayQuote;
  final ApiService _apiService = ApiService();

  UserProfile get userProfile => _userProfile;
  SadhanaData get todaySadhana => _todaySadhana;
  List<SadhanaData> get sadhanaHistory => _sadhanaHistory;
  int get currentStreak => _currentStreak;
  int get targetRounds => _targetRounds;
  DailyQuote? get todayQuote => _todayQuote;

  // Monthly analytics
  Map<String, dynamic> get monthlyAnalytics {
    final now = DateTime.now();
    final thisMonth = _sadhanaHistory.where((entry) =>
      entry.date.year == now.year && entry.date.month == now.month).toList();

    if (thisMonth.isEmpty) {
      return {
        'totalDays': 0,
        'japaByTime': {'morning': 0, 'afternoon': 0, 'evening': 0, 'night': 0},
        'averageJapa': 0.0,
        'totalReading': 0,
        'totalHearing': 0,
        'consistency': 0.0,
      };
    }

    final japaByTime = {'morning': 0, 'afternoon': 0, 'evening': 0, 'night': 0};
    int totalJapa = 0;
    int totalReading = 0;
    int totalHearing = 0;

    for (final entry in thisMonth) {
      totalJapa += entry.japaMalaCount;
      totalReading += entry.readingMinutes;
      totalHearing += entry.hearingMinutes;
      
      entry.japaByTimeOfDay.forEach((time, count) {
        japaByTime[time] = (japaByTime[time] ?? 0) + count;
      });
    }

    return {
      'totalDays': thisMonth.length,
      'japaByTime': japaByTime,
      'averageJapa': totalJapa / thisMonth.length,
      'totalReading': totalReading,
      'totalHearing': totalHearing,
      'consistency': (thisMonth.length / DateTime.now().day) * 100,
    };
  }

  void updateTodaySadhana(SadhanaData newData) async {
    _todaySadhana = newData;
    
    // Try to update via API first
    try {
      // Get current user ID (you may need to inject this from AuthService)
      final currentUserId = 1; // This should come from the authenticated user
      
      await _apiService.createOrUpdateSadhanaEntry(
        userId: currentUserId,
        date: newData.date,
        japaMalaCount: newData.japaMalaCount,
        readingMinutes: newData.readingMinutes,
        hearingMinutes: newData.hearingMinutes,
        serviceHours: newData.serviceHours,
        morningProgram: newData.morningProgram,
        eveningProgram: newData.eveningProgram,
        japaByTimeOfDay: newData.japaByTimeOfDay,
        notes: newData.notes,
      );
    } catch (apiError) {
      debugPrint('API update sadhana error: $apiError');
    }
    
    // Always update local data as fallback
    addSadhanaEntry(newData);
    notifyListeners();
  }

  void updateUserProfile(UserProfile newProfile) {
    _userProfile = newProfile;
    _saveData();
    notifyListeners();
  }

  void toggleAdminStatus() {
    _userProfile = _userProfile.copyWith(isAdmin: !_userProfile.isAdmin);
    _saveData();
    notifyListeners();
  }

  void addSadhanaEntry(SadhanaData entry) {
    final existingIndex = _sadhanaHistory.indexWhere(
      (e) => e.date.day == entry.date.day && 
             e.date.month == entry.date.month && 
             e.date.year == entry.date.year
    );
    
    if (existingIndex != -1) {
      _sadhanaHistory[existingIndex] = entry;
    } else {
      _sadhanaHistory.add(entry);
    }
    
    _sadhanaHistory.sort((a, b) => b.date.compareTo(a.date));
    _updateStreak();
    _saveData();
    notifyListeners();
  }

  void _updateStreak() {
    if (_sadhanaHistory.isEmpty) {
      _currentStreak = 0;
      return;
    }

    _sadhanaHistory.sort((a, b) => b.date.compareTo(a.date));
    
    int streak = 0;
    DateTime currentDate = DateTime.now();
    
    for (final entry in _sadhanaHistory) {
      final daysDifference = currentDate.difference(entry.date).inDays;
      
      if (daysDifference == streak) {
        if (entry.japaMalaCount > 0) {
          streak++;
          currentDate = entry.date;
        } else {
          break;
        }
      } else if (daysDifference == streak + 1) {
        currentDate = entry.date;
      } else {
        break;
      }
    }
    
    _currentStreak = streak;
  }

  double get roundsProgress {
    if (_targetRounds == 0) return 0.0;
    return (_todaySadhana.japaMalaCount / _targetRounds).clamp(0.0, 1.0);
  }

  String get greetingMessage {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  void _generateTodayQuote() async {
    // Try to get quote from API first
    try {
      final quoteData = await _apiService.getTodayQuote();
      if (quoteData != null) {
        _todayQuote = DailyQuote(
          quote: quoteData['quote'],
          author: quoteData['author'],
          source: quoteData['source'],
          date: DateTime.parse(quoteData['quoteDate'] ?? DateTime.now().toIso8601String()),
        );
        notifyListeners();
        return;
      }
    } catch (apiError) {
      debugPrint('API get quote error: $apiError');
    }
    
    // Fallback to local quotes
    final quotes = [
      DailyQuote(
        quote: "Chanting is the only way to cleanse the heart and achieve love of Godhead.",
        author: "Srila Prabhupada",
        source: "The Science of Self Realization",
        date: DateTime.now(),
      ),
      DailyQuote(
        quote: "The holy name of Krishna is transcendentally blissful. It bestows all spiritual benedictions.",
        author: "Lord Chaitanya",
        source: "Chaitanya Charitamrita",
        date: DateTime.now(),
      ),
      DailyQuote(
        quote: "One should chant the holy name of the Lord in a humble state of mind, thinking oneself lower than the straw in the street.",
        author: "Srila Prabhupada",
        source: "Teachings of Lord Chaitanya",
        date: DateTime.now(),
      ),
      DailyQuote(
        quote: "Krishna consciousness is not an artificial imposition on the mind. This consciousness is the original natural energy of the living entity.",
        author: "Srila Prabhupada",
        source: "Bhagavad Gita As It Is",
        date: DateTime.now(),
      ),
      DailyQuote(
        quote: "The devotee who is always engaged in the service of the Lord is very dear to Krishna.",
        author: "Krishna",
        source: "Bhagavad Gita 12.14",
        date: DateTime.now(),
      ),
    ];

    // Select quote based on day of year for consistency
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year)).inDays;
    _todayQuote = quotes[dayOfYear % quotes.length];
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userProfile', _encodeJson(_userProfile.toJson()));
    await prefs.setString('todaySadhana', _encodeJson(_todaySadhana.toJson()));
    await prefs.setString('sadhanaHistory', _encodeJson(_sadhanaHistory.map((e) => e.toJson()).toList()));
    await prefs.setInt('currentStreak', _currentStreak);
    await prefs.setInt('targetRounds', _targetRounds);
    if (_todayQuote != null) {
      await prefs.setString('todayQuote', _encodeJson(_todayQuote!.toJson()));
    }
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load user profile
    final profileJson = prefs.getString('userProfile');
    if (profileJson != null) {
      _userProfile = UserProfile.fromJson(_decodeJson(profileJson));
    }
    
    // Load today's sadhana
    final todayJson = prefs.getString('todaySadhana');
    if (todayJson != null) {
      final savedData = SadhanaData.fromJson(_decodeJson(todayJson));
      final today = DateTime.now();
      if (savedData.date.day == today.day && 
          savedData.date.month == today.month && 
          savedData.date.year == today.year) {
        _todaySadhana = savedData;
      }
    }
    
    // Load sadhana history
    final historyJson = prefs.getString('sadhanaHistory');
    if (historyJson != null) {
      final List<dynamic> historyList = _decodeJson(historyJson);
      _sadhanaHistory = historyList.map((e) => SadhanaData.fromJson(e)).toList();
    }
    
    // Load other data
    _currentStreak = prefs.getInt('currentStreak') ?? 0;
    _targetRounds = prefs.getInt('targetRounds') ?? 16;
    
    // Load or generate today's quote
    final quoteJson = prefs.getString('todayQuote');
    if (quoteJson != null) {
      final savedQuote = DailyQuote.fromJson(_decodeJson(quoteJson));
      final today = DateTime.now();
      if (savedQuote.date.day == today.day && 
          savedQuote.date.month == today.month && 
          savedQuote.date.year == today.year) {
        _todayQuote = savedQuote;
      } else {
        _generateTodayQuote();
      }
    } else {
      _generateTodayQuote();
    }
    
    _updateStreak();
    notifyListeners();
  }

  String _encodeJson(dynamic data) {
    return jsonEncode(data);
  }

  dynamic _decodeJson(String jsonString) {
    return jsonDecode(jsonString);
  }
} 