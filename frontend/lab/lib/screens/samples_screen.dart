import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SamplesScreen extends StatelessWidget {
  const SamplesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('All Samples', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppTheme.bgCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 1000),
                  child: DataTable(
                    columnSpacing: 24,
                    horizontalMargin: 24,
                  headingTextStyle: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textDark),
                  dataTextStyle: const TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
                  columns: const [
                    DataColumn(label: Text('Sample ID')),
                    DataColumn(label: Text('Patient')),
                    DataColumn(label: Text('Test')),
                    DataColumn(label: Text('Type')),
                    DataColumn(label: Text('Status')),
                    DataColumn(label: Text('Action')),
                  ],
                  rows: [
                    _createDataRow('SPL-10023', 'Emily Davis', 'Thyroid Profile', 'Blood', 'Collected', AppTheme.statBlue),
                    _createDataRow('SPL-10024', 'Michael Chen', 'Lipid Panel', 'Blood', 'Processing', AppTheme.statPurple),
                    _createDataRow('SPL-10025', 'Robert Wilson', 'Hemoglobin A1C', 'Blood', 'Completed', Colors.green),
                  ],
                ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  DataRow _createDataRow(String id, String patient, String test, String type, String status, Color statusColor) {
    return DataRow(
      cells: [
        DataCell(Text(id, style: const TextStyle(fontWeight: FontWeight.w600))),
        DataCell(Text(patient, style: const TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.w500))),
        DataCell(Text(test)),
        DataCell(Text(type)),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(status, style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.w600)),
          ),
        ),
        DataCell(
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              minimumSize: Size.zero,
            ),
            child: const Text('View Details', style: TextStyle(fontSize: 12)),
          ),
        ),
      ],
    );
  }
}
