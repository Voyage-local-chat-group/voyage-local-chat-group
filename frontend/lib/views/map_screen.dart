import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../palette.dart';
import './messages_screen.dart';

class MapScreen extends StatefulWidget {
    const MapScreen({super.key});

    @override
    State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
	final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
	PersistentBottomSheetController? _bottomSheetController;

  void _toggleBottomSheet() {
    if (_bottomSheetController != null) {
      _bottomSheetController!.close();
      _bottomSheetController = null;
      setState(() {});
    } else {
      _bottomSheetController = _scaffoldKey.currentState?.showBottomSheet(
        (context) {
          return Container(
            height: 200,
            color: const Color.fromARGB(255, 63, 59, 61),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Chatroom Info', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600)),
                  const Text('Location', style: TextStyle(color: Colors.white)),
                  const Text('Recent Activity', style: TextStyle(color: Colors.white)),
                  ElevatedButton(
                    child: const Text('Join Chatroom'),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const MessagesScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      );
      _bottomSheetController?.closed.then((_) {
        if (mounted) {
          setState(() {
            _bottomSheetController = null;
          });
        }
      });
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Stack(
        children: [
          FlutterMap(
            options: const MapOptions(
              initialCenter: LatLng(51.509865, -0.118092),
              initialZoom: 13.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.voyage_local_chat',
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: Text(_bottomSheetController != null ? "Hide" : "Show"),
        foregroundColor: black,
        backgroundColor: primaryColourPastel,
        onPressed: _toggleBottomSheet,
      ),
    );
  }
}