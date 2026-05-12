import 'package:flutter/material.dart';
import '../models/models.dart';

class AppState extends ChangeNotifier {
  final UserProfile user = UserProfile(
    id: 'user_1',
    name: 'Alexandre',
    balance: 2500.0, // Initial balance in rupees
    upcomingOrders: [],
  );

  List<CartItem> cart = [];
  bool addWoodenCutlery = false;
  final double cutleryPrice = 10.0;

  void addToCart(Meal meal, DateTime deliveryDate) {
    // Check if already in cart for same date
    final existingIndex = cart.indexWhere(
        (item) => item.meal.id == meal.id && isSameDay(item.deliveryDate, deliveryDate));
    
    if (existingIndex >= 0) {
      cart[existingIndex].quantity += 1;
    } else {
      cart.add(CartItem(meal: meal, quantity: 1, deliveryDate: deliveryDate));
    }
    notifyListeners();
  }

  void updateQuantity(CartItem item, int newQuantity) {
    final index = cart.indexOf(item);
    if (index >= 0) {
      if (newQuantity <= 0) {
        cart.removeAt(index);
      } else {
        cart[index].quantity = newQuantity;
      }
      notifyListeners();
    }
  }

  void toggleCutlery(bool? value) {
    addWoodenCutlery = value ?? false;
    notifyListeners();
  }

  double get subtotal {
    return cart.fold(0, (sum, item) => sum + (item.meal.price * item.quantity));
  }

  double get total {
    return subtotal + (addWoodenCutlery ? cutleryPrice : 0);
  }

  bool checkout() {
    if (user.balance >= total && cart.isNotEmpty) {
      user.balance -= total;
      
      // Add to upcoming orders
      for (var item in cart) {
        user.upcomingOrders.add(Order(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          items: [item],
          totalAmount: (item.meal.price * item.quantity) + (addWoodenCutlery ? cutleryPrice / cart.length : 0),
          orderDate: DateTime.now(),
          status: 'confirmed',
          qrCodeData: 'ST-${DateTime.now().millisecondsSinceEpoch}',
        ));
      }
      
      cart.clear();
      addWoodenCutlery = false;
      notifyListeners();
      return true;
    }
    return false;
  }

  void cancelOrder(Order order) {
    user.upcomingOrders.removeWhere((o) => o.id == order.id);
    user.balance += order.totalAmount; // Refund
    notifyListeners();
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
