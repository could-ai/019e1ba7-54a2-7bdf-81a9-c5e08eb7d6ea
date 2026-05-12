import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/models.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    if (appState.cart.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Panier')),
        body: const Center(
          child: Text('Votre panier est vide.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Panier')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: appState.cart.length,
              itemBuilder: (context, index) {
                final item = appState.cart[index];
                return ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      item.meal.imageUrl,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(item.meal.name),
                  subtitle: Text('Pour le: ${item.date.day}/${item.date.month}/${item.date.year}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () => appState.updateQuantity(item, -1),
                      ),
                      Text('${item.quantity}'),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () => appState.updateQuantity(item, 1),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CheckboxListTile(
                  title: const Text('Option couverts en bois (+10 ₹)'),
                  value: appState.includeWoodenCutlery,
                  onChanged: (value) {
                    if (value != null) appState.toggleCutlery(value);
                  },
                  activeColor: Theme.of(context).primaryColor,
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Sous-total:', style: TextStyle(fontSize: 16)),
                    Text('${appState.cartSubtotal} ₹', style: const TextStyle(fontSize: 16)),
                  ],
                ),
                if (appState.includeWoodenCutlery)
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Couverts:', style: TextStyle(fontSize: 16)),
                      Text('10 ₹', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    Text('${appState.cartTotal} ₹', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      if (appState.accountBalance < appState.cartTotal) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Solde insuffisant')),
                        );
                        return;
                      }
                      
                      if (appState.checkout()) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QrScreen(orderId: appState.orders.first.id),
                          ),
                        );
                      }
                    },
                    child: const Text('Payer et générer QR Code', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class QrScreen extends StatelessWidget {
  final String orderId;
  const QrScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Confirmation de commande')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 80),
            const SizedBox(height: 16),
            const Text('Commande validée !', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            QrImageView(
              data: orderId,
              version: QrVersions.auto,
              size: 200.0,
            ),
            const SizedBox(height: 32),
            const Text('Présentez ce QR Code pour récupérer votre repas.', textAlign: TextAlign.center),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Go back to cart (which is now empty, or we can use popUntil)
                // Better: navigate back to root
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text('Retour à l\'accueil'),
            )
          ],
        ),
      ),
    );
  }
}
