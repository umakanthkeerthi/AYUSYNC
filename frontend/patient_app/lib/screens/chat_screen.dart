import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_markdown/flutter_markdown.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/patient_providers.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {
      'text': 'Hello Rahul! I am your AyuSync AI Assistant. How are you feeling today?',
      'isUser': false,
    }
  ];
  bool _isLoading = false;

  void _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;
    
    final userText = _controller.text;
    setState(() {
      _messages.add({'text': userText, 'isUser': true});
      _controller.clear();
      _isLoading = true;
    });

    final patientId = ref.read(authProvider).patientId;
    if (patientId == null) return;

    try {
      final repository = ref.read(patientRepositoryProvider);
      final responseText = await repository.sendChatMessage(patientId, userText);
      
      if (mounted) {
        setState(() {
          _isLoading = false;
          _messages.add({
            'text': responseText,
            'isUser': false,
          });
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _messages.add({
            'text': "Sorry, I am having trouble connecting to the medical network right now.",
            'isUser': false,
          });
        });
      }
    }
  }

  bool _isSaving = false;

  Future<void> _handleExit() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    
    // Show saving UI to user
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
            SizedBox(width: 16),
            Text('Your chat is saving in My Reports...'),
          ],
        ),
        duration: Duration(seconds: 2),
        backgroundColor: AppTheme.primaryOrange,
        behavior: SnackBarBehavior.floating,
      ),
    );
    
    final patientId = ref.read(authProvider).patientId;
    if (patientId != null) {
      ref.read(patientRepositoryProvider).summarizeChat(patientId);
      ref.read(completedTaskIdsProvider.notifier).update((state) => {...state, 'ai_checkin'});
    }
    
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleExit();
      },
      child: Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.85),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _handleExit,
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryOrange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(LucideIcons.bot, color: AppTheme.primaryOrange, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('AI Care Assistant', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text('Online', style: TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFF0E6), AppTheme.backgroundLight],
            stops: [0.0, 0.4],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 120),
                  itemCount: _messages.length + (_isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _messages.length) {
                      return _buildTypingIndicator();
                    }
                    final msg = _messages[index];
                    return _buildMessageBubble(msg['text'], msg['isUser'])
                        .animate()
                        .fadeIn(duration: 400.ms, curve: Curves.easeOut)
                        .slideY(begin: 0.2, curve: Curves.easeOut);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _buildFloatingInputArea(),
    ));
  }

  Widget _buildMessageBubble(String text, bool isUser) {
    if (isUser) {
      // User Message - Standard Chat Bubble
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(bottom: 16, left: 50),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [AppTheme.primaryOrange, Color(0xFFFF9B70)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(4),
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryOrange.withOpacity(0.25),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              height: 1.4,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    } else {
      // AI Message - ChatGPT Style (No container, just icon + markdown text)
      return Container(
        margin: const EdgeInsets.only(bottom: 24, right: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Icon(LucideIcons.bot, color: AppTheme.primaryOrange, size: 20),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: MarkdownBody(
                  data: text,
                  styleSheet: MarkdownStyleSheet(
                    p: const TextStyle(fontSize: 15, color: AppTheme.textDark, height: 1.5),
                    listBullet: const TextStyle(color: AppTheme.textDark, fontSize: 15),
                    strong: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
            bottomRight: Radius.circular(24),
            bottomLeft: Radius.circular(4),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('AI is thinking', style: TextStyle(color: AppTheme.textMuted, fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(width: 8),
            Icon(LucideIcons.loader, size: 14, color: AppTheme.primaryOrange)
                .animate(onPlay: (controller) => controller.repeat())
                .rotate(duration: 1.seconds),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.2);
  }

  Widget _buildFloatingInputArea() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(LucideIcons.plus, color: AppTheme.textMuted),
              onPressed: () {},
            ),
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: 'Type your message...',
                  hintStyle: TextStyle(color: AppTheme.textMuted, fontSize: 15),
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(6.0),
              child: GestureDetector(
                onTap: _sendMessage,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryOrange,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(LucideIcons.send, color: Colors.white, size: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
