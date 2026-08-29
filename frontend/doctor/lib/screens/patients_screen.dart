import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PatientsScreen extends StatelessWidget {
  const PatientsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('My Patients Directory', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Row(
                children: [
                  SizedBox(
                    width: 250,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search patients...',
                        prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppTheme.borderColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppTheme.borderColor),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.filter_list, size: 18),
                    label: const Text('Filters'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.textDark,
                      side: const BorderSide(color: AppTheme.borderColor),
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  )
                ],
              )
            ],
          ),
          const SizedBox(height: 24),
          Card(
            clipBehavior: Clip.antiAlias,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingTextStyle: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textSecondary),
                dataRowMinHeight: 60,
                dataRowMaxHeight: 60,
                columns: const [
                  DataColumn(label: Text('Patient')),
                  DataColumn(label: Text('Age')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Risk Score')),
                  DataColumn(label: Text('Action')),
                ],
                rows: [
                  _buildRow('Sarah Jenkins', '68', 'Need Intervention', 85, true),
                  _buildRow('Robert Chen', '72', 'Monitoring', 45, false),
                  _buildRow('Maria Garcia', '65', 'Stable', 12, false),
                  _buildRow('James Wilson', '81', 'Stable', 28, false),
                  _buildRow('Linda Brown', '59', 'Need Intervention', 75, true),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  DataRow _buildRow(String name, String age, String status, int score, bool isHighRisk) {
    Color statusColor;
    if (status == 'Stable') statusColor = AppTheme.colorSuccess;
    else if (status == 'Monitoring') statusColor = AppTheme.colorWarning;
    else statusColor = AppTheme.colorDanger;

    return DataRow(
      cells: [
        DataCell(
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppTheme.borderColor,
                child: const Icon(Icons.person, size: 20, color: AppTheme.textSecondary),
              ),
              const SizedBox(width: 12),
              Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        DataCell(Text(age)),
        DataCell(Text(status, style: TextStyle(color: statusColor, fontWeight: FontWeight.w500))),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(score.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
              if (isHighRisk) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: const Color(0xFFFEE2E2), borderRadius: BorderRadius.circular(12)),
                  child: const Text('High', style: TextStyle(color: AppTheme.colorDanger, fontSize: 10, fontWeight: FontWeight.bold)),
                )
              ]
            ],
          )
        ),
        DataCell(
          TextButton(
            onPressed: () {},
            child: const Text('View Profile'),
          )
        ),
      ],
    );
  }
}
