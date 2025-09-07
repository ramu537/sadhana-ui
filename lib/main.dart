import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/sadhana_model.dart';
import 'services/auth_service.dart';
import 'services/congregation_state.dart';
import 'services/api_service.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/log_screen.dart';
import 'screens/events_screen.dart';
import 'screens/progress_screen.dart';
import 'screens/profile_screen.dart';
import 'widgets/auth_wrapper.dart';

void main() {
  runApp(SadhanaApp());
}

class SadhanaApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => SadhanaModel()),
        ChangeNotifierProvider(create: (context) => AuthService()),
        ChangeNotifierProvider(create: (context) => CongregationState()),
      ],
      child: MaterialApp(
        title: 'Sadhana Tracker',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFFF6B35),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
        ),
        home: SplashScreen(),
        routes: {
          '/login': (context) => AuthWrapper(),
          '/main': (context) => MainScreen(),
          '/auth': (context) => AuthWrapper(),
        },
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final ApiService _apiService = ApiService();
  
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _checkApiConnection();
    _screens = [
      HomeScreen(onNavigateToTab: (index) {
        setState(() {
          _selectedIndex = index;
        });
      }),
      LogScreen(),
      EventsScreen(),
      ProgressScreen(),
      ProfileScreen(),
    ];
  }

  Future<void> _checkApiConnection() async {
    // Check if API is available and show status
    final isHealthy = await _apiService.isApiHealthy();
    if (!isHealthy) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🔄 Running in offline mode - data will sync when connection is restored'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 5),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Connected to Sadhana API'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFFFF6B35),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit),
            label: 'Log',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Progress',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
