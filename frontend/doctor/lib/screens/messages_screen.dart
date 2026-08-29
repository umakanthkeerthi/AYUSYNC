import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'package:responsive_builder/responsive_builder.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, sizingInformation) {
        bool isMobile = sizingInformation.deviceScreenType == DeviceScreenType.mobile;
        
        return Container(
          margin: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: AppTheme.bgCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.borderColor),
          ),
          child: Row(
            children: [
              // Sidebar
              Container(
                width: isMobile ? MediaQuery.of(context).size.width - 50 : 300,
                decoration: const BoxDecoration(
                  border: Border(right: BorderSide(color: AppTheme.borderColor)),
                  color: AppTheme.brandBg,
                ),
                child: ListView.separated(
                  itemCount: 5,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    return ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: CircleAvatar(
                        backgroundColor: AppTheme.borderColor,
                        child: Icon(Icons.person, color: AppTheme.textSecondary),
                      ),
                      title: Text('Patient ${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: const Text('New symptom reported...'),
                      trailing: const Text('10:42 AM', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                      onTap: () {},
                    );
                  },
                ),
              ),
              // Chat Body
              if (!isMobile)
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: const BoxDecoration(
                          border: Border(bottom: BorderSide(color: AppTheme.borderColor)),
                        ),
                        child: const Row(
                          children: [
                            Text('Select a conversation', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.chat_bubble_outline, size: 64, color: AppTheme.textSecondary.withOpacity(0.5)),
                              const SizedBox(height: 16),
                              Text('Select a message thread from the left', style: TextStyle(color: AppTheme.textSecondary)),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                )
            ],
          ),
        );
      },
    );
  }
}
