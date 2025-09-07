import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/congregation_state.dart';
import '../screens/login_screen.dart';
import '../screens/congregation_selection_screen.dart';
import '../main.dart';

class AuthWrapper extends StatefulWidget {
  @override
  _AuthWrapperState createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _congregationStateInitialized = false;

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthService, CongregationState>(
      builder: (context, authService, congregationState, child) {
        // Show loading while checking authentication status
        if (authService.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: Color(0xFFFF6B35),
              ),
            ),
          );
        }
        
        // If user is not authenticated, show login screen
        if (!authService.isLoggedIn) {
          return LoginScreen();
        }

        // Initialize congregation state after login
        if (!_congregationStateInitialized && authService.isLoggedIn) {
          _initializeCongregationState(authService, congregationState);
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: Color(0xFFFF6B35),
              ),
            ),
          );
        }

        // Show loading while congregation state is loading
        if (congregationState.isLoading) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Color(0xFFFF6B35),
                  ),
                  SizedBox(height: 16),
                  Text('Loading your congregations...'),
                ],
              ),
            ),
          );
        }

        // If user needs to join a congregation, show congregation selection
        if (congregationState.needsToJoinCongregation()) {
          return CongregationSelectionScreen();
        }

        // If user has multiple congregations but none selected, show selection
        if (!congregationState.hasValidCongregation && congregationState.hasCongregations) {
          return CongregationSelectionScreen();
        }
        
        // User is authenticated and has a valid congregation, show main app
        return MainScreen();
      },
    );
  }

  Future<void> _initializeCongregationState(AuthService authService, CongregationState congregationState) async {
    // Get auth token and user ID from auth service
    final user = authService.currentUser;
    if (user != null && authService.authToken != null) {
      await congregationState.initialize(authService.authToken!, int.parse(user.id), user.globalRole);
      setState(() {
        _congregationStateInitialized = true;
      });
    }
  }
} 