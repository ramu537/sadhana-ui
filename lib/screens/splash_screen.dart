import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../services/auth_service.dart';
import '../models/sadhana_model.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _rotationController;
  
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  
  String _loadingText = 'Preparing your spiritual dashboard...';

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controllers
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Initialize animations
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.easeInOut,
    ));

    // Start animations
    _startAnimations();
    
    // Navigate after delay
    _navigateToMain();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _scaleController.forward();
    
    await Future.delayed(const Duration(milliseconds: 500));
    _fadeController.forward();
    
    await Future.delayed(const Duration(milliseconds: 800));
    _rotationController.forward();
  }

  void _navigateToMain() {
    Timer(const Duration(milliseconds: 3500), () async {
      if (mounted) {
        // Initialize services
        await _initializeApp();
        
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/auth');
        }
      }
    });
  }

  Future<void> _initializeApp() async {
    try {
      // Update loading text
      if (mounted) {
        setState(() {
          _loadingText = 'Connecting to spiritual community...';
        });
      }
      await Future.delayed(const Duration(milliseconds: 800));
      
      // Initialize auth service
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.initialize();
      
      if (mounted) {
        setState(() {
          _loadingText = 'Loading your sadhana data...';
        });
      }
      await Future.delayed(const Duration(milliseconds: 600));
      
      // Initialize sadhana model
      final sadhanaModel = Provider.of<SadhanaModel>(context, listen: false);
      await sadhanaModel.loadData();
      
      if (mounted) {
        setState(() {
          _loadingText = 'Ready for your spiritual journey!';
        });
      }
      
      // Add a small delay to ensure smooth transition
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      // Handle initialization errors gracefully
      debugPrint('Initialization error: $e');
      if (mounted) {
        setState(() {
          _loadingText = 'Almost ready...';
        });
      }
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFF6B35), // Orange
              Color(0xFFFF4757), // Red-pink
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 2),
              
              // App Icon and Title
              AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: AnimatedBuilder(
                      animation: _rotationAnimation,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _rotationAnimation.value * 0.1,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(60),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.self_improvement,
                              size: 60,
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 30),
              
              // App Title
              FadeTransition(
                opacity: _fadeAnimation,
                child: const Column(
                  children: [
                    Text(
                      'Sadhana',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 3,
                        shadows: [
                          Shadow(
                            offset: Offset(0, 2),
                            blurRadius: 4,
                            color: Colors.black26,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Track Your Spiritual Journey',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Sanskrit Greeting
              FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: const Text(
                    'हरे कृष्ण हरे कृष्ण\nकृष्ण कृष्ण हरे हरे',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                      height: 1.3,
                    ),
                  ),
                ),
              ),
              
              const Spacer(flex: 2),
              
              // Loading Indicator
              FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _loadingText,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 50),
              
              // ISKCON Attribution
              FadeTransition(
                opacity: _fadeAnimation,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Text(
                        '🕉️ For the ISKCON Community',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
} 