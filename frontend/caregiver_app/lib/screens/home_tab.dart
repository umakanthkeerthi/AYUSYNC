import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/theme.dart';
import '../widgets/glass_card.dart';
import 'profile_tab.dart';
import '../services/api_service.dart';

class HomeTab extends StatefulWidget {
  final String caregiverId;
  const HomeTab({super.key, required this.caregiverId});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  Map<String, dynamic>? _dashboardData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final data = await ApiService().getDashboardData(widget.caregiverId);
      setState(() {
        _dashboardData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AyuTheme.primary));
    }
    
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.alertTriangle, color: AyuTheme.amber, size: 48),
            const SizedBox(height: 16),
            Text('Error loading data', style: const TextStyle(fontWeight: FontWeight.bold, color: AyuTheme.textMain)),
            Text(_errorMessage!, style: const TextStyle(color: AyuTheme.textMuted, fontSize: 12), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _fetchData, child: const Text('Retry'))
          ],
        ),
      );
    }

    final patient = _dashboardData!['patient'];
    final glance = _dashboardData!['glance'] as List;
    final alerts = _dashboardData!['alerts'] as List;
    final timeline = _dashboardData!['timeline'] as List;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          _buildHeroHeader(context, patient),
          const SizedBox(height: 32),
          _buildSectionTitle('Overview'),
          const SizedBox(height: 16),
          _buildGlanceGrid(glance),
          const SizedBox(height: 32),
          
          if (alerts.isNotEmpty) ...[
            _buildSectionTitle('Action Required'),
            const SizedBox(height: 16),
            ...alerts.map((a) => _buildMinimalAlertCard(context, a)).toList(),
            const SizedBox(height: 32),
          ],
          
          _buildSectionTitle('Today\'s Activity'),
          const SizedBox(height: 16),
          _buildCleanTimeline(timeline),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildHeroHeader(BuildContext context, Map<String, dynamic> patient) {
    Color vitalsColor = patient['vitals_color'] == 'green' ? AyuTheme.green : AyuTheme.amber;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Caring For',
                  style: TextStyle(
                    color: AyuTheme.textMuted,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ).animate().fadeIn().slideX(begin: -0.2),
                const SizedBox(height: 4),
                Text(
                  patient['name'],
                  style: const TextStyle(
                    color: AyuTheme.textMain,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Outfit',
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileTab()),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AyuTheme.primary.withOpacity(0.4),
                      blurRadius: 15,
                      spreadRadius: -2,
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 32,
                  backgroundColor: AyuTheme.primary.withOpacity(0.1),
                  child: const Icon(LucideIcons.user, size: 32, color: AyuTheme.primary),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AyuTheme.border.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: vitalsColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                patient['vitals_status'],
                style: TextStyle(
                  color: vitalsColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Updated ${patient['last_updated']}',
                style: const TextStyle(
                  color: AyuTheme.textMuted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: AyuTheme.textMain,
      ),
    );
  }

  Widget _buildGlanceGrid(List glanceItems) {
    return Row(
      children: glanceItems.map((item) {
        IconData icon = LucideIcons.pill;
        if (item['icon'] == 'droplet') icon = LucideIcons.droplet;
        if (item['icon'] == 'calendar') icon = LucideIcons.calendar;
        
        Color color = AyuTheme.primary;
        if (item['color'] == 'green') color = AyuTheme.green;
        if (item['color'] == 'amber') color = AyuTheme.amber;

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: item == glanceItems.last ? 0 : 12),
            child: _buildMinimalGlanceCard(icon, item['title'], item['status'], color),
          ),
        );
      }).toList().animate(interval: 100.ms).fadeIn(duration: 400.ms).scale(begin: const Offset(0.9, 0.9)),
    );
  }

  Widget _buildMinimalGlanceCard(IconData icon, String title, String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AyuTheme.textMain),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            status,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMinimalAlertCard(BuildContext context, Map<String, dynamic> alert) {
    Color color = alert['color'] == 'amber' ? AyuTheme.amber : AyuTheme.primary;
    String btnLabel = alert['action_type'] == 'ARRANGE_TRANSPORT' ? 'Arrange Transport' : 'Review Details';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AyuTheme.primary.withOpacity(0.12),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AyuTheme.primary.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(LucideIcons.alertTriangle, color: AyuTheme.amber, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    alert['text'],
                    style: const TextStyle(
                      color: AyuTheme.textMain,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (alert['action_type'] == 'ARRANGE_TRANSPORT') {
                    final patient = _dashboardData?['patient'];
                    if (patient != null) {
                      await ApiService().arrangeTransport(widget.caregiverId, patient['id'], alert['id'] ?? '');
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Transport request submitted successfully!')),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AyuTheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                ),
                child: Text(btnLabel, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCleanTimeline(List timelineItems) {
    final validItems = timelineItems.where((i) => i != null).toList();
    if (validItems.isEmpty) {
      return const Text("No recent activity.", style: TextStyle(color: AyuTheme.textMuted));
    }
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: validItems.asMap().entries.map((entry) {
          int idx = entry.key;
          var item = entry.value;
          
          IconData icon = LucideIcons.checkCircle2;
          if (item['icon'] == 'activity') icon = LucideIcons.activity;
          if (item['icon'] == 'pill') icon = LucideIcons.pill;
          if (item['icon'] == 'fileText') icon = LucideIcons.fileText;
          if (item['icon'] == 'calendar') icon = LucideIcons.calendar;
          if (item['icon'] == 'messageSquare') icon = LucideIcons.messageSquare;
          
          Color color = AyuTheme.primary;
          if (item['color'] == 'green') color = AyuTheme.green;
          if (item['color'] == 'amber') color = AyuTheme.amber;

          return Column(
            children: [
              _buildCleanTimelineItem(icon, item['title'], item['time'], color),
              if (idx < validItems.length - 1)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Divider(color: AyuTheme.border.withOpacity(0.3), height: 1),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCleanTimelineItem(IconData icon, String title, String time, Color iconColor) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AyuTheme.textMain),
          ),
        ),
        Text(time, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AyuTheme.textMuted)),
      ],
    );
  }

}


