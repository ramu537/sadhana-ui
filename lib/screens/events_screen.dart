import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../models/sadhana_model.dart';

class Event {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String location;
  final String imageUrl;
  final Map<String, int> rsvpUsers; // userId -> attendee count
  final int maxCapacity;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.location,
    required this.imageUrl,
    this.rsvpUsers = const {},
    this.maxCapacity = 100,
  });

  Event copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? date,
    String? location,
    String? imageUrl,
    Map<String, int>? rsvpUsers,
    int? maxCapacity,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      location: location ?? this.location,
      imageUrl: imageUrl ?? this.imageUrl,
      rsvpUsers: rsvpUsers ?? this.rsvpUsers,
      maxCapacity: maxCapacity ?? this.maxCapacity,
    );
  }

  int get totalAttendees => rsvpUsers.values.fold(0, (sum, count) => sum + count);
  int get confirmedFamilies => rsvpUsers.length;
}

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  List<Event> _events = [
    Event(
      id: '1',
      title: 'Sunday Feast',
      description: 'Join us for kirtan, discourse, and delicious prasadam',
      date: DateTime.now().add(const Duration(days: 2)),
      location: 'Main Temple Hall',
      imageUrl: '',
      rsvpUsers: {'user1': 2, 'user2': 4, 'user3': 1},
      maxCapacity: 200,
    ),
    Event(
      id: '2',
      title: 'Bhagavad Gita Study Circle',
      description: 'Weekly study and discussion of the Bhagavad Gita',
      date: DateTime.now().add(const Duration(days: 5)),
      location: 'Library',
      imageUrl: '',
      rsvpUsers: {'user1': 1, 'user4': 2},
      maxCapacity: 30,
    ),
    Event(
      id: '3',
      title: 'Janmashtami Celebration',
      description: 'Grand celebration of Lord Krishna\'s appearance day',
      date: DateTime.now().add(const Duration(days: 15)),
      location: 'Temple Grounds',
      imageUrl: '',
      rsvpUsers: {'user2': 3, 'user3': 2, 'user5': 6},
      maxCapacity: 500,
    ),
  ];

  void _toggleRSVP(Event event, String userId, int attendeeCount) {
    setState(() {
      final index = _events.indexWhere((e) => e.id == event.id);
      if (index != -1) {
        final currentRsvp = Map<String, int>.from(_events[index].rsvpUsers);
        
        if (currentRsvp.containsKey(userId)) {
          // Remove RSVP
          currentRsvp.remove(userId);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('RSVP cancelled successfully'),
              backgroundColor: Colors.orange,
            ),
          );
        } else {
          // Add RSVP with attendee count
          if (event.totalAttendees + attendeeCount <= event.maxCapacity) {
            currentRsvp[userId] = attendeeCount;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('RSVP confirmed for $attendeeCount ${attendeeCount == 1 ? 'person' : 'people'}'),
                backgroundColor: Colors.green,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Event is full! Cannot add more attendees.'),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }
        }
        
        _events[index] = _events[index].copyWith(rsvpUsers: currentRsvp);
      }
    });
  }

  void _showRSVPDialog(Event event, String userId) {
    int attendeeCount = 1;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('RSVP for ${event.title}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('How many people will be attending?'),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: attendeeCount > 1 ? () {
                      setDialogState(() => attendeeCount--);
                    } : null,
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$attendeeCount',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    onPressed: event.totalAttendees + attendeeCount < event.maxCapacity ? () {
                      setDialogState(() => attendeeCount++);
                    } : null,
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Available spots: ${event.maxCapacity - event.totalAttendees}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _toggleRSVP(event, userId, attendeeCount);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B35),
              ),
              child: const Text('Confirm RSVP'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAdminView(Event event) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.admin_panel_settings, color: const Color(0xFFFF6B35)),
                const SizedBox(width: 8),
                Text(
                  'Admin View: ${event.title}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Statistics Cards
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Families',
                    '${event.confirmedFamilies}',
                    Icons.family_restroom,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildStatCard(
                    'Total Attendees',
                    '${event.totalAttendees}',
                    Icons.people,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Capacity',
                    '${event.maxCapacity}',
                    Icons.event_seat,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildStatCard(
                    'Available',
                    '${event.maxCapacity - event.totalAttendees}',
                    Icons.event_available,
                    Colors.purple,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            const Text(
              'Confirmed Families:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            
            // RSVP List
            Expanded(
              child: event.rsvpUsers.isEmpty
                  ? const Center(child: Text('No RSVPs yet'))
                  : ListView.builder(
                      itemCount: event.rsvpUsers.length,
                      itemBuilder: (context, index) {
                        final userId = event.rsvpUsers.keys.elementAt(index);
                        final attendeeCount = event.rsvpUsers[userId]!;
                        
                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xFFFF6B35),
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text('Family ${index + 1}'),
                            subtitle: Text('User ID: $userId'),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF6B35).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Text(
                                '$attendeeCount ${attendeeCount == 1 ? 'person' : 'people'}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFFF6B35),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Export functionality can be added here
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Export functionality coming soon!')),
                  );
                },
                icon: const Icon(Icons.download),
                label: const Text('Export Attendee List'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B35),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Events'),
        backgroundColor: const Color(0xFFFF6B35),
        foregroundColor: Colors.white,
      ),
      body: Consumer2<AuthService, SadhanaModel>(
        builder: (context, authService, sadhanaModel, child) {
          final currentUserId = authService.currentUser?.id ?? 'demo_user';
          final isAdmin = sadhanaModel.userProfile.isAdmin;
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _events.length,
            itemBuilder: (context, index) {
              final event = _events[index];
              final isUserRSVPed = event.rsvpUsers.containsKey(currentUserId);
              final userAttendeeCount = event.rsvpUsers[currentUserId] ?? 0;
              
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 150,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B35).withOpacity(0.1),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.event,
                          size: 60,
                          color: const Color(0xFFFF6B35),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  event.title,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              if (isAdmin)
                                IconButton(
                                  onPressed: () => _showAdminView(event),
                                  icon: const Icon(Icons.admin_panel_settings),
                                  color: const Color(0xFFFF6B35),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            event.description,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Text(
                                '${event.date.day}/${event.date.month}/${event.date.year}',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              const SizedBox(width: 16),
                              Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  event.location,
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildAttendeeInfo(event),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(child: _buildRSVPButton(event, currentUserId, isUserRSVPed, userAttendeeCount)),
                              if (isAdmin) ...[
                                const SizedBox(width: 10),
                                OutlinedButton.icon(
                                  onPressed: () => _showAdminView(event),
                                  icon: const Icon(Icons.admin_panel_settings, size: 18),
                                  label: const Text('Admin'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFFFF6B35),
                                    side: const BorderSide(color: Color(0xFFFF6B35)),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildAttendeeInfo(Event event) {
    final attendeePercentage = event.maxCapacity > 0 
        ? (event.totalAttendees / event.maxCapacity) * 100 
        : 0;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${event.totalAttendees} attending',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                '${event.maxCapacity} capacity',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: attendeePercentage / 100,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              attendeePercentage > 80 
                  ? Colors.red 
                  : attendeePercentage > 50 
                      ? Colors.orange 
                      : Colors.green,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${attendeePercentage.toStringAsFixed(1)}% full',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRSVPButton(Event event, String userId, bool isRSVPed, int attendeeCount) {
    if (isRSVPed) {
      return ElevatedButton.icon(
        onPressed: () => _toggleRSVP(event, userId, 0),
        icon: const Icon(Icons.check_circle),
        label: Text('Going ($attendeeCount)'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
      );
    } else {
      return ElevatedButton.icon(
        onPressed: event.totalAttendees >= event.maxCapacity 
            ? null 
            : () => _showRSVPDialog(event, userId),
        icon: const Icon(Icons.event_available),
        label: Text(event.totalAttendees >= event.maxCapacity ? 'Full' : 'RSVP'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF6B35),
          foregroundColor: Colors.white,
        ),
      );
    }
  }
} 