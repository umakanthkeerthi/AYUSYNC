import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../utils/theme.dart';
import 'dart:ui';
import 'package:flutter_animate/flutter_animate.dart';
import '../widgets/glass_card.dart';

class ChatTab extends StatelessWidget {
  const ChatTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF0FDFA), AyuTheme.bgApp],
          stops: [0.0, 0.3],
        ),
      ),
      child: Stack(
        children: [
          // Messages List
          Positioned.fill(
            child: ListView(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 100, bottom: 100),
              children: [
                _buildDateSeparator('Today').animate().fadeIn(duration: 400.ms),
                const SizedBox(height: 16),
                _buildChatBubble(
                  message: 'Good morning! How are you feeling today?',
                  time: '08:00 AM',
                  isMe: true,
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
                const SizedBox(height: 16),
                _buildChatBubble(
                  message: 'Hi, I finished my morning walk. Heart rate felt normal.',
                  time: '08:15 AM',
                  isMe: false,
                  avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=150&q=80',
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
                const SizedBox(height: 16),
                _buildChatBubble(
                  message: 'That is great to hear! Remember to take your morning medication.',
                  time: '08:17 AM',
                  isMe: true,
                ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1),
                const SizedBox(height: 32),
                _buildAlertBubble(
                  title: 'System Alert',
                  message: 'Patient logged medication intake.',
                  time: '08:20 AM',
                ).animate().fadeIn(delay: 800.ms).slideX(begin: 0.1),
              ],
            ),
          ),
          
          // Frosted App Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.only(top: 24, left: 24, right: 24, bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    border: Border(
                      bottom: BorderSide(color: Colors.white.withOpacity(0.5), width: 1.5),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(LucideIcons.arrowLeft, color: AyuTheme.textMain),
                            onPressed: () => Navigator.pop(context),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Messages',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: AyuTheme.textMain,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: AyuTheme.floatingIconShadow,
                        ),
                        child: const Icon(LucideIcons.search, size: 17, color: AyuTheme.textMuted),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ).animate().slideY(begin: -1, duration: 400.ms),

          // Floating Glassmorphic Input
          Positioned(
            bottom: 24, // Positioned at the bottom
            left: 20,
            right: 20,
            child: SafeArea(
              bottom: true,
              child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white, width: 1.5),
                    boxShadow: AyuTheme.softShadow,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          color: AyuTheme.bgApp,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(LucideIcons.plus, color: AyuTheme.textMuted, size: 17),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Type a message...',
                            hintStyle: TextStyle(color: AyuTheme.textMuted, fontSize: 13),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          gradient: AyuTheme.primaryGradient,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(LucideIcons.send, color: Colors.white, size: 17),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            ),
          ).animate().slideY(begin: 1, delay: 200.ms, duration: 400.ms),
        ],
      ),
      ),
    );
  }

  Widget _buildDateSeparator(String text) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: AyuTheme.surface.withOpacity(0.5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AyuTheme.textMuted),
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
              boxShadow: isMe ? AyuTheme.primaryFloatingShadow : [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: TextStyle(
                    color: isMe ? Colors.white : AyuTheme.textMain,
                    fontSize: 13,
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
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AyuTheme.green.withOpacity(0.3)),
          boxShadow: [BoxShadow(color: AyuTheme.green.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AyuTheme.green.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(LucideIcons.bell, color: AyuTheme.green, size: 17),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AyuTheme.green, fontSize: 12)),
                Text(message, style: const TextStyle(color: AyuTheme.textMain, fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
