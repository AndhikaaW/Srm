import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/firestore_services.dart';

class Sparepart extends StatefulWidget {
  const Sparepart({super.key});

  @override
  State<Sparepart> createState() => _SparepartState();
}

class _SparepartState extends State<Sparepart> {
  final _dbService = DatabaseService();
  final _nameSparepart = TextEditingController();
  final _price = TextEditingController();

  final _searchController = TextEditingController();
  String _selectedCategory = 'Semua Produk';

  // List of available categories
  List<String> categories = ['Sparepart', 'Oli', 'Lampu', 'Lainnya'];

  String _selectedCategoryDropdown = 'Sparepart'; // default category for dropdown

  String formatCurrency(dynamic value) {
    if (value == null) return '';
    String strValue = value.toString();
    final parts = strValue.split('.');
    final wholePart = parts[0].replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
    return parts.length > 1 ? '$wholePart.${parts[1]}' : wholePart;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Produk'),
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
                        hintText: 'Cari Produk',
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
                      backgroundColor: Colors.teal,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: EdgeInsets.all(12),
                    ),
                    child: Icon(Icons.add, color: Colors.white),
                  )
                ],
              )),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildCategoryChip('Semua Produk'),
                ...categories.map((category) => _buildCategoryChip(category)).toList(),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<QueryDocumentSnapshot>>(
              future: _dbService.readSparepart(),
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
                  bool matchesSearch = data['name']
                      .toString()
                      .toLowerCase()
                      .contains(_searchController.text.toLowerCase());
                  bool matchesCategory = _selectedCategory == 'Semua Produk' ||
                      data['category'] == _selectedCategory;
                  return matchesSearch && matchesCategory;
                }).toList();
                return ListView.builder(
                  itemCount: filteredData.length,
                  itemBuilder: (context, index) {
                    var productData =
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
                                  "Apakah anda yakin ingin menghapus ${productData['name']}?"),
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
                        _dbService.delete(filteredData[index].id);
                        setState(() {
                          filteredData.removeAt(index);
                        });
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content:
                            Text("${productData['name']} telah dihapus")));
                      },
                      child: Card(
                        margin:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.grey[200],
                            child: Icon(Icons.image, color: Colors.grey),
                          ),
                          title: Text(productData['name']),
                          subtitle:
                          Text(productData['category'] ?? 'Uncategorized'),
                          trailing: Text(
                              'Rp ${formatCurrency(productData['price'])}'),
                          onTap: () => _showUpdateDialog(
                              context,
                              filteredData[index].id,
                              productData['name'],
                              productData['price'],
                              productData['category']),
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

  Widget _buildCategoryChip(String category) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ChoiceChip(
        label: Text(category),
        selected: _selectedCategory == category,
        onSelected: (selected) {
          setState(() {
            _selectedCategory = selected ? category : 'Semua Produk';
          });
        },
      ),
    );
  }

  void _showDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Tambah Sparepart',
              style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.grey.shade100,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameSparepart,
                decoration: InputDecoration(
                  labelText: "Nama Sparepart",
                  hintText: "Masukkan Nama Sparepart",
                  prefixIcon: Icon(Icons.build),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                  EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                    BorderSide(color: Theme.of(context).primaryColor),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _price,
                decoration: InputDecoration(
                  labelText: "Harga Sparepart",
                  hintText: "Masukkan Harga Sparepart",
                  prefixIcon: Icon(Icons.attach_money),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                  EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                    BorderSide(color: Theme.of(context).primaryColor),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                value: _selectedCategoryDropdown,
                decoration: InputDecoration(
                  labelText: 'Kategori Sparepart',
                  prefixIcon: Icon(Icons.category),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                  EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                    BorderSide(color: Theme.of(context).primaryColor),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategoryDropdown = newValue!;
                  });
                },
                items: categories.map<DropdownMenuItem<String>>((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
              ),
            ],
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
                if (_nameSparepart.text.isNotEmpty &&
                    _price.text.isNotEmpty) {
                  await _dbService.createSparepart(
                      name: _nameSparepart.text,
                      price: int.parse(_price.text),
                      category: _selectedCategoryDropdown);
                  Navigator.of(context).pop();
                  setState(() {});
                  _nameSparepart.clear();
                  _price.clear();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Tolong isi semua kolom')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showUpdateDialog(BuildContext context, String documentId,
      String currentName, int currentPrice, String currentCategory) {
    final _updatedName = TextEditingController(text: currentName);
    final _updatedPrice = TextEditingController(text: currentPrice.toString());
    String _updatedCategory = currentCategory;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Perbarui Sparepart'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: _updatedName,
                  decoration:
                  InputDecoration(hintText: "Masukkan Nama Sparepart")),
              SizedBox(height: 5),
              TextField(
                  controller: _updatedPrice,
                  decoration:
                  InputDecoration(hintText: "Masukkan Harga Sparepart"),
                  keyboardType: TextInputType.number),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _updatedCategory,
                decoration: InputDecoration(
                  labelText: 'Kategori Sparepart',
                  prefixIcon: Icon(Icons.category),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  filled: true,
                  // fillColor: Colors.white,
                  contentPadding:
                  EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                    BorderSide(color: Theme.of(context).primaryColor),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                onChanged: (String? newValue) {
                  setState(() {
                    _updatedCategory = newValue!;
                  });
                },
                items: categories.map<DropdownMenuItem<String>>((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
              ),
            ],
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
                if (_updatedName.text.isNotEmpty &&
                    _updatedPrice.text.isNotEmpty) {
                  await _dbService.updateSparepart(
                      documentId: documentId,
                      name: _updatedName.text,
                      price: int.parse(_updatedPrice.text),
                      category: _updatedCategory);
                  Navigator.of(context).pop();
                  setState(() {});
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Tolong isi semua kolom')),
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
