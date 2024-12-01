import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:srm_v1/components/print.dart';
import '../services/firestore_services.dart';
import 'package:esc_pos_bluetooth/esc_pos_bluetooth.dart';
import 'package:flutter_bluetooth_basic/flutter_bluetooth_basic.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _dbService = DatabaseService();
  TextEditingController _searchController = TextEditingController();
  DateTimeRange _selectedDateRange = DateTimeRange(
    start: DateTime.now().subtract(Duration(
      hours: DateTime.now().hour,
      minutes: DateTime.now().minute,
      seconds: DateTime.now().second,
      milliseconds: DateTime.now().millisecond,
      microseconds: DateTime.now().microsecond,
    )),
    end: DateTime.now().add(Duration(
      hours: 23 - DateTime.now().hour,
      minutes: 59 - DateTime.now().minute,
      seconds: 59 - DateTime.now().second,
    )),
  );

  PrinterBluetoothManager _printerManager = PrinterBluetoothManager();
  BluetoothManager _bluetoothManager = BluetoothManager.instance;
  bool _isScanning = false;
  PrinterBluetooth? _selectedPrinter;

  @override
  void initState() {
    super.initState();
    _initBluetooth();
  }

  @override
  void dispose() {
    _printerManager.stopScan();
    _searchController.dispose();
    super.dispose();
  }

  void _initBluetooth() {
    _bluetoothManager.state.listen((val) {
      if (val == BluetoothManager.CONNECTED) {
        print('Bluetooth device state: ON');
        _startScan();
      } else if (val == BluetoothManager.DISCONNECTED) {
        print('Bluetooth device state: OFF');
        _showNotification('Please turn on Bluetooth');
        setState(() {
          _selectedPrinter = null;
          _isScanning = false;
        });
      }
    });
  }

  void _startScan() {
    if (_isScanning) return;
    setState(() {
      _isScanning = true;
    });
    _printerManager.startScan(Duration(seconds: 4));
    _printerManager.scanResults.listen((devices) {
      if (devices.isNotEmpty) {
        setState(() {
          _selectedPrinter = devices.first;
          _isScanning = false;
        });
        _printerManager.stopScan();
      }
    });

    // Ensure scanning stops after a timeout
    Future.delayed(Duration(seconds: 5), () {
      if (mounted && _isScanning) {
        setState(() {
          _isScanning = false;
        });
        _printerManager.stopScan();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Cari berdasarkan nama...',
            border: InputBorder.none,
          ),
          onChanged: (query) {
            setState(() {});
          },
        ),
        elevation: 0,
        backgroundColor: Color(0xFFE6F3FF),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: _pickDateRange,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<QueryDocumentSnapshot>>(
              future: _dbService.readTransaction(),
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

                List<QueryDocumentSnapshot> filteredData =
                    _filterAndSortData(snapshot.data!);

                return ListView.builder(
                  itemCount: filteredData.length,
                  itemBuilder: (context, index) {
                    var transactionData =
                        filteredData[index].data() as Map<String, dynamic>;
                    return _buildTransactionCard(context, transactionData);
                  },
                );
              },
            ),
          ),
        ],
        // _buildBluetoothStatus(),
      ),
    );
  }

  Widget _buildBluetoothStatus(detailItems) {
    return Container(
      padding: EdgeInsets.all(8),
      color: Colors.blue[100],
      child: Row(
        children: [
          Icon(_selectedPrinter != null
              ? Icons.bluetooth_connected
              : Icons.bluetooth_disabled),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              _selectedPrinter != null
                  ? 'Connected to ${_selectedPrinter!.name}'
                  : _isScanning
                      ? 'Scanning for printers...'
                      : 'No printer connected',
            ),
          ),
          IconButton(
            onPressed: _selectedPrinter != null
                ? () =>
                    Print.printTicket(context, detailItems, _selectedPrinter!)
                : _startScan,
            icon: Icon(Icons.print),
          )
        ],
      ),
    );
  }

  List<QueryDocumentSnapshot> _filterAndSortData(
      List<QueryDocumentSnapshot> data) {
    return data.where((doc) {
      var transactionData = doc.data() as Map<String, dynamic>;
      Timestamp timestamp = transactionData['tanggalTransaksi'];
      DateTime dateTime = timestamp.toDate();

      bool withinDateRange = dateTime.isAfter(_selectedDateRange.start) &&
          dateTime.isBefore(_selectedDateRange.end.add(Duration(days: 1)));

      bool matchesSearchQuery = transactionData['namaPelanggan']
          .toString()
          .toLowerCase()
          .contains(_searchController.text.toLowerCase());

      return withinDateRange && matchesSearchQuery;
    }).toList()
      ..sort((a, b) {
        var aData = a.data() as Map<String, dynamic>;
        var bData = b.data() as Map<String, dynamic>;
        Timestamp aTimestamp = aData['tanggalTransaksi'];
        Timestamp bTimestamp = bData['tanggalTransaksi'];
        return bTimestamp
            .compareTo(aTimestamp); // Reverse order for newest first
      });
  }

  Widget _buildTransactionCard(
      BuildContext context, Map<String, dynamic> transactionData) {
    Timestamp timestamp = transactionData['tanggalTransaksi'];
    DateTime dateTime = timestamp.toDate();
    String formattedDate = DateFormat('dd MMM yyyy, HH:mm').format(dateTime);

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showTransactionDetail(context, transactionData),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    transactionData['namaPelanggan'],
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    transactionData['jenisKendaraan'],
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
              SizedBox(height: 4),
              Text(
                'Tanggal: $formattedDate',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              SizedBox(height: 8),
              Text(
                'Total: ${formatCurrency(transactionData['total'])}',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.green),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDateRange() async {
    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: _selectedDateRange,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _selectedDateRange) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  String formatCurrency(dynamic value) {
    if (value == null) return '';
    double parsedValue;
    if (value is String) {
      parsedValue = double.tryParse(value) ?? 0.0;
    } else if (value is int) {
      parsedValue = value.toDouble();
    } else {
      parsedValue = value;
    }
    final formatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return formatter.format(parsedValue);
  }

  void _showTransactionDetail(
      BuildContext context, Map<String, dynamic> transactionData) {
    Timestamp timestamp = transactionData['tanggalTransaksi'];
    DateTime dateTime = timestamp.toDate();
    String formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(dateTime);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (_, controller) {
            return SingleChildScrollView(
              controller: controller,
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Header
                    Text(
                      'Detail Transaksi',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.left,
                    ),
                    SizedBox(height: 20),

                    // Basic Info
                    _buildDetailRow('Tanggal', formattedDate),
                    _buildDetailRow('Pelanggan', transactionData['namaPelanggan']),
                    _buildDetailRow('Kendaraan', transactionData['jenisKendaraan']),
                    _buildDetailRow('mekanik', transactionData['mekanik']),
                    // Products Section
                    SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Produk:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ...(transactionData['produk'] as List<dynamic>).map((produk) =>
                        _buildProductRow(
                          produk['name'],
                          produk['quantity'],
                          produk['price'],
                        ),
                    ),

                    // Services Section
                    SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Jasa:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ...(transactionData['jasa'] as List<dynamic>).map((jasa) =>
                        _buildDetailRow(
                          jasa['serviceName'],
                          formatCurrency(jasa['ongkos']),
                        ),
                    ),

                    // Divider before total
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Divider(thickness: 1),
                    ),

                    // Total
                    _buildDetailRow(
                      'Total',
                      formatCurrency(transactionData['total']),
                      isTotal: true,
                    ),

                    // Thank you message
                    SizedBox(height: 20),
                    Text(
                      'Terima kasih atas kepercayaan Anda!',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    // Printer status
                    SizedBox(height: 20),
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.bluetooth, color: Colors.black54),
                          SizedBox(width: 10),
                          Text('No printer connected'),
                          Spacer(),
                          Icon(Icons.print, color: Colors.black54),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductRow(String name, int quantity, int price) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Text(name),
          ),
          Expanded(
            flex: 3,
            child: Text(
              '$quantity x ${formatCurrency(price)}',
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  void _showNotification(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
