import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../utils/theme.dart';

class TripModel {
  final String patientId;
  final String time;
  final String duration;
  final String distance;
  final String status;
  final bool isRecent;

  TripModel({
    required this.patientId,
    required this.time,
    required this.duration,
    required this.distance,
    required this.status,
    this.isRecent = false,
  });
}

class HistoryTab extends StatefulWidget {
  const HistoryTab({super.key});

  @override
  State<HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {
  final TextEditingController _searchController = TextEditingController();
  
  final List<TripModel> _allTrips = [
    TripModel(patientId: '#10480', time: '14:30 PM', duration: '18 min', distance: '6.2 km', status: 'Completed', isRecent: true),
    TripModel(patientId: '#10472', time: '11:15 AM', duration: '22 min', distance: '8.4 km', status: 'Completed'),
    TripModel(patientId: '#10468', time: '09:05 AM', duration: '14 min', distance: '4.1 km', status: 'Completed'),
    TripModel(patientId: '#10455', time: 'Yesterday', duration: '--', distance: '--', status: 'Cancelled'),
    TripModel(patientId: '#10412', time: 'Yesterday', duration: '28 min', distance: '12.0 km', status: 'Completed'),
    TripModel(patientId: '#10398', time: 'Oct 12', duration: '15 min', distance: '5.5 km', status: 'Completed'),
  ];

  List<TripModel> _filteredTrips = [];

  @override
  void initState() {
    super.initState();
    _filteredTrips = _allTrips;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredTrips = _allTrips;
      } else {
        _filteredTrips = _allTrips.where((trip) => trip.patientId.toLowerCase().contains(query)).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 24, 20, 16),
          child: Text('Completed Trips', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, fontFamily: 'Outfit')),
        ),
        
        // Search Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search Patient ID...',
              hintStyle: const TextStyle(color: DriverTheme.textMuted),
              prefixIcon: const Icon(LucideIcons.search, color: DriverTheme.textMuted),
              filled: true,
              fillColor: DriverTheme.surface,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: DriverTheme.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: DriverTheme.primary),
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // List of Trips
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            itemCount: _filteredTrips.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final trip = _filteredTrips[index];
              return _buildTripCard(trip);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTripCard(TripModel trip) {
    final isCancelled = trip.status == 'Cancelled';
    final mainColor = isCancelled ? DriverTheme.textMuted : DriverTheme.green;
    final icon = isCancelled ? LucideIcons.xCircle : LucideIcons.checkCircle2;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DriverTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: DriverTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: DriverTheme.background,
                      shape: BoxShape.circle,
                      border: Border.all(color: DriverTheme.border),
                      boxShadow: DriverTheme.floatingIconShadow,
                    ),
                    child: Icon(icon, color: mainColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Patient ${trip.patientId}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 2),
                      Text(trip.time, style: const TextStyle(color: DriverTheme.textMuted, fontSize: 12)),
                    ],
                  ),
                ],
              ),
              if (trip.isRecent)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: DriverTheme.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: DriverTheme.green.withOpacity(0.3)),
                  ),
                  child: const Text('Today', style: TextStyle(color: DriverTheme.green, fontSize: 10, fontWeight: FontWeight.bold)),
                )
              else if (isCancelled)
                 Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: DriverTheme.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: DriverTheme.border),
                  ),
                  child: const Text('Cancelled', style: TextStyle(color: DriverTheme.textMuted, fontSize: 10, fontWeight: FontWeight.bold)),
                )
            ],
          ),
          if (!isCancelled) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                _buildFloatingStatBadge(LucideIcons.clock, trip.duration),
                const SizedBox(width: 12),
                _buildFloatingStatBadge(LucideIcons.navigation, trip.distance),
              ],
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildFloatingStatBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: DriverTheme.background,
        borderRadius: BorderRadius.circular(12),
        boxShadow: DriverTheme.floatingIconShadow,
        border: Border.all(color: DriverTheme.border.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: DriverTheme.textMuted, size: 14),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(color: DriverTheme.textMain, fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
