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
            'message': 'John sent you a message',
            'time': '5 min ago',
            'icon': Icons.message,
        },
        {
            'title': 'Friend Request',
            'message': 'Ben wants to be friends',
            'time': '1 hour ago',
            'icon': Icons.person_add,
        },
        {
            'title': 'Mention',
            'message': 'Mike mentioned you in chat',
            'time': '10 minutes ago',
            'icon': Icons.tag,
        },
        {
            'title': 'Location Update',
            'message': 'New chatroom near you',
            'time': 'Yesterday',
            'icon': Icons.location_on,
        },
    ];
        @override
    Widget build(BuildContext context) {
        return Column(
            children: [

                        Container(
                            padding: const EdgeInsets.all(16),
                            alignment: Alignment.centerLeft,
                            child: const Text(
                                'Notifications',
                                style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: primaryColour,
                                ),
                            ),
                        ),
                        Expanded(
    child: _notifications.isEmpty
        ? const Center(
            child: Text('No notifications'),
          )
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
                        color: Colors.white,
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
                        onTap: () {
                                  },
                                 ),
                              );
                            },
                          ),
                        ),
                    ],
                );      
    }
}