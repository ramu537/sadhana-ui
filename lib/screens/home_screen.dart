import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/sadhana_model.dart';
import '../services/auth_service.dart';
import '../services/congregation_state.dart';
import '../services/congregation_service.dart';
import '../models/congregation_model.dart' as congregation_model;
import '../widgets/profile_picture.dart';

class HomeScreen extends StatefulWidget {
  final Function(int)? onNavigateToTab;
  
  const HomeScreen({
    super.key,
    this.onNavigateToTab,
  });

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Consumer<SadhanaModel>(
          builder: (context, model, child) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with greeting and profile
                  _buildHeader(context, model),
                  const SizedBox(height: 20),
                  
                  // Streak display
                  _buildStreakCard(context, model),
                  const SizedBox(height: 20),
                  
                  // Today's Sadhana section
                  _buildTodaySadhanaSection(context, model),
                  const SizedBox(height: 20),
                  
                  // Quick Actions
                  _buildQuickActions(context),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, SadhanaModel model) {
    return Consumer2<AuthService, CongregationState>(
      builder: (context, authService, congregationState, child) {
        final user = authService.currentUser;
        final congregationName = congregationState.congregationDisplayName;
        final userRole = congregationState.currentRoleDisplayName;
        
        return Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFF6B35), Color(0xFFFF8E53)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              Row(
                children: [
                  ProfilePicture(
                    name: user?.name ?? 'Guest',
                    profilePictureBase64: user?.profilePictureBase64,
                    radius: 30,
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getGreetingMessage(),
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          user?.name ?? 'Guest',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.temple_hindu, color: Colors.white70, size: 16),
                            SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                congregationName,
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(width: 8),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                userRole,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Congregation switcher for users with multiple congregations
                  if (congregationState.userCongregations.length > 1)
                    IconButton(
                      onPressed: () => _showCongregationSwitcher(congregationState),
                      icon: Icon(Icons.swap_horiz, color: Colors.white),
                      tooltip: 'Switch Congregation',
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
  
    void _showCongregationSwitcher(CongregationState congregationState) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Switch Congregation',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            ...congregationState.userCongregations.map((userCong) {
              final isSelected = userCong.congregation.id == congregationState.currentCongregation?.id;
              return ListTile(
                leading: Icon(
                  Icons.temple_hindu,
                  color: isSelected ? const Color(0xFFFF6B35) : Colors.grey,
                ),
                title: Text(userCong.congregation.name),
                subtitle: Text('${userCong.congregation.location} • ${userCong.roleInCongregation.displayName}'),
                trailing: isSelected ? Icon(Icons.check, color: const Color(0xFFFF6B35)) : null,
                onTap: isSelected ? null : () async {
                  await congregationState.selectCongregation(userCong);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakCard(BuildContext context, SadhanaModel model) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFFFF6B35), // Orange
            Color(0xFFFF4757), // Red-pink
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B35).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Streak',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${model.currentStreak}',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'days in a row',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodaySadhanaSection(BuildContext context, SadhanaModel model) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Today's Sadhana",
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        // Rounds chanted
        _buildSadhanaCard(
          context,
          icon: Icons.circle_outlined,
          title: 'Rounds Chanted',
          current: model.todaySadhana.japaMalaCount,
          target: model.targetRounds,
          unit: 'of ${model.targetRounds} rounds',
          progress: model.roundsProgress,
          color: Colors.orange,
        ),
        const SizedBox(height: 12),
        
        // Reading
        _buildSadhanaCard(
          context,
          icon: Icons.menu_book,
          title: 'Reading',
          current: model.todaySadhana.readingMinutes,
          target: null,
          unit: 'minutes today',
          progress: null,
          color: Colors.blue,
        ),
        const SizedBox(height: 12),
        
        // Lectures
        _buildSadhanaCard(
          context,
          icon: Icons.headphones,
          title: 'Lectures',
          current: model.todaySadhana.hearingMinutes,
          target: null,
          unit: 'minutes today',
          progress: null,
          color: Colors.green,
        ),
        const SizedBox(height: 12),
        
        // Association
        _buildSadhanaCard(
          context,
          icon: Icons.group,
                      title: 'Service',
            current: model.todaySadhana.serviceHours,
            target: null,
            unit: 'hours served',
          progress: null,
          color: Colors.purple,
        ),
      ],
    );
  }

  Widget _buildSadhanaCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required int current,
    int? target,
    required String unit,
    double? progress,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '$current',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      TextSpan(
                        text: ' $unit',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                if (progress != null) ...[
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: color.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Consumer2<AuthService, CongregationState>(
      builder: (context, authService, congregationState, child) {
        final isSuperAdmin = authService.currentUser?.isSuperAdmin ?? false;
        final isCongregationHead = congregationState.isCongregationHead;
        final canManageMembers = isSuperAdmin || isCongregationHead;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    context,
                    title: 'Log Sadhana',
                    subtitle: 'Record today\'s practice',
                    icon: Icons.edit_note,
                    color: const Color(0xFFFF6B35),
                    onTap: () {
                      widget.onNavigateToTab?.call(1); // Navigate to Log screen (index 1)
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('📝 Opening Sadhana Log...'),
                            duration: Duration(milliseconds: 1500),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    context,
                    title: 'Upcoming Events',
                    subtitle: 'Join community activities',
                    icon: Icons.event,
                    color: Colors.green,
                    onTap: () {
                      widget.onNavigateToTab?.call(2); // Navigate to Events screen (index 2)
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('🎯 Opening Community Events...'),
                            duration: Duration(milliseconds: 1500),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
            if (canManageMembers) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  if (isSuperAdmin)
                    Expanded(
                      child: _buildActionButton(
                        context,
                        title: 'Admin Panel',
                        subtitle: 'Manage join requests',
                        icon: Icons.admin_panel_settings,
                        color: Colors.purple,
                        onTap: () => _showAdminPanel(context),
                      ),
                    ),
                  if (isSuperAdmin && isCongregationHead) const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionButton(
                      context,
                      title: 'Members',
                      subtitle: isCongregationHead 
                          ? 'Manage your congregation'
                          : 'Manage congregation members',
                      icon: Icons.people,
                      color: Colors.orange,
                      onTap: () => _showMemberManagement(context),
                    ),
                  ),
                  if (!isSuperAdmin && isCongregationHead)
                    Expanded(
                      child: _buildActionButton(
                        context,
                        title: 'Join Requests',
                        subtitle: 'Review pending requests',
                        icon: Icons.person_add,
                        color: Colors.indigo,
                        onTap: () => _showCongregationJoinRequests(context),
                      ),
                    ),
                ],
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getGreetingMessage() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  /// Show congregation-specific join requests for congregation heads
  void _showCongregationJoinRequests(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Consumer<CongregationState>(
        builder: (context, congregationState, child) {
          final currentCongregation = congregationState.currentCongregation;
          if (currentCongregation == null) {
            return Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Center(child: Text('No congregation selected')),
            );
          }

          return Container(
            height: MediaQuery.of(context).size.height * 0.8,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.indigo, Colors.indigoAccent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(Icons.person_add, color: Colors.white, size: 28),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '${currentCongregation.name} - Join Requests',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: FutureBuilder<List<congregation_model.JoinRequest>?>(
                    future: CongregationService().getPendingJoinRequests(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator(color: Colors.indigo));
                      }
                      
                      if (snapshot.hasError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error, color: Colors.red, size: 48),
                              SizedBox(height: 16),
                              Text('Error loading join requests'),
                              Text('${snapshot.error}', style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        );
                      }
                      
                      final requests = snapshot.data ?? [];
                      final pendingRequests = requests.where((r) => r.isPending).toList();
                      
                      if (pendingRequests.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle, color: Colors.green, size: 48),
                              SizedBox(height: 16),
                              Text('No pending join requests'),
                              Text('All requests have been processed', style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        );
                      }
                      
                      return ListView.builder(
                        padding: EdgeInsets.all(16),
                        itemCount: pendingRequests.length,
                        itemBuilder: (context, index) {
                          final request = pendingRequests[index];
                          return Card(
                            margin: EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.indigo.withOpacity(0.1),
                                child: Text(
                                  request.user.name[0].toUpperCase(),
                                  style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold),
                                ),
                              ),
                              title: Text(request.user.name),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(request.user.email),
                                  if (request.message?.isNotEmpty ?? false)
                                    Text('Message: ${request.message}', style: TextStyle(fontStyle: FontStyle.italic)),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.check, color: Colors.green),
                                    onPressed: () => _showApprovalDialog(context, request),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.close, color: Colors.red),
                                    onPressed: () => _rejectRequest(context, request),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Show admin panel for managing join requests
  void _showAdminPanel(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple, Colors.purpleAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.admin_panel_settings, color: Colors.white, size: 28),
                      SizedBox(width: 12),
                      Text(
                        'Super Admin Panel',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<List<congregation_model.JoinRequest>?>(
                future: CongregationService().getAllJoinRequests(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator(color: Colors.purple));
                  }
                  
                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error, color: Colors.red, size: 48),
                          SizedBox(height: 16),
                          Text('Error loading join requests'),
                          Text('${snapshot.error}', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    );
                  }
                  
                  final requests = snapshot.data ?? [];
                  final pendingRequests = requests.where((r) => r.isPending).toList();
                  
                  if (pendingRequests.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle, color: Colors.green, size: 48),
                          SizedBox(height: 16),
                          Text('No pending join requests'),
                          Text('All requests have been processed', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    );
                  }
                  
                  return ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: pendingRequests.length,
                    itemBuilder: (context, index) {
                      final request = pendingRequests[index];
                      return Card(
                        margin: EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.purple.withOpacity(0.1),
                            child: Text(
                              request.user.name[0].toUpperCase(),
                              style: TextStyle(color: Colors.purple, fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Text(request.user.name),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Wants to join: ${request.congregation.name}'),
                              if (request.message?.isNotEmpty ?? false)
                                Text('Message: ${request.message}', style: TextStyle(fontStyle: FontStyle.italic)),
                            ],
                          ),
                                                     trailing: Row(
                             mainAxisSize: MainAxisSize.min,
                             children: [
                               IconButton(
                                 icon: Icon(Icons.check, color: Colors.green),
                                 onPressed: () => _showApprovalDialog(context, request),
                               ),
                               IconButton(
                                 icon: Icon(Icons.close, color: Colors.red),
                                 onPressed: () => _rejectRequest(context, request),
                               ),
                             ],
                           ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Show member management for current congregation
  void _showMemberManagement(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Consumer<CongregationState>(
        builder: (context, congregationState, child) {
          final currentCongregation = congregationState.currentCongregation;
          if (currentCongregation == null) {
            return Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Center(child: Text('No congregation selected')),
            );
          }

          return Container(
            height: MediaQuery.of(context).size.height * 0.8,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.orange, Color(0xFFFF6B35)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(Icons.people, color: Colors.white, size: 28),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '${currentCongregation.name} Members',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: FutureBuilder<List<Map<String, dynamic>>?>(
                    future: CongregationService().getCongregationMembersWithRoles(currentCongregation.id),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator(color: Colors.orange));
                      }
                      
                      if (snapshot.hasError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error, color: Colors.red, size: 48),
                              SizedBox(height: 16),
                              Text('Error loading members'),
                              Text('${snapshot.error}', style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        );
                      }
                      
                      final members = snapshot.data ?? [];
                      
                      if (members.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.people_outline, color: Colors.grey, size: 48),
                              SizedBox(height: 16),
                              Text('No members found'),
                            ],
                          ),
                        );
                      }
                      
                      return ListView.builder(
                        padding: EdgeInsets.all(16),
                        itemCount: members.length,
                        itemBuilder: (context, index) {
                          final member = members[index];
                          return Card(
                            margin: EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.orange.withOpacity(0.1),
                                child: Text(
                                  member['userName'][0].toUpperCase(),
                                  style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                                ),
                              ),
                              title: Text(member['userName']),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(member['userEmail']),
                                  Container(
                                    margin: EdgeInsets.only(top: 4),
                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: _getRoleColor(member['role']).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      member['roleDisplayName'],
                                      style: TextStyle(
                                        color: _getRoleColor(member['role']),
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              trailing: congregationState.isSuperAdmin || congregationState.isCongregationHead
                                  ? Consumer<AuthService>(
                                      builder: (context, authService, child) {
                                        final isSuperAdmin = authService.currentUser?.isSuperAdmin ?? false;
                                        
                                        return PopupMenuButton<congregation_model.Role>(
                                          icon: Icon(Icons.more_vert),
                                          onSelected: (role) => _updateMemberRole(
                                            context, member, role, currentCongregation.id),
                                          itemBuilder: (context) => [
                                            PopupMenuItem(
                                              value: congregation_model.Role.guest,
                                              child: Text('Make Guest'),
                                            ),
                                            if (isSuperAdmin)
                                              PopupMenuItem(
                                                value: congregation_model.Role.congregationHead,
                                                child: Text('Make Congregation Head'),
                                              ),
                                          ],
                                        );
                                      },
                                    )
                                  : null,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Get color for role
  Color _getRoleColor(String role) {
    switch (role) {
      case 'CONGREGATION_HEAD':
        return Colors.purple;
      case 'SUPER_ADMIN':
        return Colors.red;
      case 'GUEST':
      default:
        return Colors.blue;
    }
  }

  /// Update member role
  Future<void> _updateMemberRole(BuildContext context, Map<String, dynamic> member, 
      congregation_model.Role newRole, int congregationId) async {
    try {
      final result = await CongregationService().updateUserRole(
        congregationId, 
        member['userId'], 
        newRole
      );
      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Updated ${member['userName']} to ${newRole.displayName}'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // Close the member management panel
        _showMemberManagement(context); // Reopen to show updated list
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Failed to update role'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Show all congregations for super admin
  void _showAllCongregations(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange, Color(0xFFFF6B35)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.temple_hindu, color: Colors.white, size: 28),
                      SizedBox(width: 12),
                      Text(
                        'All Congregations',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Consumer<CongregationState>(
                builder: (context, congregationState, child) {
                  final congregations = congregationState.userCongregations;
                  
                  if (congregations.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.temple_hindu, color: Colors.grey, size: 48),
                          SizedBox(height: 16),
                          Text('No congregations found'),
                        ],
                      ),
                    );
                  }
                  
                  return ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: congregations.length,
                    itemBuilder: (context, index) {
                      final userCong = congregations[index];
                      final cong = userCong.congregation;
                      return Card(
                        margin: EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.orange.withOpacity(0.1),
                            child: Icon(Icons.temple_hindu, color: Colors.orange),
                          ),
                          title: Text(cong.name),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(cong.location),
                              Text('Role: ${userCong.roleInCongregation.displayName}'),
                            ],
                          ),
                          onTap: () {
                            congregationState.selectCongregation(userCong);
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Switched to ${cong.name}')),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Show approval dialog with role selection
  void _showApprovalDialog(BuildContext context, congregation_model.JoinRequest request) {
    congregation_model.Role selectedRole = congregation_model.Role.guest;
    String reviewNotes = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Consumer2<AuthService, CongregationState>(
          builder: (context, authService, congregationState, child) {
            final isSuperAdmin = authService.currentUser?.isSuperAdmin ?? false;
            
            // Available roles based on user permissions
            final availableRoles = <congregation_model.Role>[
              congregation_model.Role.guest,
              if (isSuperAdmin) congregation_model.Role.congregationHead,
            ];

            return StatefulBuilder(
              builder: (context, setState) {
                return AlertDialog(
                  title: Text('Approve Join Request'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('User: ${request.user.name}'),
                      Text('Congregation: ${request.congregation.name}'),
                      SizedBox(height: 16),
                      Text('Assign Role:', style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      DropdownButtonFormField<congregation_model.Role>(
                        value: selectedRole,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: availableRoles.map((role) => DropdownMenuItem(
                          value: role,
                          child: Text(role.displayName),
                        )).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedRole = value!;
                          });
                        },
                      ),
                      if (!isSuperAdmin) ...[
                        SizedBox(height: 8),
                        Text(
                          'Note: Only Super Admins can assign Congregation Head roles',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                      SizedBox(height: 16),
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'Review Notes (Optional)',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                        onChanged: (value) => reviewNotes = value,
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _approveRequest(context, request, selectedRole, reviewNotes);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      child: Text('Approve', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  /// Approve a join request with role
  Future<void> _approveRequest(BuildContext context, congregation_model.JoinRequest request, 
      congregation_model.Role assignedRole, String reviewNotes) async {
    try {
      final result = await CongregationService().approveJoinRequest(
        request.id, 
        reviewNotes: reviewNotes.isNotEmpty ? reviewNotes : null,
        assignedRole: assignedRole,
      );
      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Approved ${request.user.name} as ${assignedRole.displayName}'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // Close the admin panel to refresh
        _showAdminPanel(context); // Reopen to show updated list
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Failed to approve request'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Reject a join request
  Future<void> _rejectRequest(BuildContext context, congregation_model.JoinRequest request) async {
    try {
      final result = await CongregationService().rejectJoinRequest(request.id);
      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Rejected ${request.user.name}\'s request'),
            backgroundColor: Colors.orange,
          ),
        );
        Navigator.pop(context); // Close the admin panel to refresh
        _showAdminPanel(context); // Reopen to show updated list
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Failed to reject request'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
} 