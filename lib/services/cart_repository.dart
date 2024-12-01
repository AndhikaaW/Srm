
import 'dart:convert';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:srm_v1/components/transaction.dart';
import ''
    'cart_database.dart';

class CartRepository {
  static final CartRepository instance = CartRepository._init();
  static AppDatabase? _database;

  CartRepository._init();

  Future<AppDatabase> get database async {
    if (_database != null) return _database!;

    _database = await $FloorAppDatabase
        .databaseBuilder('cart_database.db')
        .build();
    return _database!;
  }

  Future<void> addToCart(CartItem item) async {
    final db = await database;

    // Konversi Map ke JSON string
    final servicesJson = jsonEncode(item.selectedServices);
    final productsJson = jsonEncode(item.selectedProducts);

    final cartEntity = CartItemEntity(
      customerName: item.customerName,
      vehicleType: item.vehicleType,
      mechanic: item.mechanic,
      total: item.total,
      selectedServices: servicesJson,
      selectedProducts: productsJson,
    );

    await db.cartItemDao.insertCartItem(cartEntity);
  }

  Future<List<CartItem>> getCartItems() async {
    final db = await database;
    final entities = await db.cartItemDao.getAllCartItems();

    return entities.map((entity) {
      return CartItem(
        id: entity.id,
        customerName: entity.customerName,
        vehicleType: entity.vehicleType,
        mechanic: entity.mechanic,
        selectedServices: Map<String, double>.from(
            jsonDecode(entity.selectedServices)
        ),
        selectedProducts: Map<String, int>.from(
            jsonDecode(entity.selectedProducts)
        ),
        total: entity.total,
      );
    }).toList();
  }

  Future<void> deleteCartItem(int id) async {
    final db = await database;
    await db.cartItemDao.deleteCartItemById(id);
  }
}