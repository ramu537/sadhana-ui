import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/congregation_model.dart';
import '../services/congregation_service.dart';
import '../services/congregation_state.dart';
import '../services/auth_service.dart';
import 'congregation_search_screen.dart';

/**
 * Screen for users to select which congregation to login to
 * or join a congregation if they're not part of any
 */
class CongregationSelectionScreen extends StatefulWidget {
  @override
  _CongregationSelectionScreenState createState() => _CongregationSelectionScreenState();
}

class _CongregationSelectionScreenState extends State<CongregationSelectionScreen> {
  final CongregationService _congregationService = CongregationService();
  List<UserCongregation> _userCongregations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserCongregations();
  }

  Future<void> _loadUserCongregations() async {
    try {
      final congregations = await _congregationService.getUserCongregations();
      setState(() {
        _userCongregations = congregations ?? [];
        _isLoading = false;
      });

      // If user has no congregations, they must join one
      if (_userCongregations.isEmpty) {
        _showMustJoinDialog();
      }
      // If user has exactly one congregation, auto-select it
      else if (_userCongregations.length == 1) {
        _selectCongregation(_userCongregations.first);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading congregations: $e')),
      );
    }
  }

  void _showMustJoinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('🕉️ Join a Congregation'),
        content: Text(
          'Welcome to Sadhana Tracker!\n\n'
          'To start tracking your spiritual practices, you must join a congregation. '
          'This connects you with your local ISKCON community and allows you to '
          'participate in congregation events and activities.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _navigateToSearch();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B35),
            ),
            child: Text('Find Congregation'),
          ),
        ],
      ),
    );
  }

  void _selectCongregation(UserCongregation userCongregation) async {
    // Store selected congregation in state management
    final congregationState = Provider.of<CongregationState>(context, listen: false);
    await congregationState.selectCongregation(userCongregation);
    
    // Navigate to main app
    Navigator.of(context).pushReplacementNamed('/main');
  }

  void _navigateToSearch() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CongregationSearchScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFF6B35), Color(0xFFFF8E53)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Colors.white),
                SizedBox(height: 20),
                Text(
                  'Loading your congregations...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Select Congregation'),
        backgroundColor: const Color(0xFFFF6B35),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _navigateToSearch,
            icon: Icon(Icons.search),
            tooltip: 'Find More Congregations',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFF6B35), Color(0xFFFF8E53)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back! 🙏',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Select a congregation to continue your sadhana journey',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                SizedBox(height: 24),
                
                if (_userCongregations.isEmpty)
                  _buildEmptyState()
                else
                  _buildCongregationList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.temple_hindu,
              size: 80,
              color: Colors.white70,
            ),
            SizedBox(height: 24),
            Text(
              'No Congregations Yet',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Join a congregation to start your spiritual journey with the community',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _navigateToSearch,
              icon: Icon(Icons.search),
              label: Text('Find Congregation'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFFFF6B35),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCongregationList() {
    return Expanded(
      child: ListView.builder(
        itemCount: _userCongregations.length,
        itemBuilder: (context, index) {
          final userCongregation = _userCongregations[index];
          final congregation = userCongregation.congregation;
          
          return Card(
            margin: EdgeInsets.only(bottom: 12),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              onTap: () => _selectCongregation(userCongregation),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF6B35).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.temple_hindu,
                            color: const Color(0xFFFF6B35),
                            size: 24,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                congregation.name,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                congregation.location,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: userCongregation.roleInCongregation == Role.congregationHead
                                ? Colors.orange[100]
                                : Colors.blue[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            userCongregation.roleInCongregation.displayName,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: userCongregation.roleInCongregation == Role.congregationHead
                                  ? Colors.orange[800]
                                  : Colors.blue[800],
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (congregation.description.isNotEmpty) ...[
                      SizedBox(height: 12),
                      Text(
                        congregation.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.person, size: 16, color: Colors.grey[600]),
                        SizedBox(width: 4),
                        Text(
                          'Head: ${congregation.head?.name ?? 'Not specified'}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        Spacer(),
                        Text(
                          'Joined ${_formatDate(userCongregation.joinedAt)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays < 30) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years year${years > 1 ? 's' : ''} ago';
    }
  }
} 