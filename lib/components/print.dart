import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart' hide Image;
import 'package:esc_pos_bluetooth/esc_pos_bluetooth.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:permission_handler/permission_handler.dart';

class Print {
  static Future<void> printTicket(BuildContext context,
      List<Map<String, dynamic>> data, PrinterBluetooth printer) async {
    if (await _checkPermissions()) {
      await _startPrint(context, printer, data);
    } else {
      _showNotification(
          context, 'Perlu Perizinan Bluetooth untuk memulai print.');
    }
  }

  static Future<bool> _checkPermissions() async {
    if (await Permission.bluetoothScan.isGranted &&
        await Permission.bluetoothConnect.isGranted &&
        await Permission.location.isGranted) {
      return true;
    } else {
      await [
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.location,
      ].request();
      return await Permission.bluetoothScan.isGranted &&
          await Permission.bluetoothConnect.isGranted &&
          await Permission.location.isGranted;
    }
  }

  static Future<void> _startPrint(BuildContext context,
      PrinterBluetooth printer, List<Map<String, dynamic>> data) async {
    try {
      final result = await _attemptPrint(printer, data);
      _showPrintResult(context, result);
    } catch (e) {
      print("Printing error: $e");
      _showNotification(
          context, 'Gagal print. Cek Koneksi Bluetooth dengan print.');
    }
  }

  static Future<PosPrintResult> _attemptPrint(PrinterBluetooth printer, List<Map<String, dynamic>> data) async {
    PrinterBluetoothManager printerManager = PrinterBluetoothManager();
    printerManager.selectPrinter(printer);

    final PosPrintResult result = await printerManager.printTicket(await _generateTicket(PaperSize.mm80, data));
    return result;
  }

  static void _showNotification(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  static void _showPrintResult(BuildContext context, PosPrintResult result) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(result == PosPrintResult.success
            ? 'Print Berhasil'
            : 'Print Gagal'),
        content: Text(_getPrintResultMessage(result)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  static String _getPrintResultMessage(PosPrintResult result) {
    switch (result) {
      case PosPrintResult.success:
        return 'Print berhasil.';
      case PosPrintResult.timeout:
        return 'Print gagal, reset dan coba lagi.';
      case PosPrintResult.printerNotSelected:
        return 'Tidak ada printer yang dipilih.';
      case PosPrintResult.ticketEmpty:
        return 'Tiket kosong.';
      case PosPrintResult.printInProgress:
        return 'Pinter sedang dalam proses.';
      case PosPrintResult.scanInProgress:
        return 'Bluetooth scan dalam proses.';
      default:
        return 'An unknown error occurred.';
    }
  }

  static Future<List<int>> _generateTicket(PaperSize paper, List<Map<String, dynamic>> data) async {
    final profile = await CapabilityProfile.load();
    final Generator generator = Generator(paper, profile);
    List<int> bytes = [];

    // Add logo
    try {
      final ByteData imageData = await rootBundle.load('assets/srm.png');
      final Uint8List bytesImage = imageData.buffer.asUint8List();
      final img.Image? image = img.decodeImage(bytesImage);
      if (image != null) {
        bytes += generator.image(image);
      }
    } catch (e) {
      print("Error loading logo: $e");
    }

    // Add header
    bytes += generator.text(
      'Sri Rejeki Motor',
      styles: PosStyles(align: PosAlign.center, height: PosTextSize.size2, width: PosTextSize.size2),
      linesAfter: 1,
    );
    bytes += generator.text('Jl. Adi Sucipto No 20, Ngaglik, Menadi, Pacitan', styles: PosStyles(align: PosAlign.center, bold: true));
    bytes += generator.text('(Barat Pasar Kambil)', styles: PosStyles(align: PosAlign.center, bold: true));
    bytes += generator.text('085335746375 / 087858227988', styles: PosStyles(align: PosAlign.center, bold: true));
    bytes += generator.feed(1);

    // Add transaction details
    for (var item in data) {
      final title = item['title'];
      final value = item['value'];
      final bool isService = item['isService'] ?? false;
      final bool isProduct = item['isProduct'] ?? false;
      final bool isTotal = item['isTotal'] ?? false;
      int lineLength = (paper == PaperSize.mm80) ? 32 : 24;

      if (title == 'Tanggal') {
        bytes += _formatLine(generator, title, value);
        bytes += generator.text(
          '-' * lineLength,
          styles: PosStyles(align: PosAlign.center),
        );
      } else if (isTotal) {
        // Add a separator before the total section
        bytes += generator.text(
          '-' * lineLength,
          styles: PosStyles(align: PosAlign.center),
        );
        bytes += _formatLine(generator, title, value, bold: true);
      } else if (isService || isProduct) {
        // Add service/product details with indentation
        bytes += _formatLine(generator, title, value, indent: 2);
      } else {
        // For all other items, format without indentation
        bytes += _formatLine(generator, title, value);
      }
    }

    // Add footer
    bytes += generator.feed(2);
    bytes += generator.text('Terima kasih', styles: PosStyles(align: PosAlign.center, bold: true));
    bytes += generator.text('atas kepercayaan Anda!', styles: PosStyles(align: PosAlign.center, bold: true));
    bytes += generator.cut();

    return bytes;
  }

  static List<int> _formatLine(Generator generator, String left, String right, {bool bold = false, int indent = 0}) {
    final int maxChar = 32; // Adjust based on your printer's characters per line
    final rightLength = right.length;
    final List<int> result = [];

    // Split left text into words
    final words = left.split(' ');
    String currentLine = ' ' * indent;
    List<String> lines = [];

    // Process words to create lines
    for (String word in words) {
      // Check if adding this word would exceed the line length
      if ((currentLine + word).length > maxChar - rightLength) {
        // If current line is not empty, add it to lines
        if (currentLine.trim().isNotEmpty) {
          lines.add(currentLine);
        }
        currentLine = ' ' * indent + word + '  ';
      } else {
        currentLine += word + ' ';
      }
    }

    // Add the last line if not empty
    if (currentLine.trim().isNotEmpty) {
      lines.add(currentLine);
    }

    // Process all lines except the last one
    for (int i = 0; i < lines.length - 1; i++) {
      result.addAll(generator.text(
        lines[i].trimRight(),
        styles: PosStyles(bold: bold),
      ));
    }

    // Process the last line with right text
    if (lines.isNotEmpty) {
      String lastLine = lines.last.trimRight();
      lastLine = lastLine.padRight(maxChar - rightLength);
      lastLine += right;

      result.addAll(generator.text(
        lastLine,
        styles: PosStyles(bold: bold),
      ));
    } else {
      result.addAll(generator.text(
        ' ' * (maxChar - rightLength) + right,
        styles: PosStyles(bold: bold),
      ));
    }

    return result;
  }
}
