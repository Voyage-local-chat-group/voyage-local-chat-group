import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';
import '../palette.dart';

// Screen that shows recent message notifications.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<Map<String, dynamic>> _notifications = [];
  Timer? _timer;
  String? _token;
  bool _loading = true;
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _startRealtimeNotifications();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _startRealtimeNotifications() async {
    // Load the token and refresh notifications every few seconds.
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('jwt_token');
    await _fetchNotifications();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      _fetchNotifications();
    });
  }

  Future<void> _fetchNotifications() async {
    // Get notifications from the backend.
    if (_token == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('$backendURL/notifications'),
        headers: {'Authorization': 'Bearer $_token'},
      );

      if (response.statusCode == 200 && mounted) {
        final body = jsonDecode(response.body);
        final items = List<Map<String, dynamic>>.from(body['data'] ?? []);
        setState(() {
          _notifications
            ..clear()
            ..addAll(items);
          _unreadCount = body['unread_count'] ?? 0;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _markAsRead(int index) async {
    final notification = _notifications[index];
    if (notification['is_read'] == true || _token == null) return;

    setState(() {
      _notifications[index] = {...notification, 'is_read': true};
      if (_unreadCount > 0) _unreadCount -= 1;
    });

    try {
      final notificationId = notification['id'];
      await http.patch(
        Uri.parse('$backendURL/notifications/$notificationId/read'),
        headers: {'Authorization': 'Bearer $_token'},
      );
    } catch (_) {
      // The next refresh will correct the list if the request failed.
    }
  }

  Future<void> _markAllAsRead() async {
    if (_token == null || _unreadCount == 0) return;

    setState(() {
      for (var i = 0; i < _notifications.length; i++) {
        _notifications[i] = {..._notifications[i], 'is_read': true};
      }
      _unreadCount = 0;
    });

    try {
      await http.patch(
        Uri.parse('$backendURL/notifications/read-all'),
        headers: {'Authorization': 'Bearer $_token'},
      );
    } catch (_) {
      // The next refresh will correct the list if the request failed.
    }
  }

  IconData _iconFor(String? type) {
    // Choose an icon based on the notification type.
    if (type == 'group') return Icons.chat_bubble;
    return Icons.message;
  }

  String _formatTime(String? value) {
    // Convert the backend time into a short local time string.
    if (value == null) return '';
    final time = DateTime.tryParse(value);
    if (time == null) return '';
    final local = time.toLocal();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _unreadCount == 0
                      ? 'Notifications'
                      : 'Notifications ($_unreadCount)',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              if (_unreadCount > 0)
                TextButton.icon(
                  onPressed: _markAllAsRead,
                  icon: const Icon(Icons.done_all),
                  label: const Text('Read all'),
                ),
            ],
          ),
        ),
        Expanded(child: _buildBody()),
      ],
    );
  }

  Widget _buildBody() {
    // Show loading, empty state, or the notification list.
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_notifications.isEmpty) {
      return const Center(child: Text('No notifications'));
    }

    return RefreshIndicator(
      onRefresh: _fetchNotifications,
      child: ListView.builder(
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          final notification = _notifications[index];
          final isUnread = notification['is_read'] != true;
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: isUnread
                  ? primaryColour.withOpacity(0.08)
                  : Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListTile(
              onTap: () => _markAsRead(index),
              leading: CircleAvatar(
                backgroundColor: primaryColour.withOpacity(
                  isUnread ? 0.18 : 0.1,
                ),
                child: Icon(
                  _iconFor(notification['type']),
                  color: primaryColour,
                  size: 20,
                ),
              ),
              title: Text(
                notification['title'] ?? 'New Notification',
                style: TextStyle(
                  fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              subtitle: Text(notification['message'] ?? ''),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatTime(notification['time']),
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  if (isUnread) ...[
                    const SizedBox(height: 6),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: primaryColour,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
