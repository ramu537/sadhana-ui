import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFF6B35), // Orange
              Color(0xFFFF4757), // Red-pink
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(),
                
                // App Logo/Icon
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(60),
                  ),
                  child: const Icon(
                    Icons.self_improvement,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // App Title
                const Text(
                  'Sadhana',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Subtitle
                Text(
                  'Track Your Spiritual Journey',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w300,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Sanskrit greeting
                Text(
                  'हरे कृष्ण हरे कृष्ण',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white.withOpacity(0.8),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                
                const Spacer(),
                
                // Login Section
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Welcome to the Community',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                                             Text(
                         'Join fellow devotees in tracking your daily sadhana practice',
                         textAlign: TextAlign.center,
                         style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                           color: Colors.grey[600],
                         ),
                       ),
                       
                       const SizedBox(height: 8),
                       
                       Container(
                         padding: const EdgeInsets.all(8),
                         decoration: BoxDecoration(
                           color: Colors.blue.withOpacity(0.1),
                           borderRadius: BorderRadius.circular(8),
                         ),
                         child: Text(
                           '💡 Demo mode available if Google OAuth not configured',
                           textAlign: TextAlign.center,
                           style: Theme.of(context).textTheme.bodySmall?.copyWith(
                             color: Colors.blue[700],
                             fontWeight: FontWeight.w500,
                           ),
                         ),
                       ),
                      
                      const SizedBox(height: 32),
                      
                      Consumer<AuthService>(
                        builder: (context, authService, child) {
                          if (authService.isLoading) {
                            return const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6B35)),
                            );
                          }
                          
                          return SizedBox(
                            width: double.infinity,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    Color(0xFFFF6B35), // Orange
                                    Color(0xFFFF4757), // Red-pink
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ElevatedButton.icon(
                                onPressed: () => _handleGoogleSignIn(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.account_circle,
                                  color: Colors.white,
                                  size: 24,
                                ),
                                label: const Text(
                                  'Continue with Google (Demo Mode)',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Demo mode direct button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _activateDemoMode(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFFF6B35),
                      side: const BorderSide(color: Color(0xFFFF6B35)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.science, size: 20),
                    label: const Text(
                      'Try Demo Mode',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Terms and Privacy
                Text(
                  'By continuing, you agree to our community guidelines\nand spiritual practice tracking',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
                
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleGoogleSignIn(BuildContext context) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    
    final success = await authService.signInWithGoogle();
    
    if (success) {
      if (context.mounted) {
        // Show demo mode confirmation
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              authService.currentUser?.email == 'demo@sadhana.app' 
                ? '🎯 Demo Mode Activated! Welcome ${authService.currentUser?.name}'
                : '✅ Signed in successfully!'
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
        
        // Navigate to main app
        Navigator.of(context).pushReplacementNamed('/main');
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Sign in failed. Trying demo mode...'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }

  Future<void> _activateDemoMode(BuildContext context) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    
    // Force demo mode activation
    final success = await authService.signInDemo();
    
    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎯 Demo Mode Activated! Welcome Demo Devotee'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      
      Navigator.of(context).pushReplacementNamed('/main');
    }
  }
} 