import 'package:flutter/material.dart';
import 'package:esc_pos_bluetooth/esc_pos_bluetooth.dart';
import 'package:flutter_bluetooth_basic/flutter_bluetooth_basic.dart';
import 'package:intl/intl.dart';
import 'print.dart'; // Import halaman Print

class TransactionReceiptPage extends StatefulWidget {
  final String pelanggan;
  final String jenisKendaraan;
  final List<Map<String, dynamic>> jasa;
  final List<Map<String, dynamic>> produk;
  final String total;

  TransactionReceiptPage({
    required this.pelanggan,
    required this.jenisKendaraan,
    required this.jasa,
    required this.produk,
    required this.total,
  });

  @override
  _TransactionReceiptPageState createState() => _TransactionReceiptPageState();
}

class _TransactionReceiptPageState extends State<TransactionReceiptPage> {
  List<Map<String, dynamic>> generateDetailItems() {
    String formattedDate = DateFormat('dd MMM yyyy, HH:mm').format(DateTime.now());

    List<Map<String, dynamic>> items = [
      {'title': 'Pelanggan', 'value': widget.pelanggan},
      {'title': 'Kendaraan', 'value': widget.jenisKendaraan},
      {'title': 'Tanggal', 'value': formattedDate},
    ];

    for (var produkItem in widget.produk) {

      items.add({
        'title': produkItem['name'],
        'value': '${produkItem['quantity'].toString() +' x '+ formatCurrency(produkItem['price'].toString())}',
        'isProduct': true
      });
    }

    for (var jasaItem in widget.jasa) {
      items.add({
        'title': jasaItem['serviceName'],
        'value': '${formatCurrency(jasaItem['ongkos'].toString())}',
        'isService': true
      });
    }

    items.add({
      'title': 'Total',
      'value': '${formatCurrency(widget.total)}',
      'isTotal': true
    });

    return items;
  }
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

  String formatCurrency(String value) {
    if (value.isEmpty) return '';
    final formatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return formatter.format(double.parse(value));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nota Transaksi'),
        // actions: [
        //   IconButton(
        //     icon: Icon(Icons.print),
        //     onPressed: _selectedPrinter != null
        //         ? () => Print.printTicket(context, generateDetailItems(), _selectedPrinter!)
        //         : _startScan,
        //   ),
        // ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'Bengkel Motor SRM',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 20),
              _buildInfoRow('Tanggal',
                  DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())),
              _buildInfoRow('Pelanggan', widget.pelanggan),
              _buildInfoRow('Kendaraan', widget.jenisKendaraan),
              // _buildInfoRow('Mekanik', widget.mekanik),
              SizedBox(height: 20),
              Text('Produk:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ...widget.produk.map((item) => _buildProductItem(
                  item['name'], item['quantity'], item['price'])),
              SizedBox(height: 20),
              Text('Jasa:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ...widget.jasa.map((item) =>
                  _buildServiceItem(item['serviceName'], item['ongkos'])),
              Divider(thickness: 2),
              _buildInfoRow('Total', formatCurrency(widget.total),
                  isBold: true),
              SizedBox(height: 30),
              Center(
                child: Text(
                  'Terima kasih atas kunjungan Anda!',
                  style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                ),
              ),
              SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBluetoothStatus(),
                  SizedBox(height: 20),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: 100,
              child: Text(
                label,
                style: TextStyle(fontWeight: FontWeight.bold),
              )),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal),
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildServiceItem(String name, double ongkos) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name),
          Text(formatCurrency(ongkos.toString())),
        ],
      ),
    );
  }

  Widget _buildProductItem(String name, int quantity, int price) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(name)),
          Text('$quantity x ${formatCurrency(price.toString())}'),
          SizedBox(width: 10),
          Text(formatCurrency((quantity * price).toString())),
        ],
      ),
    );
  }

  Widget _buildBluetoothStatus() {
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
                      ? () => Print.printTicket(context, generateDetailItems(), _selectedPrinter!)
                      : _startScan,
              icon: Icon(Icons.print),
          )
        ],
      ),
    );
  }

  // List<Map<String, dynamic>> _prepareDataForPrinting() {
  //   return [
  //     {'title': 'Customer', 'value': widget.pelanggan},
  //     {'title': 'Vehicle', 'value': widget.jenisKendaraan},
  //     ...widget.jasa.map((item) => {
  //           'title': item['serviceName'],
  //           'value': item['ongkos'].toString(),
  //           'isService': true,
  //         }),
  //     ...widget.produk.map((item) => {
  //           'title': '${item['name']} x${item['quantity']}',
  //           'value': (item['price'] * item['quantity']).toString(),
  //           'isProduct': true,
  //         }),
  //     {'title': 'Total', 'value': widget.total, 'isTotal': true},
  //   ];
  // }

  void _showNotification(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
