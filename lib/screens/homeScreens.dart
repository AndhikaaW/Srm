import 'package:flutter/material.dart';
import 'package:srm_v1/components/service.dart';
import 'package:srm_v1/components/sparepart.dart';
import 'package:srm_v1/components/transaction.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFE6F3FF),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(20),
              color: Color(0xFFE6F3FF),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SRI REJEKI MOTOR',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4A86E8),
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Semoga harimu menyenangkan!',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                  SizedBox(height: 20),
                  Image.asset('assets/motor.png'), // Replace with your image
                ],
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMenuItem(
                    context: context,
                    icon: Icons.settings,
                    label: 'Sparepart',
                    color: Colors.teal,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => Sparepart())),
                  ),
                  _buildMenuItem(
                    context: context,
                    icon: Icons.build,
                    label: 'Service',
                    color: Colors.lightBlueAccent,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => Service())),
                  ),
                  _buildMenuItem(
                    context: context,
                    icon: Icons.receipt_long,
                    label: 'Transaksi',
                    color: Colors.orangeAccent,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => Transaction())),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        color: Colors.grey.shade100,
        child: Container(
          width: 100, // Adjust as needed
          height: 100, // Adjust as needed
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 30, color: color),
              SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}