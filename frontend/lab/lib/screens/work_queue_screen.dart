import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import '../theme/app_theme.dart';

class WorkQueueScreen extends StatelessWidget {
  const WorkQueueScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatsGrid(),
            const SizedBox(height: 32),
            _buildScheduleHeader(),
            const SizedBox(height: 16),
            _buildDataList(context),
            const SizedBox(height: 32),
            _buildAlertBanner(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isTabletOrMobile = constraints.maxWidth < 900;
        
        if (isTabletOrMobile) {
          return const Column(
            children: [
              Row(
                children: [
                  Expanded(child: _StatCard(label: 'Pending', value: '12', color: AppTheme.statOrange, icon: Icons.pending_actions, imagePath: 'assets/images/pending.jpg')),
                  SizedBox(width: 16),
                  Expanded(child: _StatCard(label: 'Collected', value: '8', color: AppTheme.statBlue, icon: Icons.science_outlined, imagePath: 'assets/images/collected.jpg')),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _StatCard(label: 'Processing', value: '15', color: AppTheme.statPurple, icon: Icons.sync, imagePath: 'assets/images/processing.jpg')),
                  SizedBox(width: 16),
                  Expanded(child: _StatCard(label: 'Critical', value: '3', color: AppTheme.statRed, subLabel: 'Need Review', icon: Icons.warning_amber_rounded, imagePath: 'assets/images/critical.jpg')),
                ],
              ),
            ],
          );
        }

        return const Row(
          children: [
            Expanded(child: _StatCard(label: 'Pending', value: '12', color: AppTheme.statOrange, icon: Icons.pending_actions, imagePath: 'assets/images/pending.jpg')),
            SizedBox(width: 16),
            Expanded(child: _StatCard(label: 'Collected', value: '8', color: AppTheme.statBlue, icon: Icons.science_outlined, imagePath: 'assets/images/collected.jpg')),
            SizedBox(width: 16),
            Expanded(child: _StatCard(label: 'Processing', value: '15', color: AppTheme.statPurple, icon: Icons.sync, imagePath: 'assets/images/processing.jpg')),
            SizedBox(width: 16),
            Expanded(child: _StatCard(label: 'Critical', value: '3', color: AppTheme.statRed, subLabel: 'Need Review', icon: Icons.warning_amber_rounded, imagePath: 'assets/images/critical.jpg')),
          ],
        );
      },
    );
  }

  Widget _buildScheduleHeader() {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 16,
      runSpacing: 16,
      children: [
        const Text("Today's Schedule", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const Text('Showing all records', style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.filter_alt_outlined, size: 18),
              label: const Text('Filter'),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildDataList(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: ResponsiveBuilder(
        builder: (context, sizingInformation) {
          if (sizingInformation.isMobile) {
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 4,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) => _buildMobileListItem(index),
            );
          }
          return _buildDesktopTable();
        },
      ),
    );
  }

  Widget _buildDesktopTable() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: constraints.maxWidth > 1000 ? constraints.maxWidth : 1000,
            ),
            child: DataTable(
              columnSpacing: 24,
              horizontalMargin: 24,
              headingTextStyle: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textDark),
              dataTextStyle: const TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
              columns: const [
                DataColumn(label: Text('Patient')),
                DataColumn(label: Text('Test')),
                DataColumn(label: Text('Collection Time')),
                DataColumn(label: Text('Urgency')),
                DataColumn(label: Text('Risk Score')),
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('Action')),
              ],
              rows: [
                _createDataRow('Sarah Jenkins', 'Complete Blood Count', '09:00 AM', 'Routine', '25', 'Pending', AppTheme.statOrange),
                _createDataRow('Michael Chen', 'Lipid Panel', '09:15 AM', 'Urgent', '80', 'Processing', AppTheme.statPurple),
                _createDataRow('Emily Davis', 'Thyroid Profile', '09:30 AM', 'Routine', '45', 'Collected', AppTheme.statBlue),
                _createDataRow('Robert Wilson', 'Hemoglobin A1C', '10:00 AM', 'Priority', '65', 'Critical', AppTheme.statRed),
              ],
            ),
          ),
        );
      }
    );
  }

  DataRow _createDataRow(String patient, String test, String time, String urgency, String risk, String status, Color statusColor) {
    return DataRow(
      cells: [
        DataCell(Text(patient, style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textDark))),
        DataCell(Text(test)),
        DataCell(Text(time)),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: urgency == 'Urgent' ? AppTheme.statRed.withOpacity(0.1) : AppTheme.brandBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(urgency, style: TextStyle(color: urgency == 'Urgent' ? AppTheme.statRed : AppTheme.textSecondary, fontSize: 12)),
          ),
        ),
        DataCell(Text(risk)),
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
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.brandBg,
              foregroundColor: AppTheme.brandActive,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              elevation: 0,
              side: const BorderSide(color: AppTheme.borderColor),
            ),
            child: Text(status == 'Pending' ? 'Collect' : (status == 'Critical' ? 'Review' : 'Enter Results'), style: const TextStyle(fontSize: 12)),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileListItem(int index) {
    final data = [
      {'patient': 'Sarah Jenkins', 'test': 'CBC', 'time': '09:00 AM', 'status': 'Pending', 'color': AppTheme.statOrange},
      {'patient': 'Michael Chen', 'test': 'Lipid Panel', 'time': '09:15 AM', 'status': 'Processing', 'color': AppTheme.statPurple},
      {'patient': 'Emily Davis', 'test': 'Thyroid Profile', 'time': '09:30 AM', 'status': 'Collected', 'color': AppTheme.statBlue},
      {'patient': 'Robert Wilson', 'test': 'HbA1C', 'time': '10:00 AM', 'status': 'Critical', 'color': AppTheme.statRed},
    ][index];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(data['patient'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (data['color'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(data['status'] as String, style: TextStyle(color: data['color'] as Color, fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(data['test'] as String, style: const TextStyle(color: AppTheme.textSecondary)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.schedule, size: 14, color: AppTheme.textSecondary),
                  const SizedBox(width: 4),
                  Text(data['time'] as String, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                ],
              ),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  minimumSize: Size.zero,
                ),
                child: Text(data['status'] == 'Pending' ? 'Collect' : (data['status'] == 'Critical' ? 'Review' : 'Enter Results'), style: const TextStyle(fontSize: 12, color: AppTheme.brandActive)),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildAlertBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.statRed.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.statRed.withOpacity(0.2)),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 16,
        runSpacing: 16,
        children: [
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            children: [
              const Icon(Icons.warning_amber_rounded, color: AppTheme.statRed),
              const Text('3 results require immediate review', style: TextStyle(color: AppTheme.statRed, fontWeight: FontWeight.bold)),
            ],
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.statRed,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text('View Now', style: TextStyle(fontSize: 12)),
          )
        ],
      ),
    );
  }
}

class _StatCard extends StatefulWidget {
  final String label;
  final String value;
  final Color color;
  final String? subLabel;
  final IconData icon;
  final String imagePath;

  const _StatCard({Key? key, required this.label, required this.value, required this.color, required this.icon, required this.imagePath, this.subLabel}) : super(key: key);

  @override
  State<_StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<_StatCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {},
        child: AnimatedContainer(
          height: 140,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutQuart,
          transformAlignment: Alignment.center,
          transform: Matrix4.identity()
            ..translate(0.0, _isHovered ? -5.0 : 0.0, 0.0)
            ..scale(_isHovered ? 1.02 : 1.00),
          decoration: BoxDecoration(
            color: widget.color.withOpacity(0.08), // Premium tinted background
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(0.9), // Ceramic/glass edge
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: _isHovered ? widget.color.withOpacity(0.2) : widget.color.withOpacity(0.0),
                blurRadius: _isHovered ? 20 : 0,
                offset: Offset(0, _isHovered ? 10 : 0),
                spreadRadius: _isHovered ? 2 : 0,
              )
            ],
          ),
          clipBehavior: Clip.hardEdge,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Bottom Right 3D Image
              Positioned(
                right: -10,
                bottom: -20,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.white.withOpacity(0.5), blurRadius: 20, spreadRadius: 10)],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      widget.imagePath,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              
              // Content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                            ]
                          ),
                          child: Icon(widget.icon, color: widget.color, size: 24),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.label, 
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark, height: 1.1),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(widget.value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: widget.color)),
                            const SizedBox(width: 4),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 2),
                              child: Text(widget.subLabel ?? 'records', style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
