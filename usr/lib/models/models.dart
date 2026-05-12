import 'package:flutter/foundation.dart';

class Meal {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final List<String> ingredients;
  final String nutritionalValues;
  final bool isVegetarian;

  const Meal({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.ingredients,
    required this.nutritionalValues,
    this.isVegetarian = false,
  });
}

class CartItem {
  final Meal meal;
  final DateTime date;
  int quantity;

  CartItem({
    required this.meal,
    required this.date,
    this.quantity = 1,
  });
}

class Order {
  final String id;
  final List<CartItem> items;
  final double total;
  final bool includesCutlery;
  final DateTime orderDate;
  final String status;

  Order({
    required this.id,
    required this.items,
    required this.total,
    required this.includesCutlery,
    required this.orderDate,
    this.status = 'Confirmé',
  });
}

class AppState extends ChangeNotifier {
  final List<Meal> _meals = [
    Meal(
      id: '1',
      name: 'Poke Bowl Saumon',
      description: 'Délicieux poke bowl au saumon frais, avocat et mangue.',
      price: 350,
      imageUrl: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&q=80&w=800',
      ingredients: ['Riz vinaigré', 'Saumon', 'Avocat', 'Mangue', 'Edamame', 'Graines de sésame'],
      nutritionalValues: '450 kcal | Protéines: 25g | Glucides: 45g | Lipides: 18g',
    ),
    Meal(
      id: '2',
      name: 'Salade de Pâtes Estivale',
      description: 'Pâtes complètes avec tomates cerises, mozzarella et pesto.',
      price: 280,
      imageUrl: 'https://images.unsplash.com/photo-1626844131082-256783844137?auto=format&fit=crop&q=80&w=800',
      ingredients: ['Pâtes complètes', 'Tomates cerises', 'Billes de mozzarella', 'Pesto basilic', 'Pignons de pin'],
      nutritionalValues: '380 kcal | Protéines: 15g | Glucides: 50g | Lipides: 12g',
      isVegetarian: true,
    ),
    Meal(
      id: '3',
      name: 'Salade de Riz Thaï',
      description: 'Riz aux crevettes, cacahuètes, citron vert et coriandre.',
      price: 320,
      imageUrl: 'https://images.unsplash.com/photo-1512003867696-6d5ce6835040?auto=format&fit=crop&q=80&w=800',
      ingredients: ['Riz basmati', 'Crevettes', 'Cacahuètes', 'Concombre', 'Coriandre', 'Citron vert'],
      nutritionalValues: '410 kcal | Protéines: 22g | Glucides: 48g | Lipides: 14g',
    ),
    Meal(
      id: '4',
      name: 'Plat Végé Protéiné',
      description: 'Quinoa, tofu fumé, patate douce rôtie et brocoli.',
      price: 300,
      imageUrl: 'https://images.unsplash.com/photo-1540420773420-3366772f4999?auto=format&fit=crop&q=80&w=800',
      ingredients: ['Quinoa', 'Tofu fumé', 'Patate douce', 'Brocoli', 'Graines de courge'],
      nutritionalValues: '390 kcal | Protéines: 20g | Glucides: 55g | Lipides: 10g',
      isVegetarian: true,
    ),
  ];

  final List<CartItem> _cart = [];
  final List<Order> _orders = [];
  double _accountBalance = 2500.0;
  bool _includeWoodenCutlery = false;

  List<Meal> get meals => _meals;
  List<CartItem> get cart => _cart;
  List<Order> get orders => _orders;
  double get accountBalance => _accountBalance;
  bool get includeWoodenCutlery => _includeWoodenCutlery;

  double get cartSubtotal {
    return _cart.fold(0.0, (sum, item) => sum + (item.meal.price * item.quantity));
  }

  double get cartTotal {
    double total = cartSubtotal;
    if (_includeWoodenCutlery) {
      total += 10.0; // Prix des couverts en bois
    }
    return total;
  }

  void addToCart(Meal meal, DateTime date) {
    var existingItem = _cart.where((item) => item.meal.id == meal.id && isSameDay(item.date, date)).firstOrNull;
    
    if (existingItem != null) {
      existingItem.quantity++;
    } else {
      _cart.add(CartItem(meal: meal, date: date));
    }
    notifyListeners();
  }

  void updateQuantity(CartItem item, int delta) {
    item.quantity += delta;
    if (item.quantity <= 0) {
      _cart.remove(item);
    }
    notifyListeners();
  }

  void toggleCutlery(bool value) {
    _includeWoodenCutlery = value;
    notifyListeners();
  }

  bool checkout() {
    if (_cart.isEmpty) return false;
    if (_accountBalance >= cartTotal) {
      _accountBalance -= cartTotal;
      final newOrder = Order(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        items: List.from(_cart),
        total: cartTotal,
        includesCutlery: _includeWoodenCutlery,
        orderDate: DateTime.now(),
      );
      _orders.insert(0, newOrder);
      _cart.clear();
      _includeWoodenCutlery = false;
      notifyListeners();
      return true;
    }
    return false;
  }

  void cancelOrder(Order order) {
    if (order.status != 'Annulé') {
      _accountBalance += order.total;
      final index = _orders.indexOf(order);
      if (index != -1) {
        _orders[index] = Order(
          id: order.id,
          items: order.items,
          total: order.total,
          includesCutlery: order.includesCutlery,
          orderDate: order.orderDate,
          status: 'Annulé',
        );
        notifyListeners();
      }
    }
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
