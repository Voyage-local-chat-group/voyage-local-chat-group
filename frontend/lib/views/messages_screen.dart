import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../palette.dart';
import '../main.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _chatrooms = [];
  Timer? _pollTimer;
  String? _token;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAndPoll();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadAndPoll() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('jwt_token');
    await _fetchChatrooms();
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _fetchChatrooms();
    });
  }

  Future<void> _fetchChatrooms() async {
    if (_token == null) return;
    try {
      final resp = await http.get(
        Uri.parse('$backendURL/chatrooms/mine'),
        headers: {'Authorization': 'Bearer $_token'},
      );
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        if (data['success'] == true && mounted) {
          setState(() {
            _chatrooms = List<Map<String, dynamic>>.from(data['data']);
          });
        }
      }
    } catch (_) {}
  }

  void _openUserSearch() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _UserSearchSheet(
        token: _token ?? '',
        onChatroomReady: (chatroomId, displayName) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatScreen(
                chatroomId: chatroomId,
                displayName: displayName,
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Direct Messages'),
            Tab(text: 'Groups'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openUserSearch,
        backgroundColor: primaryColour,
        child: const Icon(Icons.edit, color: Colors.white),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _ChatroomList(
            chatrooms: _chatrooms.where((c) => c['type'] == 'dm').toList(),
            token: _token ?? '',
          ),
          _ChatroomList(
            chatrooms: _chatrooms.where((c) => c['type'] != 'dm').toList(),
            token: _token ?? '',
          ),
        ],
      ),
    );
  }
}

class _ChatroomList extends StatelessWidget {
  final List<Map<String, dynamic>> chatrooms;
  final String token;

  const _ChatroomList({required this.chatrooms, required this.token});

  @override
  Widget build(BuildContext context) {
    if (chatrooms.isEmpty) {
      return const Center(
        child: Text('No conversations yet.\nTap ✏️ to start one.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey)),
      );
    }
    return ListView.separated(
      itemCount: chatrooms.length,
      separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
      itemBuilder: (context, i) {
        final room = chatrooms[i];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: primaryColour.withOpacity(0.15),
            child: Text(
              (room['display_name'] ?? '?')[0].toUpperCase(),
              style: TextStyle(color: primaryColour),
            ),
          ),
          title: Text(room['display_name'] ?? 'Chat',
              style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(room['last_message'] ?? '',
              maxLines: 1, overflow: TextOverflow.ellipsis),
          trailing: room['last_time'] != null
              ? Text(room['last_time'],
                  style: const TextStyle(fontSize: 11, color: Colors.grey))
              : null,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatScreen(
                  chatroomId: room['chatroom_id'].toString(),
                  displayName: room['display_name'] ?? 'Chat',
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _UserSearchSheet extends StatefulWidget {
  final String token;
  final void Function(String chatroomId, String displayName) onChatroomReady;

  const _UserSearchSheet({
    required this.token,
    required this.onChatroomReady,
  });

  @override
  State<_UserSearchSheet> createState() => _UserSearchSheetState();
}

class _UserSearchSheetState extends State<_UserSearchSheet> {
  final TextEditingController _searchCtrl = TextEditingController();
  List<Map<String, dynamic>> _results = [];
  bool _loading = false;
  bool _opening = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _search(String q) async {
    if (q.trim().isEmpty) {
      setState(() => _results = []);
      return;
    }
    setState(() => _loading = true);
    try {
      final resp = await http.get(
        Uri.parse('$backendURL/users/search?q=${Uri.encodeComponent(q)}'),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );
      if (resp.statusCode == 200 && mounted) {
        final data = jsonDecode(resp.body);
        setState(() {
          _results = List<Map<String, dynamic>>.from(data['data'] ?? []);
        });
      }
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _openDm(Map<String, dynamic> user) async {
    if (_opening) return;
    setState(() => _opening = true);
    try {
      final resp = await http.post(
        Uri.parse('$backendURL/chatrooms/dm'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'user_id': user['user_id']}),
      );
      if (resp.statusCode == 200 || resp.statusCode == 201) {
        final data = jsonDecode(resp.body);
        final chatroomId = data['data']['chatroom_id'].toString();
        final displayName = user['username'] as String;
        if (mounted) {
          Navigator.of(context).pop();
          widget.onChatroomReady(chatroomId, displayName);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open chat. Try again.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
    if (mounted) setState(() => _opening = false);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollCtrl) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Text('New Message',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _searchCtrl,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Search by username...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: offWhite,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: _search,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        controller: scrollCtrl,
                        itemCount: _results.length,
                        itemBuilder: (_, i) {
                          final user = _results[i];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: primaryColour.withOpacity(0.15),
                              child: Text(
                                (user['username'] ?? '?')[0].toUpperCase(),
                                style: TextStyle(color: primaryColour),
                              ),
                            ),
                            title: Text(user['username'] ?? ''),
                            onTap: () => _openDm(user),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class ChatScreen extends StatefulWidget {
  final String chatroomId;
  final String displayName;

  const ChatScreen({
    super.key,
    required this.chatroomId,
    required this.displayName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _msgCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  List<Map<String, dynamic>> _messages = [];
  Timer? _pollTimer;
  String? _token;
  String? _myUsername;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _loadAndPoll();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadAndPoll() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('jwt_token');
    _myUsername = prefs.getString('username');
    await _fetchMessages();
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _fetchMessages();
    });
  }

  Future<void> _fetchMessages() async {
    if (_token == null) return;
    try {
      final resp = await http.get(
        Uri.parse('$backendURL/chatrooms/${widget.chatroomId}/messages'),
        headers: {'Authorization': 'Bearer $_token'},
      );
      if (resp.statusCode == 200 && mounted) {
        final data = jsonDecode(resp.body);
        final msgs = List<Map<String, dynamic>>.from(data is List ? data : (data['data'] ?? []));
                setState(() {
          _messages = msgs;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollCtrl.hasClients) {
            _scrollCtrl.jumpTo(_scrollCtrl.position.maxScrollExtent);
          }
        });
      }
    } catch (_) {}
  }

  Future<void> _sendMessage() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty || _sending || _token == null) return;
    setState(() => _sending = true);
    _msgCtrl.clear();
    try {
      await http.post(
        Uri.parse('$backendURL/chatrooms/${widget.chatroomId}/messages'),
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'content': text}),
      );
      await _fetchMessages();
    } catch (_) {}
    if (mounted) setState(() => _sending = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.displayName)),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? const Center(
                    child: Text('No messages yet. Say hello! 👋',
                        style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 20),
                    itemCount: _messages.length,
                    itemBuilder: (_, i) {
                      final msg = _messages[i];
                      final isMe = msg['sender_username'] == _myUsername;
                      return _MessageBubble(
                        text: msg['content'] ?? '',
                        isMe: isMe,
                        senderName: msg['sender_username'] ?? '',
                      );
                    },
                  ),
          ),
          _buildInput(),
        ],
      ),
    );
  }

  Widget _buildInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: offWhite,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey.withOpacity(0.2)),
                ),
                child: TextField(
                  controller: _msgCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Type a message...',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: 20, vertical: 14),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              decoration: BoxDecoration(
                color: _sending ? Colors.grey : primaryColour,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white),
                onPressed: _sending ? null : _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final String text;
  final bool isMe;
  final String senderName;

  const _MessageBubble({
    required this.text,
    required this.isMe,
    required this.senderName,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 4, left: 8, right: 8),
            child: Text(
              senderName,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isMe ? primaryColour : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: Radius.circular(isMe ? 20 : 0),
                bottomRight: Radius.circular(isMe ? 0 : 20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              text,
              style: TextStyle(
                color: isMe ? Colors.white : darkGrey,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}