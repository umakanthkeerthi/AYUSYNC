import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';
import 'package:responsive_builder/responsive_builder.dart';

class MessagesScreen extends ConsumerStatefulWidget {
  const MessagesScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends ConsumerState<MessagesScreen> {
  List<dynamic> _patients = [];
  bool _isLoading = true;
  dynamic _selectedPatient;
  
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  // Dummy messages store for frontend showcase
  final Map<String, List<Map<String, dynamic>>> _chatHistory = {};

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _fetchPatients());
  }

  Future<void> _fetchPatients() async {
    final doctorId = ref.read(authProvider).doctorId;
    if (doctorId == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('http://16.171.226.51/api/v1/doctor/roster?doctor_id=$doctorId'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            _patients = data['roster'];
            _isLoading = false;
            
            // Generate some dummy messages for each patient
            for (var p in _patients) {
              _chatHistory[p['patient_id']] = [
                {"sender": "patient", "text": "Hello doctor, my heart rate has been slightly elevated today.", "time": "10:30 AM"},
                {"sender": "doctor", "text": "Hi ${p['name']}. Have you been taking your medication as prescribed?", "time": "10:35 AM"},
                {"sender": "patient", "text": "Yes, I took it this morning. I will keep monitoring it.", "time": "10:42 AM"},
              ];
            }
          });
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty || _selectedPatient == null) return;
    
    setState(() {
      _chatHistory[_selectedPatient['patient_id']]!.add({
        "sender": "doctor",
        "text": _messageController.text,
        "time": "Just now",
      });
      _messageController.clear();
    });
    
    // Scroll to bottom
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

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
                width: isMobile ? (MediaQuery.of(context).size.width - 50) : 320,
                decoration: const BoxDecoration(
                  border: Border(right: BorderSide(color: AppTheme.borderColor)),
                  color: AppTheme.brandBg,
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        border: Border(bottom: BorderSide(color: AppTheme.borderColor)),
                      ),
                      child: const Row(
                        children: [
                          Text('Recent Conversations', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: _patients.isEmpty
                          ? const Center(child: Text("No patients assigned.", style: TextStyle(color: AppTheme.textSecondary)))
                          : ListView.separated(
                              itemCount: _patients.length,
                              separatorBuilder: (_, __) => const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final p = _patients[index];
                                final isSelected = _selectedPatient != null && _selectedPatient['patient_id'] == p['patient_id'];
                                return ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  tileColor: isSelected ? AppTheme.brandActive.withOpacity(0.05) : null,
                                  leading: const CircleAvatar(
                                    backgroundColor: AppTheme.borderColor,
                                    child: Icon(Icons.person, color: AppTheme.textSecondary),
                                  ),
                                  title: Text(p['name'] ?? 'Unknown', style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.w600)),
                                  subtitle: const Text('Recent updates...'),
                                  trailing: const Text('10:42 AM', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                                  onTap: () {
                                    setState(() {
                                      _selectedPatient = p;
                                    });
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
              // Chat Body
              if (!isMobile)
                Expanded(
                  child: _selectedPatient == null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.chat_bubble_outline, size: 64, color: AppTheme.textSecondary.withOpacity(0.5)),
                              const SizedBox(height: 16),
                              const Text('Select a message thread from the left', style: TextStyle(color: AppTheme.textSecondary)),
                            ],
                          ),
                        )
                      : Column(
                          children: [
                            // Chat Header
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                              decoration: const BoxDecoration(
                                border: Border(bottom: BorderSide(color: AppTheme.borderColor)),
                                color: Colors.white,
                              ),
                              child: Row(
                                children: [
                                  const CircleAvatar(
                                    backgroundColor: AppTheme.borderColor,
                                    child: Icon(Icons.person, color: AppTheme.textSecondary),
                                  ),
                                  const SizedBox(width: 16),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(_selectedPatient['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                      Text(_selectedPatient['isHighRisk'] ? 'High Risk' : 'Stable', style: TextStyle(color: _selectedPatient['isHighRisk'] ? AppTheme.colorDanger : AppTheme.colorSuccess, fontSize: 12)),
                                    ],
                                  ),
                                  const Spacer(),
                                  IconButton(icon: const Icon(Icons.phone), onPressed: () {}),
                                  IconButton(icon: const Icon(Icons.videocam), onPressed: () {}),
                                ],
                              ),
                            ),
                            // Messages List
                            Expanded(
                              child: Container(
                                color: const Color(0xFFFAFAFA),
                                child: ListView.builder(
                                  controller: _scrollController,
                                  padding: const EdgeInsets.all(24),
                                  itemCount: _chatHistory[_selectedPatient['patient_id']]?.length ?? 0,
                                  itemBuilder: (context, index) {
                                    final msg = _chatHistory[_selectedPatient['patient_id']]![index];
                                    final isMe = msg['sender'] == 'doctor';
                                    
                                    return Align(
                                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                                      child: Container(
                                        margin: const EdgeInsets.only(bottom: 16),
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.4),
                                        decoration: BoxDecoration(
                                          color: isMe ? AppTheme.brandActive : Colors.white,
                                          borderRadius: BorderRadius.only(
                                            topLeft: const Radius.circular(16),
                                            topRight: const Radius.circular(16),
                                            bottomLeft: Radius.circular(isMe ? 16 : 0),
                                            bottomRight: Radius.circular(isMe ? 0 : 16),
                                          ),
                                          boxShadow: [
                                            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))
                                          ],
                                          border: isMe ? null : Border.all(color: AppTheme.borderColor),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              msg['text'],
                                              style: TextStyle(color: isMe ? Colors.white : AppTheme.textDark, fontSize: 14),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              msg['time'],
                                              style: TextStyle(color: isMe ? Colors.white.withOpacity(0.7) : AppTheme.textSecondary, fontSize: 10),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            // Input Area
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                              decoration: const BoxDecoration(
                                border: Border(top: BorderSide(color: AppTheme.borderColor)),
                                color: Colors.white,
                              ),
                              child: Row(
                                children: [
                                  IconButton(icon: const Icon(Icons.attach_file, color: AppTheme.textSecondary), onPressed: () {}),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextField(
                                      controller: _messageController,
                                      onSubmitted: (_) => _sendMessage(),
                                      decoration: InputDecoration(
                                        hintText: 'Type your message...',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(30),
                                          borderSide: BorderSide.none,
                                        ),
                                        filled: true,
                                        fillColor: const Color(0xFFF3F4F6),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  CircleAvatar(
                                    backgroundColor: AppTheme.brandActive,
                                    child: IconButton(
                                      icon: const Icon(Icons.send, color: Colors.white, size: 18),
                                      onPressed: _sendMessage,
                                    ),
                                  ),
                                ],
                              ),
                            ),
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
