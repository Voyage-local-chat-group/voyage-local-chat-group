import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../palette.dart';
import '../main.dart';
import './messages_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  PersistentBottomSheetController? _bottomSheetController;

  List<Map<String, dynamic>> _chatrooms = [];
  Map<String, dynamic>? _selectedRoom;
  String? _token;
  bool _loading = true;
  final MapController _mapController = MapController();
  double? _mouseX;
  double? _mouseY;
  LatLng? _createLocation;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('jwt_token');
    await _fetchChatrooms();
  }

  Future<void> _fetchChatrooms() async {
    if (_token == null) {
      setState(() => _loading = false);
      return;
    }
    try {
      final response = await http.get(
        Uri.parse('$backendURL/chatrooms/locational'),
        headers: {'Authorization': 'Bearer $_token'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _chatrooms = List<Map<String, dynamic>>.from(data['data']);
          _loading = false;
        });
      } else {
        setState(() => _loading = false);
      }
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  LatLng? _parseCoords(String? coords) {
    if (coords == null || coords.trim().isEmpty) return null;
    final parts = coords.trim().split(',');
    if (parts.length != 2) return null;
    try {
      return LatLng(double.parse(parts[0]), double.parse(parts[1]));
    } catch (_) {
      return null;
    }
  }

  LatLng _getCentrePoint(Map<String, dynamic> room) {
    final tl = _parseCoords(room['coords_top_left']);
    final br = _parseCoords(room['coords_bottom_right']);
    if (tl != null && br != null) {
      return LatLng(
        (tl.latitude + br.latitude) / 2,
        (tl.longitude + br.longitude) / 2,
      );
    }
    if (tl != null) return tl;
    if (br != null) return br;
    return const LatLng(50.7989, -1.0914);
  }

  void _onMarkerTap(Map<String, dynamic> room) {
    setState(() => _selectedRoom = room);
    if (_bottomSheetController != null) {
      _bottomSheetController!.close();
      _bottomSheetController = null;
    }
    _bottomSheetController = _scaffoldKey.currentState?.showBottomSheet(
      (context) => _buildBottomSheet(room),
    );
    _bottomSheetController?.closed.then((_) {
      if (mounted) {
        setState(() {
          _bottomSheetController = null;
          _selectedRoom = null;
        });
      }
    });
  }

  Widget _buildBottomSheet(Map<String, dynamic> room) {
    return Container(
      width: double.infinity,
      height: 200,
      color: const Color.fromARGB(255, 63, 59, 61),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            room['chatroom_name'] ?? 'Chatroom',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Local chatroom · Portsmouth',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: const Icon(Icons.group),
            label: const Text('Join Chatroom'),
            onPressed: () => _joinChatroom(room),
          ),
        ],
      ),
    );
  }

  Future<void> _joinChatroom(Map<String, dynamic> room) async {
    if (_token == null) return;
    try {
      final response = await http.post(
        Uri.parse('$backendURL/chatrooms/join'),
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'chatroom_id': room['chatroom_id']}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final chatroomId = data['data']['chatroom_id'];
        final displayName = data['data']['chatroom_name'];
        if (mounted) {
          _bottomSheetController?.close();
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) =>
                  ChatScreen(chatroomId: chatroomId, displayName: displayName),
            ),
          );
        }
      }
    } catch (e) {
      // 忽略网络错误
    }
  }

  Future<void> _createLocationalChatroom() async {
    if (_token == null) return;
    if (_createLocation == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please tap on the map to select a location first'),
          ),
        );
      }
      return;
    }
    final lat = _createLocation!.latitude;
    final lng = _createLocation!.longitude;
    final topLeft =
        '${(lat + 0.005).toStringAsFixed(4)},${(lng - 0.005).toStringAsFixed(4)}';
    final bottomRight =
        '${(lat - 0.005).toStringAsFixed(4)},${(lng + 0.005).toStringAsFixed(4)}';
    final name =
        'Local Chat at ${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}';

    try {
      final response = await http.post(
        Uri.parse('$backendURL/chatrooms/locational'),
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'chatroom_name': name,
          'coords_top_left': topLeft,
          'coords_bottom_right': bottomRight,
        }),
      );
      if (response.statusCode == 201) {
        await _fetchChatrooms(); // Refresh the map
        setState(() => _createLocation = null); // Reset after creation
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Locational chatroom created!')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to create chatroom')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error creating chatroom')),
        );
      }
    }
  }

  Future<void> _resetChatrooms() async {
    if (_token == null) return;
    if (_chatrooms.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('No chatrooms to delete')));
      }
      return;
    }
    try {
      final response = await http.delete(
        Uri.parse('$backendURL/chatrooms/locational'),
        headers: {'Authorization': 'Bearer $_token'},
      );
      if (response.statusCode == 200) {
        await _fetchChatrooms(); // Refresh the map
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('All locational chatrooms deleted!')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to delete chatrooms')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error deleting chatrooms')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final markers = _chatrooms.map((room) {
      final point = _getCentrePoint(room);
      final isSelected = _selectedRoom?['chatroom_id'] == room['chatroom_id'];
      return Marker(
        point: point,
        width: 40,
        height: 40,
        child: GestureDetector(
          onTap: () => _onMarkerTap(room),
          child: Icon(
            Icons.chat_bubble,
            color: isSelected ? primaryColour : primaryColourPastel,
            size: 36,
          ),
        ),
      );
    }).toList();

    return Scaffold(
      key: _scaffoldKey,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                MouseRegion(
                  onHover: (event) {
                    setState(() {
                      _mouseX = event.localPosition.dx;
                      _mouseY = event.localPosition.dy;
                    });
                  },
                  onExit: (_) => setState(() {
                    _mouseX = null;
                    _mouseY = null;
                  }),
                  child: FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: const LatLng(50.7989, -1.0914),
                      initialZoom: 14.0,
                      onTap: (tapPosition, latLng) =>
                          setState(() => _createLocation = latLng),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.voyage_local_chat',
                      ),
                      MarkerLayer(markers: markers),
                    ],
                  ),
                ),
                if (_mouseX != null && _mouseY != null)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      color: Colors.white.withOpacity(0.8),
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        '${_mouseX!.toStringAsFixed(0)}, ${_mouseY!.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: ElevatedButton(
                    onPressed: _resetChatrooms,
                    child: const Text('Reset Chatrooms'),
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createLocationalChatroom,
        child: const Icon(Icons.add),
        tooltip: 'Create Locational Chatroom',
      ),
    );
  }
}
