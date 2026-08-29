import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../utils/theme.dart';

class ChatTab extends StatelessWidget {
  const ChatTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        Expanded(
          child: Container(
            color: AyuTheme.bgApp,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              children: [
                _buildDateSeparator('Today'),
                const SizedBox(height: 16),
                _buildChatBubble(
                  message: 'Good morning! How are you feeling today?',
                  time: '08:00 AM',
                  isMe: true,
                ),
                const SizedBox(height: 16),
                _buildChatBubble(
                  message: 'Hi, I finished my morning walk. Heart rate felt normal.',
                  time: '08:15 AM',
                  isMe: false,
                  avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=150&q=80',
                ),
                const SizedBox(height: 16),
                _buildChatBubble(
                  message: 'That is great to hear! Remember to take your morning medication.',
                  time: '08:17 AM',
                  isMe: true,
                ),
                const SizedBox(height: 32),
                _buildAlertBubble(
                  title: 'System Alert',
                  message: 'Patient logged medication intake.',
                  time: '08:20 AM',
                ),
              ],
            ),
          ),
        ),
        _buildInputArea(),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.only(top: 24, left: 24, right: 24, bottom: 24),
      decoration: const BoxDecoration(
        color: AyuTheme.surface,
        boxShadow: [BoxShadow(color: Color(0x05000000), blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Messages',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              fontFamily: 'Outfit',
              color: AyuTheme.textMain,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AyuTheme.bgApp,
              shape: BoxShape.circle,
            ),
            child: const Icon(LucideIcons.search, size: 20, color: AyuTheme.textMuted),
          )
        ],
      ),
    );
  }

  Widget _buildDateSeparator(String text) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: AyuTheme.border,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AyuTheme.textMuted),
        ),
      ),
    );
  }

  Widget _buildChatBubble({required String message, required String time, required bool isMe, String? avatarUrl}) {
    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (!isMe && avatarUrl != null) ...[
          CircleAvatar(radius: 16, backgroundImage: NetworkImage(avatarUrl)),
          const SizedBox(width: 8),
        ],
        if (!isMe && avatarUrl == null) const SizedBox(width: 40),
        
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              gradient: isMe ? AyuTheme.primaryGradient : null,
              color: isMe ? null : AyuTheme.surface,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(24),
                topRight: const Radius.circular(24),
                bottomLeft: Radius.circular(isMe ? 24 : 4),
                bottomRight: Radius.circular(isMe ? 4 : 24),
              ),
              boxShadow: AyuTheme.softShadow,
            ),
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: TextStyle(
                    color: isMe ? Colors.white : AyuTheme.textMain,
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(
                    color: isMe ? Colors.white70 : AyuTheme.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (isMe) const SizedBox(width: 8) else const SizedBox(width: 40),
      ],
    );
  }

  Widget _buildAlertBubble({required String title, required String message, required String time}) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AyuTheme.greenBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AyuTheme.green.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.bell, color: AyuTheme.green, size: 20),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AyuTheme.green, fontSize: 13)),
                Text(message, style: const TextStyle(color: AyuTheme.textMain, fontSize: 13)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      color: Colors.transparent,
      child: SafeArea(
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AyuTheme.surface,
                shape: BoxShape.circle,
                boxShadow: AyuTheme.floatingIconShadow,
              ),
              child: const Icon(LucideIcons.plus, color: AyuTheme.textMuted, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: AyuTheme.bgApp,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AyuTheme.border.withOpacity(0.5)),
                ),
                child: const Text('Type a message...', style: TextStyle(color: AyuTheme.textMuted, fontSize: 15)),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: const BoxDecoration(
                gradient: AyuTheme.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: AyuTheme.primaryFloatingShadow,
              ),
              child: const Icon(LucideIcons.send, color: Colors.white, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}
