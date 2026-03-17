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
	bool showBottomSheet = true;

    @override
    Widget build(BuildContext context) {
        return Scaffold(
			key:_scaffoldKey,
            body: Stack(
                children: [
                    FlutterMap(
                        options: const MapOptions(
                            initialCenter: LatLng(51.509865, -0.118092), // Default center (London)
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
				label: Text("Show"),
				foregroundColor:black,
				backgroundColor:primaryColourPastel,
				onPressed: () {
					_scaffoldKey.currentState?.showBottomSheet((BuildContext context) {
						if (showBottomSheet == true){
							showBottomSheet = false;
							return Container(
								height: 200,
								color: const Color.fromARGB(255, 63, 59, 61),
								child: Center(
									child: Column(
									mainAxisAlignment: MainAxisAlignment.center,
									mainAxisSize: MainAxisSize.min,
									children: <Widget>[
										const Text('Chatroom Info',style:TextStyle(color:white,fontSize: 20,fontWeight: FontWeight.w600)),
										const Text('Location',style:TextStyle(color:white)),
										const Text('Recent Activity',style:TextStyle(color:white)),
										ElevatedButton(
										child: const Text('Join Chatroom'),
										onPressed: () {
											Navigator.of(context).push(
												MaterialPageRoute(builder: (context) => const MessagesScreen()),
											);
										}
										),
									],
									),
								),
							);
						}
						else{
							showBottomSheet = true;
							return SizedBox.shrink();
						}
					});
				}
			),
        );
    }
}