import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/congregation_model.dart';
import '../services/congregation_service.dart';
import '../services/congregation_state.dart';

/**
 * Screen for searching and requesting to join congregations
 */
class CongregationSearchScreen extends StatefulWidget {
  @override
  _CongregationSearchScreenState createState() => _CongregationSearchScreenState();
}

class _CongregationSearchScreenState extends State<CongregationSearchScreen> {
  final CongregationService _congregationService = CongregationService();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  
  List<Congregation> _congregations = [];
  List<Congregation> _allCongregations = [];
  bool _isLoading = false;
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    _loadAllCongregations();
  }

  Future<void> _loadAllCongregations() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final congregations = await _congregationService.getAllCongregations();
      setState(() {
        _allCongregations = congregations ?? [];
        _congregations = _allCongregations;
        _isLoading = false;
        _hasSearched = true;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading congregations: $e')),
      );
    }
  }

  Future<void> _searchCongregations() async {
    if (_searchController.text.trim().isEmpty) {
      setState(() {
        _congregations = _allCongregations;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final results = await _congregationService.searchCongregations(_searchController.text.trim());
      setState(() {
        _congregations = results ?? [];
        _isLoading = false;
        _hasSearched = true;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error searching congregations: $e')),
      );
    }
  }

  void _showJoinDialog(Congregation congregation) {
    _messageController.clear();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Join ${congregation.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Send a join request to this congregation. The congregation head will review your request.',
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _messageController,
              decoration: InputDecoration(
                labelText: 'Message (Optional)',
                hintText: 'Why would you like to join this congregation?',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              maxLength: 500,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _submitJoinRequest(congregation),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B35),
            ),
            child: Text('Send Request'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitJoinRequest(Congregation congregation) async {
    try {
      final joinRequest = await _congregationService.createJoinRequest(
        congregation.id,
        _messageController.text.trim(),
      );

      Navigator.of(context).pop(); // Close dialog

      if (joinRequest != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Join request sent successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Refresh congregation state
        final congregationState = Provider.of<CongregationState>(context, listen: false);
        await congregationState.onCongregationJoined();
        
        // Navigate back to selection screen
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send join request. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      Navigator.of(context).pop(); // Close dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Find Congregation'),
        backgroundColor: const Color(0xFFFF6B35),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFF6B35), Color(0xFFFF8E53)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search by name or location...',
                  prefixIcon: Icon(Icons.search, color: const Color(0xFFFF6B35)),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _congregations = _allCongregations;
                            });
                          },
                          icon: Icon(Icons.clear),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onChanged: (value) {
                  setState(() {});
                  if (value.isEmpty) {
                    setState(() {
                      _congregations = _allCongregations;
                    });
                  }
                },
                onSubmitted: (value) => _searchCongregations(),
              ),
            ),
          ),

          // Search button
          if (_searchController.text.isNotEmpty)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _searchCongregations,
                  icon: Icon(Icons.search),
                  label: Text('Search'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B35),
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),

          // Results
          Expanded(
            child: _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: const Color(0xFFFF6B35)),
            SizedBox(height: 16),
            Text('Searching congregations...'),
          ],
        ),
      );
    }

    if (!_hasSearched) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.temple_hindu,
              size: 64,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              'Search for congregations',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Find your local ISKCON community',
              style: TextStyle(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    if (_congregations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              'No congregations found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Try searching with different keywords',
              style: TextStyle(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _congregations.length,
      itemBuilder: (context, index) {
        final congregation = _congregations[index];
        return _buildCongregationCard(congregation);
      },
    );
  }

  Widget _buildCongregationCard(Congregation congregation) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B35).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.temple_hindu,
                    color: const Color(0xFFFF6B35),
                    size: 32,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        congregation.name,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                          SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              congregation.location,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            if (congregation.description.isNotEmpty) ...[
              SizedBox(height: 16),
              Text(
                congregation.description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
              ),
            ],

            if (congregation.address != null && congregation.address!.isNotEmpty) ...[
              SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.home, size: 16, color: Colors.grey[600]),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      congregation.address!,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
            ],

            SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.person, size: 16, color: Colors.grey[600]),
                SizedBox(width: 4),
                Text(
                  'Head: ${congregation.head?.name ?? 'Not specified'}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
                Spacer(),
                ElevatedButton.icon(
                  onPressed: () => _showJoinDialog(congregation),
                  icon: Icon(Icons.group_add, size: 18),
                  label: Text('Join'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B35),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    textStyle: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _messageController.dispose();
    super.dispose();
  }
} 