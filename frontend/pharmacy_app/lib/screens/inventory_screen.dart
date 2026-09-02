import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/theme.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  List<dynamic> _inventory = [];
  int _lowStockCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchInventory();
  }

  Future<void> _fetchInventory() async {
    try {
      final response = await http.get(Uri.parse('http://127.0.0.1:8001/api/v1/pharmacy/inventory'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          final inv = data['inventory'] as List<dynamic>;
          int lowCount = inv.where((i) => i['status'] != 'In Stock').length;
          
          setState(() {
            _inventory = inv;
            _lowStockCount = lowCount;
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
              Row(
                children: [
                  const Text('Inventory', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: PharmacyTheme.textDark)),
                  const SizedBox(width: 12),
                  if (_lowStockCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: const BoxDecoration(color: PharmacyTheme.statRedBg, borderRadius: BorderRadius.all(Radius.circular(4))),
                      child: Text('$_lowStockCount Low Stock', style: const TextStyle(color: PharmacyTheme.statRed, fontSize: 12, fontWeight: FontWeight.bold)),
                    )
                ],
              ),
              const SizedBox(height: 4),
              const Text('Monitor medicines and stock levels.', style: TextStyle(color: PharmacyTheme.textSecondary, fontSize: 15)),
              const SizedBox(height: 24),
              _buildActionBar(isMobile),
              const SizedBox(height: 24),
              if (_isLoading)
                const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()))
              else
                _buildInventoryList(isMobile),
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
                    hintText: 'Search medicines...',
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
              icon: const Icon(LucideIcons.list, size: 16),
              label: const Text('Category'),
              style: OutlinedButton.styleFrom(
                foregroundColor: PharmacyTheme.textDark,
                side: const BorderSide(color: PharmacyTheme.border),
              ),
            ),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(LucideIcons.filter, size: 16),
              label: const Text('Stock Status'),
              style: OutlinedButton.styleFrom(
                foregroundColor: PharmacyTheme.textDark,
                side: const BorderSide(color: PharmacyTheme.border),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(LucideIcons.plus, size: 16),
              label: const Text('Add Medicine'),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildInventoryList(bool isMobile) {
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
                  Expanded(flex: 3, child: Text('Medicine / Category', style: TextStyle(fontWeight: FontWeight.w600, color: PharmacyTheme.textSecondary, fontSize: 13))),
                  Expanded(flex: 2, child: Text('Available', style: TextStyle(fontWeight: FontWeight.w600, color: PharmacyTheme.textSecondary, fontSize: 13))),
                  Expanded(flex: 2, child: Text('Status', style: TextStyle(fontWeight: FontWeight.w600, color: PharmacyTheme.textSecondary, fontSize: 13))),
                  Expanded(flex: 1, child: Align(alignment: Alignment.centerRight, child: Text('Action', style: TextStyle(fontWeight: FontWeight.w600, color: PharmacyTheme.textSecondary, fontSize: 13)))),
                ],
              ),
            ),
            
          if (_inventory.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32.0),
              child: Text('No inventory records found.', style: TextStyle(color: PharmacyTheme.textSecondary)),
            ),
            
          for (var i in _inventory) ...[
            _buildInventoryItem(i['med'] ?? 'Unknown', i['category'] ?? 'General', i['stock'] ?? 0, i['status'] ?? 'Low Stock', isMobile),
            const Divider(height: 1, color: PharmacyTheme.border),
          ],
        ],
      ),
    );
  }

  Widget _buildInventoryItem(String med, String category, int stock, String status, bool isMobile) {
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
                    Text(med, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: PharmacyTheme.textDark)),
                    _buildStatusBadge(status),
                  ],
                ),
                const SizedBox(height: 4),
                Text(category, style: const TextStyle(fontWeight: FontWeight.w500, color: PharmacyTheme.textSecondary)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(LucideIcons.package, size: 16, color: PharmacyTheme.textSecondary),
                    const SizedBox(width: 8),
                    Expanded(child: Text('$stock units left', style: const TextStyle(fontWeight: FontWeight.w500))),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(onPressed: () {}, child: const Text('Update Stock')),
                ),
              ],
            )
          : Row(
              children: [
                Expanded(
                  flex: 3, 
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(med, style: const TextStyle(fontWeight: FontWeight.w600, color: PharmacyTheme.textDark)),
                      Text(category, style: const TextStyle(fontSize: 13, color: PharmacyTheme.textSecondary)),
                    ],
                  )
                ),
                Expanded(flex: 2, child: Text('$stock units', style: const TextStyle(fontWeight: FontWeight.w500, color: PharmacyTheme.textDark))),
                Expanded(flex: 2, child: _buildStatusBadge(status)),
                Expanded(
                  flex: 1, 
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(icon: const Icon(LucideIcons.edit2, size: 18, color: PharmacyTheme.textSecondary), onPressed: () {}),
                  ),
                ),
              ],
            ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg; Color text;
    if (status == 'In Stock') { bg = PharmacyTheme.statGreenBg; text = PharmacyTheme.statGreen; }
    else if (status == 'Low Stock') { bg = PharmacyTheme.statOrangeBg; text = PharmacyTheme.statOrange; }
    else { bg = PharmacyTheme.statRedBg; text = PharmacyTheme.statRed; }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)), // Subtle shape
      child: Text(status, style: TextStyle(color: text, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}
