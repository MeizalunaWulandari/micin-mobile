import 'package:flutter/material.dart';
import '../models/provider.dart';

class ProviderCard extends StatelessWidget {
  final ProviderItem provider;
  final VoidCallback onTap;

  const ProviderCard({Key? key, required this.provider, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        title: Text(provider.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(provider.description),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}
