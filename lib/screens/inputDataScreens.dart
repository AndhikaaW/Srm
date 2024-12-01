// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
// import 'package:srm/components/service.dart';
// import 'package:srm/components/sparepart.dart';
// import 'package:srm/services/firestore_services.dart';

class InputDataScreen extends StatefulWidget {
  const InputDataScreen({super.key});

  @override
  State<InputDataScreen> createState() => _InputDataScreenState();
}

class _InputDataScreenState extends State<InputDataScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(centerTitle: true, title: Text('Input Data'),),
        body: Column(
          children: [
            SizedBox(height: 30),
            Row(
              children: [
                SizedBox(width: 30),
                InkWell(
                  // onTap: () {
                  //   Navigator.push(
                  //     context,
                  //     MaterialPageRoute(builder: (context) => Sparepart()),
                  //   );
                  // },
                  child: Card(color: Colors.orangeAccent,
                    elevation: 10,
                    child: Padding(
                      padding: EdgeInsets.all(30),
                      child: Text(
                        "Sparepart",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 20),
                InkWell(
                  // onTap: () {
                  //   Navigator.push(
                  //     context,
                  //     MaterialPageRoute(builder: (context) => Service()),
                  //   );
                  // },
                  child: Card(color: Colors.orangeAccent,
                    elevation: 10,
                    child: Padding(
                      padding: EdgeInsets.all(30),
                      child: Text(
                        "Service",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        )
    );
  }
}
