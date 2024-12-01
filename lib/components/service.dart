import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/firestore_services.dart';

class Service extends StatefulWidget {
  const Service({super.key});

  @override
  State<Service> createState() => _ServiceState();
}

class _ServiceState extends State<Service> {
  final _dbService = DatabaseService();
  final _searchController = TextEditingController();
  final _serviceName = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Service'),
        // actions: [
        //   IconButton(
        //     icon: Icon(Icons.add),
        //     onPressed: () => _showDialog(context),
        //   ),
        // ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Cari Jasa',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => _showDialog(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15), // Adjust radius as needed
                    ),
                    padding: EdgeInsets.all(12), // Adjust padding as needed
                  ),
                  child: Icon(Icons.add, color: Colors.white), // White icon for contrast
                )
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<QueryDocumentSnapshot>>(
              future: _dbService.readService(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No data available'));
                }
                var filteredData = snapshot.data!.where((doc) {
                  var data = doc.data() as Map<String, dynamic>;
                  return data['serviceName']
                      .toString()
                      .toLowerCase()
                      .contains(_searchController.text.toLowerCase());
                }).toList();
                return ListView.builder(
                  itemCount: filteredData.length,
                  itemBuilder: (context, index) {
                    var serviceData =
                        filteredData[index].data() as Map<String, dynamic>;
                    return Dismissible(
                      key: Key(filteredData[index].id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.only(right: 20.0),
                        color: Colors.red,
                        child: Icon(Icons.delete, color: Colors.white),
                      ),
                      confirmDismiss: (direction) async {
                        return await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("Konfirmasi Hapus"),
                              content: Text(
                                  "Apakah anda yakin ingin menghapus ${serviceData['serviceName']}?"),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: Text("Batal"),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  child: Text("Hapus"),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      onDismissed: (direction) {
                        _dbService.deleteService(filteredData[index].id);
                        setState(() {
                          filteredData.removeAt(index);
                        });
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                                "${serviceData['serviceName']} telah dihapus")));
                      },
                      child: Card(
                        margin:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue[200],
                            child: Icon(Icons.build, color: Colors.blue),
                          ),
                          title: Text(serviceData['serviceName']),
                          onTap: () => _showUpdateDialog(
                              context,
                              filteredData[index].id,
                              serviceData['serviceName']),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Tambah Jasa'),
          content: TextField(
            controller: _serviceName,
            decoration: InputDecoration(hintText: "Masukkan Nama Jasa"),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('OK'),
              onPressed: () async {
                if (_serviceName.text.isNotEmpty) {
                  await _dbService.createService(
                    serviceName: _serviceName.text,
                  );
                  Navigator.of(context).pop();
                  setState(() {});
                  _serviceName.clear();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Tolong isi nama jasa')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showUpdateDialog(
      BuildContext context, String documentId, String currentName) {
    final _updatedName = TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Perbarui Jasa'),
          content: TextField(
            controller: _updatedName,
            decoration: InputDecoration(hintText: "Masukkan Nama Jasa"),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Perbarui'),
              onPressed: () async {
                if (_updatedName.text.isNotEmpty) {
                  await _dbService.updateService(
                    documentId: documentId,
                    serviceName: _updatedName.text,
                  );
                  Navigator.of(context).pop();
                  setState(() {});
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Tolong isi nama jasa')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}
