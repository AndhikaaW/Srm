import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final FirebaseFirestore _fire = FirebaseFirestore.instance;

  //sparepart
  Future<void> createSparepart({required String name,required int price, required String category}) async {
    try {
      await _fire.collection("spareparts").add({
        "name": name,
        "price": price,
        "category": category
      });
    } catch (e) {
      log(e.toString());
    }
  }
  Future<List<QueryDocumentSnapshot>> readSparepart() async {
    try {
      QuerySnapshot querySnapshot = await _fire.collection("spareparts").get();
      return querySnapshot.docs;
    } catch (e) {
      log(e.toString());
      return [];
    }
  }
  Future<void> updateSparepart({required String documentId, required String name, required int price, required String category}) async {
    try {
      await _fire.collection("spareparts").doc(documentId).update({
        "name": name,
        "price": price,
        "category": category
      });
      print("Document successfully updated!");
    } catch (e) {
      print("Error updating document: $e");
      log(e.toString());
    }
  }
  Future<void> delete(String documentId) async {
    try {
      await _fire.collection("spareparts").doc(documentId).delete();
      print("Document successfully deleted!");
    } catch (e) {
      print("Error deleting document: $e");
    }
  }

  //service
  Future<void> createService({required String serviceName}) async {
    try {
      await _fire.collection("services").add({
        "serviceName": serviceName,
      });
    } catch (e) {
      log(e.toString());
    }
  }
  Future<List<QueryDocumentSnapshot>> readService() async {
    try {
      QuerySnapshot querySnapshot = await _fire.collection("services").get();
      return querySnapshot.docs;
    } catch (e) {
      log(e.toString());
      return [];
    }
  }
  Future<void> updateService({required String documentId, required String serviceName}) async {
    try {
      await _fire.collection("services").doc(documentId).update({
        "serviceName": serviceName,
      });
      print("Document successfully updated!");
    } catch (e) {
      print("Error updating document: $e");
      log(e.toString());
    }
  }
  Future<void> deleteService(String documentId) async {
    try {
      await _fire.collection("services").doc(documentId).delete();
      print("Document successfully deleted!");
    } catch (e) {
      print("Error deleting document: $e");
    }
  }

  //transaction
  Future<void> createTransaction({required String pelanggan,required String jenisKendaraan,required String mekanik,required List<Map<String, dynamic>> jasa,required List<Map<String, dynamic>> produk,required String total}) async {
    try {
      await _fire.collection("transaction").add({
        "namaPelanggan": pelanggan,
        "jenisKendaraan": jenisKendaraan,
        "mekanik": mekanik,
        "jasa": jasa,
        "produk": produk,
        "tanggalTransaksi": Timestamp.now(),
        "total": total
      });
    } catch (e) {
      log(e.toString());
    }
  }
  Future<List<QueryDocumentSnapshot>> readTransaction() async {
    try {
      QuerySnapshot querySnapshot = await _fire.collection("transaction").get();
      return querySnapshot.docs;
    } catch (e) {
      log(e.toString());
      return [];
    }
  }
  // Future<List<QueryDocumentSnapshot>> readTransactionInDateRange(DateTime startDate, DateTime endDate) async {
//   // Ensure startDate is set to the beginning of the day
//   startDate = DateTime(startDate.year, startDate.month, startDate.day);
//
//   // Ensure endDate is set to the end of the day
//   endDate = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59, 999);
//
//   final QuerySnapshot snapshot = await _fire.collection('transactions')
//       .where('tanggalTransaksi', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
//       .where('tanggalTransaksi', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
//       .orderBy('tanggalTransaksi', descending: true)
//       .get();
//
//   return snapshot.docs;
// }
}