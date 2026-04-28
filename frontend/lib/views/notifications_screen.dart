import 'package:flutter/material.dart';
import '../widgets/navigation_bars.dart';
import '../palette.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<Map<String, dynamic>> _notifications = [
    {
      'title': 'New Message',
      'message': 'You have a new direct message',
      'time': '',
      'icon': Icons.message,
    },
    {
      'title': 'New Chatroom Nearby',
      'message': 'A new local chatroom has appeared near you',
      'time': '',
      'icon': Icons.location_on,
    },
    {
      'title': 'New Member',
      'message': 'Someone joined your local chatroom',
      'time': '',
      'icon': Icons.group_add,
    },
    {
      'title': 'New Group Chat',
      'message': 'You have been added to a group chat',
      'time': '',
      'icon': Icons.chat_bubble,
    },
  ];
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          alignment: Alignment.centerLeft,
          child: Text(
            'Notifications',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        Expanded(
          child: _notifications.isEmpty
              ? const Center(child: Text('No notifications'))
              : ListView.builder(
                  itemCount: _notifications.length,
                  itemBuilder: (context, index) {
                    final notif = _notifications[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
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
                        leading: CircleAvatar(
                          backgroundColor: primaryColour.withOpacity(0.1),
                          child: Icon(
                            notif['icon'],
                            color: primaryColour,
                            size: 20,
                          ),
                        ),
                        title: Text(notif['title']),
                        subtitle: Text(notif['message']),
                        trailing: Text(
                          notif['time'],
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        onTap: () {},
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
