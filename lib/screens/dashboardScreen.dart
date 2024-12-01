import 'package:flutter/material.dart';
import 'package:srm_v1/screens/historyScreens.dart';
import 'package:srm_v1/screens/home.dart';
import 'package:srm_v1/screens/homeScreens.dart';
import 'package:srm_v1/screens/inputDataScreens.dart';
// import 'package:srm/screens/historyScreen.dart';
// import 'package:srm/screens/homeScreen.dart';
// import 'package:srm/screens/inputDataScreen.dart';
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  late List<Widget> body;

  @override
  void initState() {
    super.initState();
    body = [
      const HomeScreen(),
      const HistoryScreen(),
      const HistoryScreen(),
      // const InputDataScreen()
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      body: Center(
        child: body[_currentIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (int newIndex){
          setState(() {
            _currentIndex = newIndex;
          });
        },
        items: const [
          BottomNavigationBarItem(
              label: 'Utama',
              icon: Icon(Icons.home)
          ),
          BottomNavigationBarItem(
              label: 'Riwayat',
              icon: Icon(Icons.history)
          ),
          BottomNavigationBarItem(
              label: 'Produk',
              icon: Icon(Icons.edit)
          )
        ],
      ),
    );
  }
}
