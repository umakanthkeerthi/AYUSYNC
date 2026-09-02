import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../theme/app_theme.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({Key? key}) : super(key: key);

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  List<dynamic> _threads = [];
  bool _isLoadingThreads = true;
  String _errorMessage = '';

  String? _selectedThreadId;
  String? _selectedPatientName;
  List<dynamic> _activeMessages = [];
  bool _isLoadingMessages = false;
  
  final TextEditingController _msgController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchThreads();
  }

  Future<void> _fetchThreads() async {
    try {
      final response = await http.get(Uri.parse('http://127.0.0.1:8001/api/v1/nurse/messages'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _threads = data['messages'] ?? [];
          _isLoadingThreads = false;
        });
        if (_threads.isNotEmpty && _selectedThreadId == null) {
          _selectThread(_threads[0]['thread_id'], _threads[0]['sender_name']);
        }
      } else {
        setState(() {
          _errorMessage = 'Failed to load threads';
          _isLoadingThreads = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Network error: $e';
        _isLoadingThreads = false;
      });
    }
  }

  Future<void> _selectThread(String threadId, String patientName) async {
    setState(() {
      _selectedThreadId = threadId;
      _selectedPatientName = patientName;
      _isLoadingMessages = true;
    });

    try {
      final response = await http.get(Uri.parse('http://127.0.0.1:8001/api/v1/nurse/messages/$threadId'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _activeMessages = data['messages'] ?? [];
          _isLoadingMessages = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingMessages = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingThreads) return Center(child: CircularProgressIndicator());
    if (_errorMessage.isNotEmpty) return Center(child: Text(_errorMessage, style: TextStyle(color: Colors.red)));

    return Row(
      children: [
        // Left Panel: Threads List
        Container(
          width: 350,
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(right: BorderSide(color: AppTheme.borderColor)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Conversations', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    IconButton(icon: Icon(Icons.refresh), onPressed: _fetchThreads),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  itemCount: _threads.length,
                  itemBuilder: (context, index) {
                    final thread = _threads[index];
                    final isSelected = thread['thread_id'] == _selectedThreadId;
                    
                    return InkWell(
                      onTap: () => _selectThread(thread['thread_id'], thread['sender_name']),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.brandPrimary.withOpacity(0.05) : Colors.transparent,
                          border: Border(left: BorderSide(color: isSelected ? AppTheme.brandPrimary : Colors.transparent, width: 4)),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: AppTheme.brandPrimary.withOpacity(0.1),
                              child: Text(thread['sender_name'][0], style: TextStyle(color: AppTheme.brandPrimary, fontWeight: FontWeight.bold)),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(thread['sender_name'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                      Text(thread['time'], style: TextStyle(color: Theme.of(context).hintColor, fontSize: 12)),
                                    ],
                                  ),
                                  SizedBox(height: 4),
                                  Text(thread['message'], maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Theme.of(context).hintColor)),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
              )
            ],
          ),
        ),
        
        // Right Panel: Chat Area
        Expanded(
          child: _selectedThreadId == null 
            ? Center(child: Text('Select a conversation to view', style: TextStyle(color: Theme.of(context).hintColor)))
            : Column(
                children: [
                  // Chat Header
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      border: Border(bottom: BorderSide(color: AppTheme.borderColor)),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppTheme.brandPrimary.withOpacity(0.1),
                          child: Text(_selectedPatientName![0], style: TextStyle(color: AppTheme.brandPrimary, fontWeight: FontWeight.bold)),
                        ),
                        SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_selectedPatientName!, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            Text('Active Patient', style: TextStyle(color: AppTheme.colorOnTrack, fontSize: 12)),
                          ],
                        ),
                        const Spacer(),
                        IconButton(icon: Icon(Icons.more_vert), onPressed: () {})
                      ],
                    ),
                  ),
                  
                  // Messages List
                  Expanded(
                    child: Container(
                      color: const Color(0xFFF8FAFC),
                      child: _isLoadingMessages
                        ? Center(child: CircularProgressIndicator())
                        : ListView.builder(
                            padding: const EdgeInsets.all(24),
                            itemCount: _activeMessages.length,
                            itemBuilder: (context, index) {
                              final msg = _activeMessages[index];
                              // Hardcode logic for demo: Nurse Clara is NURSE.
                              final isNurse = msg['sender_role'] == 'NURSE';
                              
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: Row(
                                  mainAxisAlignment: isNurse ? MainAxisAlignment.end : MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    if (!isNurse) ...[
                                      CircleAvatar(
                                        radius: 16,
                                        backgroundColor: AppTheme.brandPrimary.withOpacity(0.1),
                                        child: Text(msg['sender_name'][0], style: TextStyle(color: AppTheme.brandPrimary, fontSize: 12)),
                                      ),
                                      SizedBox(width: 8),
                                    ],
                                    Flexible(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                        decoration: BoxDecoration(
                                          color: isNurse ? AppTheme.brandPrimary : Colors.white,
                                          borderRadius: BorderRadius.only(
                                            topLeft: const Radius.circular(16),
                                            topRight: const Radius.circular(16),
                                            bottomLeft: Radius.circular(isNurse ? 16 : 0),
                                            bottomRight: Radius.circular(isNurse ? 0 : 16),
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.05),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            )
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment: isNurse ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              msg['message'],
                                              style: TextStyle(
                                                color: isNurse ? Colors.white : AppTheme.textDark,
                                                fontSize: 15,
                                                height: 1.4,
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              msg['time'],
                                              style: TextStyle(
                                                color: isNurse ? Colors.white.withOpacity(0.7) : Theme.of(context).hintColor,
                                                fontSize: 10,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                    ),
                  ),
                  
                  // Message Input
                  Container(
                    padding: const EdgeInsets.all(24),
                    color: Colors.white,
                    child: Row(
                      children: [
                        IconButton(icon: Icon(Icons.attach_file, color: Theme.of(context).hintColor), onPressed: () {}),
                        SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _msgController,
                            decoration: InputDecoration(
                              hintText: 'Type a message...',
                              hintStyle: TextStyle(color: Theme.of(context).hintColor),
                              filled: true,
                              fillColor: Theme.of(context).scaffoldBackgroundColor,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: AppTheme.brandPrimary,
                          child: IconButton(
                            icon: Icon(Icons.send, color: Colors.white, size: 20),
                            onPressed: () {
                               // Handle send (not required for static demo)
                               _msgController.clear();
                            },
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
        )
      ],
    );
  }
}
