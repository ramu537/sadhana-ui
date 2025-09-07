import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/sadhana_model.dart';
import 'package:intl/intl.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress'),
        backgroundColor: const Color(0xFFFF6B35),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Consumer<SadhanaModel>(
          builder: (context, model, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatsOverview(model),
                const SizedBox(height: 24),
                _buildMonthlyAnalytics(model),
                const SizedBox(height: 24),
                _buildSadhanaHistory(model),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatsOverview(SadhanaModel model) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFF6B35),
            Color(0xFFFF4757),
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
        children: [
          const Text(
            'Your Sadhana Journey',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Current Streak', '${model.currentStreak} days', Icons.local_fire_department),
              _buildStatItem('Target Rounds', '${model.targetRounds}', Icons.adjust),
              _buildStatItem('Today\'s Rounds', '${model.todaySadhana.japaMalaCount}', Icons.beenhere),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 30),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white70,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildMonthlyAnalytics(SadhanaModel model) {
    final analytics = model.monthlyAnalytics;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'This Month\'s Analytics',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        // Overview Cards
        Row(
          children: [
            Expanded(
              child: _buildAnalyticsCard(
                'Active Days',
                '${analytics['totalDays']}',
                Icons.calendar_today,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildAnalyticsCard(
                'Consistency',
                '${analytics['consistency'].toStringAsFixed(1)}%',
                Icons.trending_up,
                Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildAnalyticsCard(
                'Avg Japa/Day',
                '${analytics['averageJapa'].toStringAsFixed(1)}',
                Icons.self_improvement,
                const Color(0xFFFF6B35),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildAnalyticsCard(
                'Total Reading',
                '${analytics['totalReading']} min',
                Icons.menu_book,
                Colors.purple,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 20),
        
        // Japa Time Distribution
        _buildJapaTimeDistribution(analytics['japaByTime']),
        
        const SizedBox(height: 20),
        
        // Reading & Hearing Progress
        _buildReadingHearingProgress(analytics),
      ],
    );
  }

  Widget _buildAnalyticsCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
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
              fontSize: 18,
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

  Widget _buildJapaTimeDistribution(Map<String, dynamic> japaByTime) {
    final total = japaByTime.values.fold<int>(0, (sum, count) => sum + (count as int));
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.access_time, color: const Color(0xFFFF6B35)),
              const SizedBox(width: 8),
              const Text(
                'Chanting Time Distribution',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          if (total == 0)
            const Center(
              child: Text(
                'No chanting data for this month',
                style: TextStyle(color: Colors.grey),
              ),
            )
          else ...[
            _buildTimeDistributionBar('Morning', japaByTime['morning'], total, Colors.orange),
            const SizedBox(height: 8),
            _buildTimeDistributionBar('Afternoon', japaByTime['afternoon'], total, Colors.yellow[700]!),
            const SizedBox(height: 8),
            _buildTimeDistributionBar('Evening', japaByTime['evening'], total, Colors.deepOrange),
            const SizedBox(height: 8),
            _buildTimeDistributionBar('Night', japaByTime['night'], total, Colors.indigo),
            
            const SizedBox(height: 16),
            Text(
              'Total rounds this month: $total',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFFFF6B35),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeDistributionBar(String timeLabel, int count, int total, Color color) {
    final percentage = total > 0 ? (count / total) : 0.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              timeLabel,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            Text(
              '$count rounds (${(percentage * 100).toStringAsFixed(1)}%)',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: percentage,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ],
    );
  }

  Widget _buildReadingHearingProgress(Map<String, dynamic> analytics) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.book, color: const Color(0xFFFF6B35)),
              const SizedBox(width: 8),
              const Text(
                'Study & Hearing Progress',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildProgressIndicator(
                  'Reading',
                  '${analytics['totalReading']} min',
                  analytics['totalReading'] / 600.0, // Target: 10 hours per month
                  Icons.menu_book,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildProgressIndicator(
                  'Hearing',
                  '${analytics['totalHearing']} min',
                  analytics['totalHearing'] / 600.0, // Target: 10 hours per month
                  Icons.headphones,
                  Colors.green,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Progress insights
          if (analytics['totalReading'] > 0 || analytics['totalHearing'] > 0) ...[
            const Divider(),
            _buildProgressInsights(analytics),
          ],
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(String title, String value, double progress, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 30),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
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
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress.clamp(0.0, 1.0),
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
        const SizedBox(height: 4),
        Text(
          '${(progress * 100).toStringAsFixed(1)}% of monthly goal',
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressInsights(Map<String, dynamic> analytics) {
    final readingMinutes = analytics['totalReading'] as int;
    final hearingMinutes = analytics['totalHearing'] as int;
    final totalStudyMinutes = readingMinutes + hearingMinutes;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Study Insights',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        
        if (totalStudyMinutes > 0) ...[
          Row(
            children: [
              Icon(Icons.insights, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Total study time: ${(totalStudyMinutes / 60).toStringAsFixed(1)} hours',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.balance, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  readingMinutes > hearingMinutes 
                      ? 'More focused on reading' 
                      : hearingMinutes > readingMinutes 
                          ? 'More focused on hearing' 
                          : 'Balanced reading and hearing',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),
        ] else ...[
          Row(
            children: [
              Icon(Icons.lightbulb_outline, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Start tracking your reading and hearing to see insights!',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildSadhanaHistory(SadhanaModel model) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Sadhana',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        if (model.sadhanaHistory.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                'No sadhana entries yet. Start logging your practice!',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: model.sadhanaHistory.take(7).length,
            itemBuilder: (context, index) {
              final entry = model.sadhanaHistory[index];
              final isToday = entry.date.day == DateTime.now().day &&
                             entry.date.month == DateTime.now().month &&
                             entry.date.year == DateTime.now().year;
              
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: isToday 
                      ? Border.all(color: const Color(0xFFFF6B35).withOpacity(0.3), width: 2)
                      : Border.all(color: Colors.grey[200]!),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: isToday 
                            ? const Color(0xFFFF6B35) 
                            : Colors.grey[400],
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Center(
                        child: Text(
                          '${entry.date.day}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                DateFormat('MMM dd').format(entry.date),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (isToday)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFF6B35),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Text(
                                    'Today',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.adjust, size: 16, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Text(
                                '${entry.japaMalaCount} rounds',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              const SizedBox(width: 16),
                              Icon(Icons.menu_book, size: 16, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Text(
                                '${entry.readingMinutes}m',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
         );
   }
 } 