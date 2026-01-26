import 'package:flutter/material.dart';

import '../models/shopping_list.dart';
import '../services/storage_service.dart';
import '../widgets/glass_morphism.dart';

class SavedListsPage extends StatefulWidget {
  const SavedListsPage({super.key});

  @override
  State<SavedListsPage> createState() => _SavedListsPageState();
}

class _SavedListsPageState extends State<SavedListsPage> {
  final StorageService _storage = StorageService();
  List<ShoppingList> _lists = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final lists = await _storage.getAllLists();
    setState(() {
      _lists = lists;
      _loading = false;
    });
  }

  void _openDetails(ShoppingList list) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SavedListDetailPage(list: list),
      ),
    );
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Listes sauvegardées')),
      body: GradientBackground(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _lists.isEmpty
                ? const Center(child: Text('Aucune liste sauvegardée pour le moment'))
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _lists.length,
                    itemBuilder: (context, index) {
                      final l = _lists[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: GlassContainer(
                          borderRadius: 12,
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                            title: Text(
                              l.name,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(
                              '${l.productCount} articles • Total: ${l.totalPrice.toStringAsFixed(2)} €',
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                            trailing: const Icon(Icons.chevron_right, color: Colors.teal),
                            onTap: () => _openDetails(l),
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}

class SavedListDetailPage extends StatefulWidget {
  final ShoppingList list;
  const SavedListDetailPage({super.key, required this.list});

  @override
  State<SavedListDetailPage> createState() => _SavedListDetailPageState();
}

class _SavedListDetailPageState extends State<SavedListDetailPage> {
  final StorageService _storage = StorageService();

  Future<void> _delete() async {
    await _storage.deleteList(widget.list.id);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _rename() async {
    final controller = TextEditingController(text: widget.list.name);
    final result = await showDialog<String?>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Renommer la liste'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Nouveau nom'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, null), child: const Text('Annuler')),
          ElevatedButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: const Text('Enregistrer')),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      await _storage.renameList(widget.list.id, result);
      setState(() {
        widget.list.name = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final list = widget.list;
    return Scaffold(
      appBar: AppBar(title: Text(list.name)),
      body: GradientBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info cards
              Row(
                spacing: 12,
                children: [
                  Expanded(
                    child: GlassContainer(
                      borderRadius: 12,
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${list.productCount}',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Produits',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: GlassContainer(
                      borderRadius: 12,
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${list.totalPrice.toStringAsFixed(2)} €',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Prix total',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Produits',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 12),
              if (list.products.isEmpty)
                GlassContainer(
                  borderRadius: 12,
                  child: Text(
                    'Aucun produit dans cette liste',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                )
              else
                Column(
                  children: List.generate(list.products.length, (index) {
                    final p = list.products[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: GlassContainer(
                        borderRadius: 12,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    p.name.isEmpty ? '(Sans nom)' : p.name,
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Qté: ${p.quantity}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${p.total.toStringAsFixed(2)} €',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.teal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ElevatedButton.icon(
                    onPressed: _rename,
                    icon: const Icon(Icons.edit),
                    label: const Text('Renommer'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _delete,
                    icon: const Icon(Icons.delete),
                    label: const Text('Supprimer'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
