import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/theme.dart';

class RefillsScreen extends StatefulWidget {
  const RefillsScreen({super.key});

  @override
  State<RefillsScreen> createState() => _RefillsScreenState();
}

class _RefillsScreenState extends State<RefillsScreen> {
  List<dynamic> _refills = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRefills();
  }

  Future<void> _fetchRefills() async {
    try {
      final response = await http.get(Uri.parse('http://127.0.0.1:8001/api/v1/pharmacy/refills'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            _refills = data['refills'];
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() {
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

        return SingleChildScrollView(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Refill Requests', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: PharmacyTheme.textDark)),
              const SizedBox(height: 4),
              const Text('Review medication refill requests.', style: TextStyle(color: PharmacyTheme.textSecondary, fontSize: 15)),
              const SizedBox(height: 24),
              _buildActionBar(isMobile),
              const SizedBox(height: 24),
              if (_isLoading)
                const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()))
              else
                _buildRefillsList(isMobile),
            ],
          ),
        );
      },
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
                    hintText: 'Search patients...',
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
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(LucideIcons.filter, size: 16),
          label: const Text('Status'),
          style: OutlinedButton.styleFrom(
            foregroundColor: PharmacyTheme.textDark,
            side: const BorderSide(color: PharmacyTheme.border),
          ),
        )
      ],
    );
  }

  Widget _buildRefillsList(bool isMobile) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: PharmacyTheme.cardRadius,
        border: Border.all(color: PharmacyTheme.border),
        boxShadow: PharmacyTheme.premiumShadow,
      ),
      child: Column(
        children: [
          if (!isMobile)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: PharmacyTheme.border)),
                color: Colors.white,
              ),
              child: const Row(
                children: [
                  Expanded(flex: 2, child: Text('Patient', style: TextStyle(fontWeight: FontWeight.w600, color: PharmacyTheme.textSecondary, fontSize: 13))),
                  Expanded(flex: 3, child: Text('Medication', style: TextStyle(fontWeight: FontWeight.w600, color: PharmacyTheme.textSecondary, fontSize: 13))),
                  Expanded(flex: 2, child: Text('Status', style: TextStyle(fontWeight: FontWeight.w600, color: PharmacyTheme.textSecondary, fontSize: 13))),
                  Expanded(flex: 1, child: Align(alignment: Alignment.centerRight, child: Text('Action', style: TextStyle(fontWeight: FontWeight.w600, color: PharmacyTheme.textSecondary, fontSize: 13)))),
                ],
              ),
            ),
          
          if (_refills.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32.0),
              child: Text('No active refill requests.', style: TextStyle(color: PharmacyTheme.textSecondary)),
            ),
            
          for (var r in _refills) ...[
            _buildRefillItem(r['patient_name'] ?? 'Unknown', r['drug_name'] ?? 'Unknown', r['status'] ?? 'Pending', isMobile),
            const Divider(height: 1, color: PharmacyTheme.border),
          ],
        ],
      ),
    );
  }

  Widget _buildRefillItem(String name, String meds, String status, bool isMobile) {
    return InkWell(
      onTap: () {},
      hoverColor: const Color(0xFFF9FAFB),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
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
                const SizedBox(height: 8),
                Text(meds, style: const TextStyle(fontWeight: FontWeight.w500, color: PharmacyTheme.textSecondary)),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {},
                    child: const Text('Approve'),
                  ),
                ),
              ],
            )
          : Row(
              children: [
                Expanded(flex: 2, child: Text(name, style: const TextStyle(fontWeight: FontWeight.w600, color: PharmacyTheme.textDark))),
                Expanded(flex: 3, child: Text(meds, style: const TextStyle(fontWeight: FontWeight.w500, color: PharmacyTheme.textSecondary))),
                Expanded(flex: 2, child: _buildStatusBadge(status)),
                Expanded(
                  flex: 1, 
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(onPressed: () {}, child: const Text('Approve')),
                  ),
                ),
              ],
            ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg = status == 'Pending' ? PharmacyTheme.statOrangeBg : PharmacyTheme.statGreenBg;
    Color text = status == 'Pending' ? PharmacyTheme.statOrange : PharmacyTheme.statGreen;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)), // Subtle shape
      child: Text(status, style: TextStyle(color: text, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}
