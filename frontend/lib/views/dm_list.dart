import 'package:flutter/material.dart';
import '../widgets/navigation_bars.dart';
import '../palette.dart';

class DmList extends StatefulWidget {
  const DmList({super.key});

  @override
  State<DmList> createState() => _DmListState();
}

class _DmListState extends State<DmList> {
  int _selectedNavIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: offWhite,
      bottomNavigationBar: BottomNavigationBarWidget(
        selectedIndex: _selectedNavIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedNavIndex = index;
          });
        },
      ),
      body: SafeArea(
        child: Column(
          children: [
            TopNavigationBar(onProfileTap: () {}),
            const Expanded(child: Center(child: Text('Messages screen'))),
          ],
        ),
      ),
    );
  }
}
