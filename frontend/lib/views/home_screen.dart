import 'package:flutter/material.dart';
import '../palette.dart';
import '../widgets/navigation_bars.dart';
import './map_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _carouselController = PageController(
    viewportFraction: 0.9,
  );
  int _selectedNavIndex = 0;

  @override
  void dispose() {
    _carouselController.dispose();
    super.dispose();
  }

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
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TopNavigationBar(
                onProfileTap: () {
                  // Navigate to profile
                },
              ),
              const SizedBox(height: 40.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Center(
                  child: SizedBox(
                    height: 250,
                    child: PageView.builder(
                      controller: _carouselController,
                      itemCount: 3,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            if (index == 0) {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (context) => const MapScreen()),
                              );
                            }
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 5.0),
                            decoration: BoxDecoration(
                              color: secondaryColour,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: index == 0
                                ? const Center(
                                    child: Text(
                                      'Map',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
