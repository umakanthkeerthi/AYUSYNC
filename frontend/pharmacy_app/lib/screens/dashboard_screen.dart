import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/theme.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isLoading = true;
  String _error = '';
  List<dynamic> _prescriptions = [];

  @override
  void initState() {
    super.initState();
    _fetchPrescriptions();
  }

  Future<void> _fetchPrescriptions() async {
    try {
      final response = await http.get(Uri.parse('http://127.0.0.1:8001/api/v1/pharmacy/prescriptions'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            _prescriptions = data['prescriptions'];
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _error = 'Failed to load prescriptions';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error connecting to server';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 600;
        final double padding = isMobile ? 16.0 : 32.0;

        if (_isLoading) {
          return const Center(child: CircularProgressIndicator(color: PharmacyTheme.primary));
        }

        if (_error.isNotEmpty) {
          return Center(child: Text(_error, style: const TextStyle(color: Colors.red)));
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Prescriptions', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: PharmacyTheme.textDark, letterSpacing: -0.5)),
              const SizedBox(height: 6),
              const Text('Review and process incoming prescriptions.', style: TextStyle(color: PharmacyTheme.textSecondary, fontSize: 16)),
              const SizedBox(height: 32),
              _buildActionBar(isMobile),
              const SizedBox(height: 24),
              _buildQueueTable(context, isMobile),
            ],
          ),
        );
      }
    );
  }

  Widget _buildActionBar(bool isMobile) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 16,
      runSpacing: 16,
      children: [
        Container(
          width: isMobile ? double.infinity : 300,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: PharmacyTheme.border),
            borderRadius: BorderRadius.circular(6),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: const Row(
            children: [
              Icon(LucideIcons.search, size: 16, color: PharmacyTheme.textSecondary),
              SizedBox(width: 8),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search prescriptions...',
                    hintStyle: TextStyle(color: PharmacyTheme.textSecondary, fontSize: 14),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
        ),
        Wrap(
          spacing: 12,
          children: [
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(LucideIcons.filter, size: 16),
              label: const Text('Filter'),
              style: OutlinedButton.styleFrom(
                foregroundColor: PharmacyTheme.textDark,
                side: const BorderSide(color: PharmacyTheme.border),
              ),
            ),
            ElevatedButton.icon(
              onPressed: _fetchPrescriptions,
              icon: const Icon(LucideIcons.refreshCcw, size: 16),
              label: const Text('Refresh'),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildQueueTable(BuildContext context, bool isMobile) {
    return Column(
      children: [
        if (!isMobile)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: [
                Expanded(flex: 2, child: Text('PATIENT', style: TextStyle(fontWeight: FontWeight.w700, color: PharmacyTheme.textSecondary, fontSize: 12, letterSpacing: 1.0))),
                Expanded(flex: 3, child: Text('MEDICATION', style: TextStyle(fontWeight: FontWeight.w700, color: PharmacyTheme.textSecondary, fontSize: 12, letterSpacing: 1.0))),
                Expanded(flex: 2, child: Text('PRIORITY', style: TextStyle(fontWeight: FontWeight.w700, color: PharmacyTheme.textSecondary, fontSize: 12, letterSpacing: 1.0))),
                Expanded(flex: 2, child: Text('STATUS', style: TextStyle(fontWeight: FontWeight.w700, color: PharmacyTheme.textSecondary, fontSize: 12, letterSpacing: 1.0))),
                Expanded(flex: 1, child: Align(alignment: Alignment.centerRight, child: Text('ACTION', style: TextStyle(fontWeight: FontWeight.w700, color: PharmacyTheme.textSecondary, fontSize: 12, letterSpacing: 1.0)))),
              ],
            ),
          ),
        if (_prescriptions.isEmpty)
          const Padding(
            padding: EdgeInsets.all(32.0),
            child: Text('No active prescriptions found in database.', style: TextStyle(color: PharmacyTheme.textSecondary)),
          ),
        for (var p in _prescriptions) ...[
          _buildQueueItem(context, p['patient_name'] ?? 'Unknown', p['order_id'] ?? '#RX-000', p['drug_name'] ?? 'Unknown', p['priority'] ?? 'Routine', p['status'] ?? 'New', isMobile),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _buildQueueItem(BuildContext context, String name, String id, String meds, String urgency, String status, bool isMobile) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: PharmacyTheme.cardRadius,
        boxShadow: PharmacyTheme.premiumShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showPrescriptionDetail(context, name, id, meds, urgency, status),
          borderRadius: PharmacyTheme.cardRadius,
          hoverColor: PharmacyTheme.primary.withOpacity(0.04),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
      child: isMobile 
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: PharmacyTheme.textDark)),
                  _buildStatusBadge(status),
                ],
              ),
              const SizedBox(height: 4),
              Text('ID: $id', style: const TextStyle(color: PharmacyTheme.textSecondary, fontSize: 13)),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(LucideIcons.pill, size: 16, color: PharmacyTheme.textSecondary),
                  const SizedBox(width: 8),
                  Expanded(child: Text(meds, style: const TextStyle(fontWeight: FontWeight.w500))),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(LucideIcons.alertCircle, size: 16, color: PharmacyTheme.textSecondary),
                  const SizedBox(width: 8),
                  Text(urgency, style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: urgency == 'Urgent' ? PharmacyTheme.statRed : PharmacyTheme.textSecondary,
                  )),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: PharmacyTheme.primary,
                    side: const BorderSide(color: PharmacyTheme.primary),
                  ),
                  child: const Text('Process'),
                ),
              ),
            ],
          )
        : Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontWeight: FontWeight.bold, color: PharmacyTheme.textDark)),
                    Text(id, style: const TextStyle(color: PharmacyTheme.textSecondary, fontSize: 13)),
                  ],
                ),
              ),
              Expanded(flex: 3, child: Text(meds, style: const TextStyle(fontWeight: FontWeight.w500))),
              Expanded(
                flex: 2, 
                child: Text(urgency, style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: urgency == 'Urgent' ? PharmacyTheme.statRed : PharmacyTheme.textSecondary,
                )),
              ),
              Expanded(flex: 2, child: _buildStatusBadge(status)),
              Expanded(
                flex: 1, 
                child: Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton(
                    onPressed: () => _showPrescriptionDetail(context, name, id, meds, urgency, status),
                    style: FilledButton.styleFrom(
                      backgroundColor: PharmacyTheme.primary.withOpacity(0.1),
                      foregroundColor: PharmacyTheme.primary,
                      shape: RoundedRectangleBorder(borderRadius: PharmacyTheme.pillRadius),
                      elevation: 0,
                    ),
                    child: const Text('Process'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }

  void _showPrescriptionDetail(BuildContext context, String name, String id, String meds, String urgency, String status) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withOpacity(0.4),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Align(
          alignment: Alignment.centerRight,
          child: Material(
            color: Colors.white,
            elevation: 8,
            child: SizedBox(
              width: 400,
              height: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drawer Header
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Prescription $id', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: PharmacyTheme.textDark)),
                            const SizedBox(height: 8),
                            _buildStatusBadge(status),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(LucideIcons.x, color: PharmacyTheme.textSecondary),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: PharmacyTheme.border),
                  // Drawer Body
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(24),
                      children: [
                        _buildDetailRow('Patient', name),
                        _buildDetailRow('Medication', meds),
                        _buildDetailRow('Priority', urgency),
                        _buildDetailRow('Dosage', 'Take as directed'),
                        _buildDetailRow('Prescriber', 'Dr. AyuSync'),
                        _buildDetailRow('Date', 'Today'),
                      ],
                    ),
                  ),
                  // Drawer Footer
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Process Prescription'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
          child: child,
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: PharmacyTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(color: PharmacyTheme.textDark, fontSize: 15, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color text;
    if (status == 'New') {
      bg = PharmacyTheme.statBlueBg; text = PharmacyTheme.statBlue;
    } else if (status == 'Preparing') {
      bg = PharmacyTheme.statOrangeBg; text = PharmacyTheme.statOrange;
    } else if (status == 'Ready') {
      bg = PharmacyTheme.statGreenBg; text = PharmacyTheme.statGreen;
    } else {
      bg = const Color(0xFFF8FAFC); text = PharmacyTheme.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: PharmacyTheme.pillRadius),
      child: Text(status, style: TextStyle(color: text, fontSize: 13, fontWeight: FontWeight.w700)),
    );
  }
}
