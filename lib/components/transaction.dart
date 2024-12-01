import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:srm_v1/components/invoice.dart';
import 'package:srm_v1/components/print.dart';
import 'package:srm_v1/services/cart_repository.dart';
import '../services/firestore_services.dart';

class CartItem {
  final int? id;
  final String customerName;
  final String vehicleType;
  final String? mechanic;
  final Map<String, double> selectedServices;
  final Map<String, int> selectedProducts;
  final double total;

  CartItem({
    this.id,
    required this.customerName,
    required this.vehicleType,
    required this.mechanic,
    required this.selectedServices,
    required this.selectedProducts,
    required this.total,
  });
}
class SparepartItem {
  final String id;
  final String name;
  final int price;
  final String category;

  SparepartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
  });
}
typedef OnItemSelected = void Function(SparepartItem item);

// Di widget parent:
OnItemSelected onSelected = (SparepartItem item) {
  // Handle item selection
  print('Selected item: ${item.name}');
};

class Transaction extends StatefulWidget {
  @override
  _TransactionState createState() => _TransactionState();
}

class _TransactionState extends State<Transaction> {
  final _dbService = DatabaseService();
  final _formKey = GlobalKey<FormState>();
  final _namaPelanggan = TextEditingController();
  final _jenisKendaraan = TextEditingController();

  List<Map<String, dynamic>> _jasaList = [];
  List<Map<String, dynamic>> _produkList = [];

  List<CartItem> _cartItems = [];

  Map<String, double> selectedJasaFees = {};
  Map<String, int> selectedProdukQuantities = {};

  String? selectedJasa;
  String? selectedProduk;

  List<String> mechanicNames = ['Lukman', 'Diaz', 'Vano', 'Yono', 'Agus'];
  String? selectedMechanic;

  double total = 0;

  final cartRepository = CartRepository.instance;

  Future<void> _fetchProducts() async {
    final _dbService = DatabaseService();
    final snapshots = await _dbService.readSparepart();
    setState(() {
      _produkList = snapshots.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'name': data['name'],
          'price': data['price'],
          'category': data['category'],
        };
      }).toList();
    });
  }
  Future<void> _fetchServices() async {
    final snapshots = await _dbService.readService();
    setState(() {
      _jasaList = snapshots.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'serviceName': data['serviceName'],
        };
      }).toList();
    });
  }
  // Add these controllers at the class level
  final _nameSparepart = TextEditingController();
  final _price = TextEditingController();
  String _selectedCategoryDropdown = 'Sparepart';
  final List<String> categories = ['Sparepart', 'Oli', 'Lampu', 'Lainnya'];
  void _showAddSparepartDialog(BuildContext context) {
    _nameSparepart.clear();
    _price.clear();
    _selectedCategoryDropdown = 'Sparepart';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (context, setState) {
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
                    // Di dalam onPressed OK button _showAddSparepartDialog
                    onPressed: () async {
                      if (_nameSparepart.text.isNotEmpty && _price.text.isNotEmpty) {
                        final _dbService = DatabaseService();
                        await _dbService.createSparepart(
                            name: _nameSparepart.text,
                            price: int.parse(_price.text),
                            category: _selectedCategoryDropdown
                        );

                        // Refresh products
                        await _fetchProducts();

                        // Clear form and close dialog
                        _nameSparepart.clear();
                        _price.clear();
                        Navigator.of(context).pop();

                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Sparepart berhasil ditambahkan'))
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Tolong isi semua kolom')),
                        );
                      }
                    },
                  ),
                ],
              );
            }
        );
      },
    );
  }

  final _serviceName = TextEditingController();

  void _showAddJasaDialog(BuildContext context) {
    _serviceName.clear(); // Clear the existing text

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Tambah Jasa',
              style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.grey.shade100,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _serviceName,
                decoration: InputDecoration(
                  labelText: "Nama Jasa",
                  hintText: "Masukkan Nama Jasa",
                  prefixIcon: Icon(Icons.build_circle),
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
                if (_serviceName.text.isNotEmpty) {
                  await _dbService.createService(
                    serviceName: _serviceName.text,
                  );

                  await _fetchServices();
                  // Clear form and close dialog
                  _serviceName.clear();
                  Navigator.of(context).pop();
                  setState(() {}); // Refresh the list

                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Jasa berhasil ditambahkan'))
                  );
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

  void _addToCart() async {
    CartItem newItem = CartItem(
      customerName: _namaPelanggan.text,
      vehicleType: _jenisKendaraan.text,
      mechanic: selectedMechanic,
      selectedServices: selectedJasaFees,
      selectedProducts: selectedProdukQuantities,
      total: total,
    );

    // Simpan ke database
    await cartRepository.addToCart(newItem);

    // Update state
    setState(() {
      _cartItems.add(newItem);
    });

    // Reset form
    _resetForm();
  }

  void _resetForm() {
    _namaPelanggan.clear();
    _jenisKendaraan.clear();
    selectedMechanic = null;
    selectedJasaFees.clear();
    selectedProdukQuantities.clear();
    selectedJasa = null;
    selectedProduk = null;
    total = 0;
  }

  void _showCart()  async {
    final items = await cartRepository.getCartItems();

    setState(() {
      _cartItems = items;
    });
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Keranjang Belanja'),
          content: Container(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ..._cartItems.asMap().entries.map((entry) {
                    int index = entry.key;
                    CartItem item = entry.value;
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('ID : ${item.id}'),
                            Text('Pelanggan: ${item.customerName}',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('Kendaraan: ${item.vehicleType}'),
                            Text('Mekanik: ${item.mechanic ?? "Belum dipilih"}'),
                            Divider(),
                            Text('Jasa:'),
                            ...item.selectedServices.entries.map((service) =>
                                Text('- ${service.key}: Rp ${formatCurrency(service.value)}')),
                            Divider(),
                            Text('Produk:'),
                            ...item.selectedProducts.entries.map((product) {
                              var produkItem = _produkList
                                  .firstWhere((p) => p['name'] == product.key);
                              return Text(
                                  '- ${product.key} (${product.value}x): Rp ${formatCurrency(produkItem["price"] * product.value)}');
                            }),
                            Divider(),
                            Text('Total: Rp ${formatCurrency(item.total)}',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            ButtonBar(
                              children: [
                                TextButton(
                                  child: Text('Hapus'),
                                  onPressed: () => _deleteCartItem(index)
                                ),
                                TextButton(
                                  child: Text('Edit'),
                                  onPressed: () => _editCartItem(index),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                  if (_cartItems.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text('Keranjang kosong'),
                    ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Tutup'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  void _deleteCartItem(int index) async {
    final itemToDelete = _cartItems[index];

    if (itemToDelete.id != null) {
      try {
        // Tampilkan loading indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return Center(child: CircularProgressIndicator());
          },
        );

        await cartRepository.deleteCartItem(itemToDelete.id!);

        // Tutup loading indicator
        Navigator.pop(context);

        setState(() {
          _cartItems.removeAt(index);
        });

        // Tutup dialog keranjang
        Navigator.pop(context);

        // Tampilkan ulang keranjang dengan data terbaru
        _showCart();

        // Tampilkan success message
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Item berhasil dihapus'),
              backgroundColor: Colors.green,
            )
        );
      } catch (e) {
        // Tutup loading indicator
        Navigator.pop(context);

        // Tampilkan error message
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menghapus item: ${e.toString()}'),
              backgroundColor: Colors.red,
            )
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ID item tidak ditemukan'),
            backgroundColor: Colors.red,
          )
      );
    }
  }

  void _populateFormWithCartItem(CartItem item) {
    setState(() {
      _namaPelanggan.text = item.customerName;
      _jenisKendaraan.text = item.vehicleType;
      selectedMechanic = item.mechanic;
      selectedJasaFees = Map.from(item.selectedServices);
      selectedProdukQuantities = Map.from(item.selectedProducts);
      total = item.total;
    });
  }

  // Fungsi edit menggantikan checkout
  void _editCartItem(int index) {
    CartItem item = _cartItems[index];

    // Hapus item dari keranjang
    setState(() {
      _cartItems.removeAt(index);
    });

    // Tutup dialog keranjang
    Navigator.of(context).pop();

    // Isi form dengan data dari item
    _populateFormWithCartItem(item);

    // Scroll ke atas halaman (optional)
    if (scrollController.hasClients) {
      scrollController.animateTo(
        0,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  // Tambahkan ScrollController
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadSpareparts();
    _loadJasa();
  }

  Future<void> _loadSpareparts() async {
    List<QueryDocumentSnapshot> sparepartDocs =
        await _dbService.readSparepart();
    setState(() {
      _produkList = sparepartDocs
          .map((doc) =>
              {'name': doc['name'] as String, 'price': doc['price'] as int})
          .toList();
    });
  }

  Future<void> _loadJasa() async {
    List<QueryDocumentSnapshot> jasaDocs = await _dbService.readService();
    setState(() {
      _jasaList = jasaDocs
          .map((doc) => {
                'serviceName': doc['serviceName'] as String,
              })
          .toList();
    });
  }

  void _showSearchDialog(BuildContext context, List<String> items, String title,
      Function(String) onSelected) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SearchDialog(
          items: items,
          title: title,
          onSelected: onSelected,
          onRefresh: _fetchServices,
        );
      },
    );
  }
  void _showSearchDialogproduk(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SearchDialog(
          items: _produkList
              .map((produk) => '${produk['name']} - Rp ${formatCurrency(produk['price'])}')
              .toList(),
          title: 'Pilih Produk',
          onSelected: (String selected) {
            _fetchProducts();
            setState(() {
              selectedProduk = selected.split(' - ')[0];
            });
          },
          onRefresh: _fetchProducts,
          onUpdate: (oldName, newName, oldPrice, newPrice) {
            _updateProduct(oldName, newName, oldPrice, newPrice);
          },
        );
      },
    );
  }

  Future<void> _updateProduct(String oldName, String newName, int oldPrice, int newPrice) async {

    final produkRef = FirebaseFirestore.instance.collection('spareparts');
    final snapshot = await produkRef.where('name', isEqualTo: oldName).get();
    if (snapshot.docs.isNotEmpty) {
      await snapshot.docs.first.reference.update({
        'name': newName,
        'price': newPrice,
      });
    }
    await _fetchProducts();
  }

  void _addJasa() {
    if (selectedJasa != null) {
      _showOngkosInputDialog(selectedJasa!);
    }
  }

  void _showOngkosInputDialog(String jasa) {
    TextEditingController ongkosController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Masukkan Ongkos untuk $jasa"),
          content: TextField(
            controller: ongkosController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Ongkos'),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Simpan'),
              onPressed: () {
                double ongkos = double.tryParse(ongkosController.text) ?? 0;
                setState(() {
                  selectedJasaFees[jasa] = ongkos;
                });
                calculateTotal();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _addProduk() {
    if (selectedProduk != null) {
      setState(() {
        if (selectedProdukQuantities.containsKey(selectedProduk)) {
          selectedProdukQuantities[selectedProduk!] =
              (selectedProdukQuantities[selectedProduk] ?? 0) + 1;
        } else {
          selectedProdukQuantities[selectedProduk!] = 1;
        }
      });
      calculateTotal();
    }
  }

  void calculateTotal() {
    total = 0;
    selectedJasaFees.forEach((jasa, fee) {
      total += fee;
    });
    selectedProdukQuantities.forEach((produk, quantity) {
      var produkItem = _produkList.firstWhere((item) => item['name'] == produk);
      total += (produkItem['price'] as int) * quantity;
    });
    setState(() {});
  }

  String formatCurrency(dynamic value) {
    if (value == null) return '';
    String strValue = value.toString();
    final parts = strValue.split('.');
    final wholePart = parts[0].replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
    return parts.length > 1 ? '$wholePart.${parts[1]}' : wholePart;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tambah Transaksi'),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.shopping_cart),
                onPressed: _showCart,
              ),
              if (_cartItems.isNotEmpty)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: BoxConstraints(
                      minWidth: 20,
                      minHeight: 20,
                    ),
                    child: Text(
                      '${_cartItems.length}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText: 'Nama Pelanggan'),
                controller: _namaPelanggan,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Jenis Kendaraan'),
                controller: _jenisKendaraan,
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Pilih Mekanik'),
                value: selectedMechanic,
                items: mechanicNames.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    selectedMechanic = newValue;
                  });
                },
              ),
              SizedBox(height: 20),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        ElevatedButton(
                          onPressed: () => _showAddSparepartDialog(context),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.all(10),
                            minimumSize: Size(40, 40),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Icon(Icons.add, size: 20),
                        ),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _showSearchDialogproduk(context),
                            child: Text(selectedProduk ?? 'Pilih Produk'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _addProduk,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                      textStyle: TextStyle(fontSize: 15),
                      minimumSize: Size(50, 30),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text('Tambah Produk'),
                  ),
                ],
              ),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () => _showAddJasaDialog(context),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.all(10),
                      minimumSize: Size(40, 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Icon(Icons.add, size: 20),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _showSearchDialog(
                        context,
                        _jasaList
                            .map((jasa) => jasa['serviceName'] as String)
                            .toList(),
                        'Pilih Jasa',
                        (String selected) {
                          setState(() {
                            selectedJasa = selected;
                          });
                        },
                      ),
                      child: Text(selectedJasa ?? 'Pilih Jasa'),
                    ),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _addJasa,
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      textStyle: TextStyle(fontSize: 15),
                      minimumSize: Size(50, 30),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text('Tambah Jasa'),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text('Jasa yang dipilih:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Column(
                children: selectedJasaFees.entries.map((entry) {
                  return ListTile(
                    title: Text(entry.key),
                    subtitle: Text(
                        'Ongkos: Rp ${formatCurrency(entry.value.toInt())}'),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        setState(() {
                          selectedJasaFees.remove(entry.key);
                          calculateTotal();
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 20),
              Text('Produk yang dipilih:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Column(
                children: selectedProdukQuantities.entries.map((entry) {
                  var produk =
                      _produkList.firstWhere((p) => p['name'] == entry.key);
                  return ListTile(
                    title: Text(
                        '${entry.key} - Rp ${formatCurrency(produk['price'])}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.remove),
                          onPressed: () {
                            setState(() {
                              if (entry.value > 1) {
                                selectedProdukQuantities[entry.key] =
                                    entry.value - 1;
                              } else {
                                selectedProdukQuantities.remove(entry.key);
                              }
                              calculateTotal();
                            });
                          },
                        ),
                        Text('${entry.value}'),
                        IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () {
                            setState(() {
                              selectedProdukQuantities[entry.key] =
                                  entry.value + 1;
                              calculateTotal();
                            });
                          },
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 20),
              Text("Total: Rp ${formatCurrency(total.toInt())}",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        List<Map<String, dynamic>> jasa =
                        selectedJasaFees.entries.map((entry) {
                          return {
                            'serviceName': entry.key,
                            'ongkos': entry.value,
                          };
                        }).toList();

                        List<Map<String, dynamic>> produk =
                        selectedProdukQuantities.entries.map((entry) {
                          var produkItem = _produkList
                              .firstWhere((item) => item['name'] == entry.key);
                          return {
                            'name': entry.key,
                            'quantity': entry.value,
                            'price': produkItem['price'],
                          };
                        }).toList();

                        await _dbService.createTransaction(
                          pelanggan: _namaPelanggan.text,
                          jenisKendaraan: _jenisKendaraan.text,
                          mekanik: selectedMechanic ?? '',
                          jasa: jasa,
                          produk: produk,
                          total: total.toString(),
                        );
                        Navigator.of(context).pop();
                        _showTransactionReceipt(
                          CartItem(
                            customerName: _namaPelanggan.text,
                            vehicleType: _jenisKendaraan.text,
                            mechanic: selectedMechanic,
                            selectedServices: selectedJasaFees,
                            selectedProducts: selectedProdukQuantities,
                            total: total,
                          ),
                        );
                      }
                    },
                    child: Text('Simpan Transaksi'),
                  ),
                  ElevatedButton(
                    onPressed: _addToCart,
                    child: Text('Tambah ke Keranjang'),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void _showTransactionReceipt(CartItem item) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TransactionReceiptPage(
          pelanggan: _namaPelanggan.text,
          jenisKendaraan: _jenisKendaraan.text,
          jasa: selectedJasaFees.entries.map((entry) {
            return {
              'serviceName': entry.key,
              'ongkos': entry.value,
            };
          }).toList(),
          produk: selectedProdukQuantities.entries.map((entry) {
            var produkItem =
                _produkList.firstWhere((item) => item['name'] == entry.key);
            return {
              'name': entry.key,
              'quantity': entry.value,
              'price': produkItem['price'],
            };
          }).toList(),
          total: total.toString(),
        ),
      ),
    );
  }
}

class SearchDialog extends StatefulWidget {
  final List items;
  final String title;
  final Function(String) onSelected;
  final Future Function()? onRefresh;
  final Function(String, String, int, int)? onUpdate;

  SearchDialog({
    required this.items,
    required this.title,
    required this.onSelected,
    this.onRefresh,
    this.onUpdate,
  });

  @override
  _SearchDialogState createState() => _SearchDialogState();
}

class _SearchDialogState extends State<SearchDialog> {
  String _searchQuery = '';
  List _filteredItems = [];
  bool _isLoading = false;
  String _selectedItem = '';
  bool _isEditing = false;
  final _updatedName = TextEditingController();
  final _updatedPrice = TextEditingController();


  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
    _refreshItems();
  }

  Future<void> _refreshItems() async {
    setState(() => _isLoading = true);

    if (widget.onRefresh != null) {
      await widget.onRefresh!();
    }

    setState(() => _isLoading = false);
  }

  void _filterItems(String query) {
    setState(() {
      _searchQuery = query;
      _filteredItems = widget.items
          .where((item) => item.toString().toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _handleLongPress(String itemValue) {
    setState(() {
      _selectedItem = itemValue;
      _isEditing = true;
      final List<String> parts = itemValue.split(' - ');
      _updatedName.text = parts[0];
      _updatedPrice.text = parts[1].replaceFirst('Rp ', '');
    });
  }

  void _cancelEdit() {
    setState(() {
      _isEditing = false;
      _updatedName.clear();
      _updatedPrice.clear();
    });
  }

  void _saveEdit() {
    if (_updatedName.text.isNotEmpty && _updatedPrice.text.isNotEmpty) {
      final newName = _updatedName.text.trim();
      final newPriceString = _updatedPrice.text.trim();
      int newPrice;

      final numericPriceString = newPriceString.replaceAll(RegExp(r'[^0-9]'), '');

      try {
        newPrice = int.parse(numericPriceString);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Harga produk harus berupa angka')),
        );
        return;
      }

      if (widget.onUpdate != null) {
        final List<String> parts = _selectedItem.split(' - ');
        final oldName = parts[0];
        final oldPriceString = parts[1].replaceFirst('Rp ', '');
        final oldPrice = int.parse(oldPriceString.replaceAll(RegExp(r'[^0-9]'), ''));
        widget.onUpdate!(oldName, newName, oldPrice, newPrice);
      }

      setState(() {
        _isEditing = false;
        _selectedItem = '$newName - Rp $newPrice';
        _updatedName.clear();
        _updatedPrice.clear();
      });
      _refreshData();

    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tolong isi semua kolom')),
      );
    }
  }
  void _refreshData() {
    setState(() {
      _isLoading = true;
    });

    if (widget.onRefresh != null) {
      widget.onRefresh!().then((_) {
        setState(() {
          _isLoading = false;
          _filteredItems = widget.items;
          _searchQuery = '';
        });
      });
    } else {
      setState(() {
        _isLoading = false;
        _filteredItems = widget.items;
        _searchQuery = '';
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(widget.title),
          if (_isLoading)
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            ),
        ],
      ),
      content: Container(
        width: double.maxFinite,
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              onChanged: _filterItems,
              decoration: InputDecoration(
                hintText: 'Cari...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            SizedBox(height: 10),

            if (_isEditing)
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _updatedName,
                      decoration: InputDecoration(
                        labelText: "Nama Produk",
                        hintText: "Masukkan Nama Produk",
                        prefixIcon: Icon(Icons.build),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Theme.of(context).primaryColor),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.0),
                    TextField(
                      controller: _updatedPrice,
                      decoration: InputDecoration(
                        labelText: "Harga Produk",
                        hintText: "Masukkan Harga Produk",
                        prefixIcon: Icon(Icons.attach_money),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Theme.of(context).primaryColor),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                    ),
                    SizedBox(height: 16.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: _cancelEdit,
                          child: Text('Batal'),
                        ),
                        SizedBox(width: 8.0),
                        TextButton(
                          onPressed: _saveEdit,
                          child: Text('Simpan'),
                        ),
                      ],
                    )
                  ],
                ),
              )
            else
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refreshItems,
                  child: _isLoading
                      ? Center(child: Text('Memuat data...'))
                      : _filteredItems.isEmpty
                      ? Center(child: Text('Tidak ada data'))
                      : ListView.builder(
                    shrinkWrap: true,
                    itemCount: _filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = _filteredItems[index];
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          title: Text(item.toString()),
                          onTap: () {
                            widget.onSelected(item.toString());
                            Navigator.of(context).pop();
                          },
                          onLongPress: () => _handleLongPress(item.toString()),
                        ),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}