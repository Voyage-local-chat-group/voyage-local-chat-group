import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../palette.dart';
import '../main.dart';
import '../widgets/navigation_bars.dart';
import './map_screen.dart';
import './messages_screen.dart';
import './notifications_screen.dart';
import './settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  int _selectedNavIndex = 0;
  List<Map<String, dynamic>> _chatrooms = [];
  bool _loadingChatrooms = false;

  @override
  void initState() {
    super.initState();
    _fetchMyChatrooms();
  }

  // Fetch the current user's chatrooms from the backend.
  Future<void> _fetchMyChatrooms() async {
    setState(() => _loadingChatrooms = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token') ?? '';
      final response = await http.get(
        Uri.parse('$backendURL/chatrooms/mine'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _chatrooms = List<Map<String, dynamic>>.from(data['data']);
        });
      }
    } catch (e) {
      debugPrint('Failed to load chatrooms: $e');
    } finally {
      setState(() => _loadingChatrooms = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBarWidget(
        selectedIndex: _selectedNavIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedNavIndex = index;
          });
          if (index == 0) {
            _fetchMyChatrooms();
          }
        },
      ),
      body: SafeArea(
        child: Column(
          children: [
            TopNavigationBar(onProfileTap: () {}),

            if (_selectedNavIndex == 0) ...[
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 位置卡片
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: primaryColour,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.location_on, color: Colors.white),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    'Your Location',
                                    style: TextStyle(color: Colors.white70, fontSize: 12),
                                  ),
                                  Text(
                                    'Portsmouth, UK',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${_chatrooms.length} joined',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      const Text(
                        'My Chatrooms',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // 显示加载、空状态或真实聊天室列表
                      if (_loadingChatrooms)
                        const Center(child: CircularProgressIndicator())
                      else if (_chatrooms.isEmpty)
                        const Text(
                          'No chatrooms joined yet. Visit the map to join one!',
                          style: TextStyle(color: Colors.grey),
                        )
                      else
                        SizedBox(
                          height: 120,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _chatrooms.length,
                            itemBuilder: (context, index) {
                              final room = _chatrooms[index];
                              final name = room['display_name'] ?? room['chatroom_name'] ?? 'Chatroom';
                              return _buildChatroomCard(name, Icons.group);
                            },
                          ),
                        ),

                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _selectedNavIndex = 2;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColour,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'View Map',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              Expanded(
                child: IndexedStack(
                  index: _selectedNavIndex,
                  children: const [
                    SizedBox.shrink(),
                    MessagesScreen(),
                    MapScreen(),
                    NotificationsScreen(),
                    SettingsScreen(),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildChatroomCard(String name, IconData icon) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: primaryColour, size: 28),
          const SizedBox(height: 8),
          Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.bold),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}