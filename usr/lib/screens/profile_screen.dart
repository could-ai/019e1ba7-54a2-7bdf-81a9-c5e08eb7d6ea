import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(title: const Text('Mon Profil')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: Colors.green.shade50,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Icon(Icons.account_balance_wallet, size: 48, color: Colors.green),
                  const SizedBox(height: 8),
                  const Text('Solde du compte', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  Text(
                    '${appState.accountBalance} ₹',
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Mes commandes', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          if (appState.orders.isEmpty)
            const Center(child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Text('Aucune commande.'),
            ))
          else
            ...appState.orders.map((order) => Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Commande #${order.id.substring(order.id.length - 4)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text('${order.total} ₹', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Statut: ${order.status}', style: TextStyle(color: order.status == 'Annulé' ? Colors.red : Colors.green)),
                    const Divider(),
                    ...order.items.map((item) => Text('${item.quantity}x ${item.meal.name} (${item.date.day}/${item.date.month})')),
                    if (order.includesCutlery)
                      const Text('1x Couverts en bois'),
                    const SizedBox(height: 16),
                    if (order.status != 'Annulé')
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Annuler la commande ?'),
                                content: const Text('Voulez-vous vraiment annuler cette commande ? Le montant sera remboursé sur votre solde.'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Non')),
                                  TextButton(
                                    onPressed: () {
                                      appState.cancelOrder(order);
                                      Navigator.pop(context);
                                    },
                                    child: const Text('Oui, annuler', style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              ),
                            );
                          },
                          icon: const Icon(Icons.cancel, color: Colors.red),
                          label: const Text('Annuler', style: TextStyle(color: Colors.red)),
                        ),
                      ),
                  ],
                ),
              ),
            )).toList(),
        ],
      ),
    );
  }
}
