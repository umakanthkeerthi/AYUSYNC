import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class LabScreen extends StatelessWidget {
  const LabScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Lab Coordination', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
                  DataColumn(label: Text('Test Type')),
                  DataColumn(label: Text('Date Ordered')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Action')),
                ],
                rows: [
                  _buildRow('Sarah Jenkins', 'Complete Blood Count', 'Oct 24, 08:30 AM', 'Pending', false),
                  _buildRow('Robert Chen', 'Lipid Panel', 'Oct 24, 09:15 AM', 'In Progress', false),
                  _buildRow('Maria Garcia', 'HbA1c', 'Oct 23, 14:20 PM', 'Completed', true),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  DataRow _buildRow(String name, String testType, String date, String status, bool isComplete) {
    Color statusColor;
    if (status == 'Completed') {
      statusColor = AppTheme.colorOnTrack;
    } else if (status == 'In Progress') {
      statusColor = AppTheme.colorTotal;
    } else {
      statusColor = AppTheme.colorFollowup;
    }

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
        DataCell(Text(testType)),
        DataCell(Text(date)),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(status, style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ),
        DataCell(
          isComplete 
            ? TextButton(onPressed: () {}, child: const Text('View Results'))
            : OutlinedButton(onPressed: () {}, child: const Text('Follow Up'))
        ),
      ],
    );
  }
}
