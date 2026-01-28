import 'package:flutter/material.dart';
import '../services/settings_service.dart';

class SettingsPage extends StatefulWidget {
  final bool performanceMode;
  final Function(bool) onPerformanceModeChanged;

  const SettingsPage({
    super.key,
    required this.performanceMode,
    required this.onPerformanceModeChanged,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final SettingsService _settingsService = SettingsService();
  late bool _performanceMode;

  @override
  void initState() {
    super.initState();
    _performanceMode = widget.performanceMode;
  }

  Future<void> _togglePerformanceMode(bool value) async {
    setState(() {
      _performanceMode = value;
    });
    await _settingsService.setPerformanceMode(value);
    widget.onPerformanceModeChanged(value);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            value ? 'Mode Performance activé' : 'Mode Performance désactivé',
          ),
        ),
      );
    }
  }

  Future<void> _clearAllData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Effacer toutes les données'),
        content: const Text(
          'Voulez-vous vraiment supprimer toutes les listes enregistrées et réinitialiser tous les paramètres ? Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Effacer tout'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _settingsService.clearAllData();
      setState(() {
        _performanceMode = false;
      });
      widget.onPerformanceModeChanged(false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Toutes les données ont été effacées'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
        backgroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Apparence',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: SwitchListTile(
              title: const Text('Mode Performance'),
              subtitle: const Text(
                'Désactive les effets visuels pour améliorer les performances',
              ),
              value: _performanceMode,
              onChanged: _togglePerformanceMode,
              secondary: Icon(
                _performanceMode ? Icons.speed : Icons.auto_awesome,
                color: Colors.teal,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Données',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text('Effacer toutes les données'),
              subtitle: const Text(
                'Supprime toutes les listes et réinitialise les paramètres',
              ),
              onTap: _clearAllData,
            ),
          ),
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'À propos',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline, color: Colors.teal),
                  title: const Text('Version'),
                  trailing: const Text('1.0.0'),
                ),
                ListTile(
                  leading: const Icon(Icons.shopping_cart, color: Colors.teal),
                  title: const Text('Liste de Courses'),
                  subtitle: const Text('Application de gestion de courses'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
