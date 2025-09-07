import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/sadhana_model.dart';

class LogScreen extends StatefulWidget {
  const LogScreen({super.key});

  @override
  State<LogScreen> createState() => _LogScreenState();
}

class _LogScreenState extends State<LogScreen> {
  late TextEditingController _roundsController;
  late TextEditingController _readingController;
  late TextEditingController _lectureController;
  late TextEditingController _associationController;

  @override
  void initState() {
    super.initState();
    _roundsController = TextEditingController();
    _readingController = TextEditingController();
    _lectureController = TextEditingController();
    _associationController = TextEditingController();
  }

  @override
  void dispose() {
    _roundsController.dispose();
    _readingController.dispose();
    _lectureController.dispose();
    _associationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Log Sadhana'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Consumer<SadhanaModel>(
        builder: (context, model, child) {
          // Initialize controllers with current values
          if (_roundsController.text.isEmpty) {
            _roundsController.text = model.todaySadhana.japaMalaCount.toString();
            _readingController.text = model.todaySadhana.readingMinutes.toString();
            _lectureController.text = model.todaySadhana.hearingMinutes.toString();
            _associationController.text = model.todaySadhana.serviceHours.toString();
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Record Your Daily Practice',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Update your spiritual practices for today',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),

                _buildInputCard(
                  context,
                  icon: Icons.circle_outlined,
                  title: 'Rounds Chanted',
                  subtitle: 'Japa meditation rounds',
                  controller: _roundsController,
                  suffix: 'rounds',
                  color: Colors.orange,
                ),
                const SizedBox(height: 16),

                _buildInputCard(
                  context,
                  icon: Icons.menu_book,
                  title: 'Scriptural Reading',
                  subtitle: 'Bhagavatam, Gita, etc.',
                  controller: _readingController,
                  suffix: 'minutes',
                  color: Colors.blue,
                ),
                const SizedBox(height: 16),

                _buildInputCard(
                  context,
                  icon: Icons.headphones,
                  title: 'Lecture Hearing',
                  subtitle: 'Spiritual discourses',
                  controller: _lectureController,
                  suffix: 'minutes',
                  color: Colors.green,
                ),
                const SizedBox(height: 16),

                _buildInputCard(
                  context,
                  icon: Icons.volunteer_activism,
                  title: 'Service Hours',
                  subtitle: 'Hours spent in service',
                  controller: _associationController,
                  suffix: 'hours',
                  color: Colors.purple,
                ),
                const SizedBox(height: 32),

                SizedBox(
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
                    child: ElevatedButton(
                      onPressed: () => _saveSadhana(context, model),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Save Today\'s Sadhana',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required TextEditingController controller,
    required String suffix,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
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
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: color.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: color, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                suffix,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _saveSadhana(BuildContext context, SadhanaModel model) {
    final rounds = int.tryParse(_roundsController.text) ?? 0;
    final reading = int.tryParse(_readingController.text) ?? 0;
    final lecture = int.tryParse(_lectureController.text) ?? 0;
    final association = int.tryParse(_associationController.text) ?? 0;

    final newSadhana = SadhanaData(
      date: DateTime.now(),
      japaMalaCount: rounds,
      readingMinutes: reading,
      hearingMinutes: lecture,
      serviceHours: association,
      morningProgram: false,
      eveningProgram: false,
      japaByTimeOfDay: const {'morning': 0, 'afternoon': 0, 'evening': 0, 'night': 0},
      notes: '',
    );
    model.updateTodaySadhana(newSadhana);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Sadhana saved successfully!'),
        backgroundColor: const Color(0xFFFF6B35),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
} 