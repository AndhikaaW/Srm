// cart_database.dart
import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

part 'cart_database.g.dart';

// Entity
@entity
class CartItemEntity {

  @PrimaryKey(autoGenerate: true)
  final int? id;

  final String customerName;
  final String vehicleType;
  final String? mechanic;
  final double total;

  // Kita perlu mengkonversi Map ke String untuk menyimpan services dan products
  final String selectedServices; // JSON string
  final String selectedProducts; // JSON string

  CartItemEntity({
    this.id,
    required this.customerName,
    required this.vehicleType,
    this.mechanic,
    required this.total,
    required this.selectedServices,
    required this.selectedProducts,
  });
}

// DAO
@dao
abstract class CartItemDao {
  @Query('SELECT * FROM CartItemEntity')
  Future<List<CartItemEntity>> getAllCartItems();

  @insert
  Future<void> insertCartItem(CartItemEntity cartItem);

  @update
  Future<void> updateCartItem(CartItemEntity cartItem);

  @delete
  Future<void> deleteCartItem(CartItemEntity cartItem);

  @Query('DELETE FROM CartItemEntity WHERE id = :id')
  Future<void> deleteCartItemById(int id);
}

// Database
@Database(version: 1, entities: [CartItemEntity])
abstract class AppDatabase extends FloorDatabase {
  CartItemDao get cartItemDao;
}
