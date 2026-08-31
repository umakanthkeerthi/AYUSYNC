import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'package:responsive_builder/responsive_builder.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, sizingInformation) {
        bool isMobile = sizingInformation.deviceScreenType == DeviceScreenType.mobile;
        
        return Scaffold(
          backgroundColor: AppTheme.brandBg,
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(isMobile),
                const SizedBox(height: 32),
                _buildStatCards(isMobile),
                const SizedBox(height: 32),
                const Text(
                  'Pending Authorizations',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                ),
                const SizedBox(height: 16),
                _buildDataTable(context, isMobile),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {},
                  child: const Text('View all authorizations →', style: TextStyle(color: AppTheme.brandActive, fontWeight: FontWeight.w600)),
                )
              ],
            ),
          ),
        );
      }
    );
  }

  Widget _buildHeader(bool isMobile) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 16,
      runSpacing: 16,
      children: [
        const Text('Claims & Authorization', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
        _buildSearchAndFilter(),
      ],
    );
  }

  Widget _buildSearchAndFilter() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 200,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.borderColor),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: const Row(
            children: [
              Expanded(child: Text('Search patient / ID', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13))),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.borderColor),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.filter_list, size: 16, color: AppTheme.textSecondary),
              SizedBox(width: 8),
              Text('All', style: TextStyle(color: AppTheme.textDark, fontSize: 13)),
              SizedBox(width: 8),
              Icon(Icons.keyboard_arrow_down, size: 16, color: AppTheme.textSecondary),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCards(bool isMobile) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth <= 0) return const SizedBox.shrink();
        
        // Subtract a slightly larger margin to prevent sub-pixel Wrap overflow crashes on Android
        double cardWidth = constraints.maxWidth < 600 
            ? ((constraints.maxWidth - 20) / 2).clamp(0.0, double.infinity)
            : ((constraints.maxWidth - 52) / 4).clamp(0.0, double.infinity);
            
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            SizedBox(
              width: cardWidth,
              height: 175,
              child: HoverStatCard(
                title: 'Pending',
                count: '12',
                bgColor: const Color(0xFFFFF4E5),
                iconColor: const Color(0xFFF59E0B),
                icon: Icons.assignment_late,
                imageAsset: 'assets/images/stat_pending.jpg',
              )
            ),
            SizedBox(
              width: cardWidth,
              height: 175,
              child: HoverStatCard(
                title: 'Approved',
                count: '38',
                bgColor: const Color(0xFFEBF4FF),
                iconColor: const Color(0xFF3B82F6),
                icon: Icons.science,
                imageAsset: 'assets/images/stat_approved.jpg',
              )
            ),
            SizedBox(
              width: cardWidth,
              height: 175,
              child: HoverStatCard(
                title: 'Rejected',
                count: '3',
                bgColor: const Color(0xFFF3E8FF),
                iconColor: const Color(0xFF8B5CF6),
                icon: Icons.refresh,
                imageAsset: 'assets/images/stat_rejected.jpg',
              )
            ),
            SizedBox(
              width: cardWidth,
              height: 175,
              child: HoverStatCard(
                title: 'Under Review',
                count: '2',
                bgColor: const Color(0xFFFFEBEB),
                iconColor: const Color(0xFFEF4444),
                icon: Icons.warning_amber_rounded,
                imageAsset: 'assets/images/stat_review.jpg',
              )
            ),
          ],
        );
      }
    );
  }

  Widget _buildDataTable(BuildContext context, bool isMobile) {
    final List<Map<String, String>> data = [
      {'patient': 'Rahul Kumar', 'procedure': 'MRI Scan', 'amount': '₹8,500', 'coverage': '80%', 'pay': '₹1,700'},
      {'patient': 'Priya Sharma', 'procedure': 'CT Scan', 'amount': '₹6,200', 'coverage': '80%', 'pay': '₹1,240'},
      {'patient': 'Arjun Rao', 'procedure': 'Physiotherapy', 'amount': '₹3,000', 'coverage': '60%', 'pay': '₹1,200'},
      {'patient': 'Meera Iyer', 'procedure': 'Echocardiogram', 'amount': '₹4,000', 'coverage': '80%', 'pay': '₹800'},
    ];

    if (MediaQuery.of(context).size.width < 800) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.borderColor),
        ),
        child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: data.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final item = data[index];
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(item['patient']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(item['amount']!, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.brandActive)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(item['procedure']!, style: const TextStyle(color: AppTheme.textSecondary)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Patient Pay', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                          Text(item['pay']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF3b82f6),
                          side: const BorderSide(color: Color(0xFFbfdbfe)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text('Review', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  )
                ],
              ),
            );
          },
        ),
      );
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width > 800 ? MediaQuery.of(context).size.width - 350 : 800),
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(Colors.grey[50]),
              dividerThickness: 1,
              columns: [
                DataColumn(label: _buildCellText('Patient', const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textSecondary), 140)),
                DataColumn(label: _buildCellText('Procedure', const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textSecondary), 140)),
                DataColumn(label: _buildCellText('Amount', const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textSecondary), 100)),
                DataColumn(label: _buildCellText('Coverage', const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textSecondary), 100)),
                DataColumn(label: _buildCellText('Patient Pay', const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textSecondary), 100)),
                DataColumn(label: _buildCellText('Action', const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textSecondary), 100)),
              ],
              rows: data.map((item) => _buildRow(item['patient']!, item['procedure']!, item['amount']!, item['coverage']!, item['pay']!)).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCellText(String text, TextStyle style, double width) {
    return SizedBox(
      width: width,
      child: Text(
        text, 
        style: style,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  DataRow _buildRow(String patient, String procedure, String amount, String coverage, String pay) {
    return DataRow(
      cells: [
        DataCell(_buildCellText(patient, const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textDark), 140)),
        DataCell(_buildCellText(procedure, const TextStyle(color: AppTheme.textSecondary), 140)),
        DataCell(_buildCellText(amount, const TextStyle(color: AppTheme.textDark), 100)),
        DataCell(_buildCellText(coverage, const TextStyle(color: AppTheme.textSecondary), 100)),
        DataCell(_buildCellText(pay, const TextStyle(color: AppTheme.textDark), 100)),
        DataCell(
          SizedBox(
            width: 100,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF3b82f6),
                side: const BorderSide(color: Color(0xFFbfdbfe)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('Review', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          ),
        ),
      ],
    );
  }
}

class HoverStatCard extends StatefulWidget {
  final String title;
  final String count;
  final Color bgColor;
  final Color iconColor;
  final IconData icon;
  final String imageAsset;

  const HoverStatCard({
    Key? key,
    required this.title,
    required this.count,
    required this.bgColor,
    required this.iconColor,
    required this.icon,
    required this.imageAsset,
  }) : super(key: key);

  @override
  State<HoverStatCard> createState() => _HoverStatCardState();
}

class _HoverStatCardState extends State<HoverStatCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          // Future: navigate to corresponding section
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutQuart,
          transformAlignment: Alignment.center,
          transform: Matrix4.identity()
            ..translate(0.0, _isHovered ? -8.0 : 0.0, 0.0)
            ..scale(_isHovered ? 1.02 : 1.00),
          decoration: BoxDecoration(
            color: widget.bgColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(0.9), // Ceramic/glass edge
              width: 1.5,
            ),
            boxShadow: [
              // Ambient base shadow
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
              // Animated colored glow on hover
              BoxShadow(
                color: _isHovered ? widget.iconColor.withOpacity(0.3) : widget.iconColor.withOpacity(0.0),
                blurRadius: _isHovered ? 24 : 0,
                offset: Offset(0, _isHovered ? 12 : 0),
                spreadRadius: _isHovered ? 2 : 0,
              )
            ],
          ),
          child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
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
                      widget.imageAsset,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              
              // Card Content
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Left Icon Box
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                        ]
                      ),
                      child: Icon(widget.icon, color: widget.iconColor, size: 24),
                    ),
                    const Spacer(),
                    // Title
                    Text(
                      widget.title,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark, height: 1.1),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Subtitle / Count
                    Row(
                      children: [
                        Text(
                          widget.count,
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: widget.iconColor),
                        ),
                        const SizedBox(width: 4),
                        const Text('records', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}
