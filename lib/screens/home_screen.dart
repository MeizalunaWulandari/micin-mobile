import 'package:flutter/material.dart';

import '../widgets/provider_card.dart';
import '../services/update_service.dart';
import '../services/provider_service.dart';

/// HomeScreen
///
/// - On first load, checks for app update via [UpdateService.checkUpdate].
/// - If a forced update is required (`isForceUpdate == true`), shows a non‑dismissable modal
///   with a button that opens `updateUrl` in the external browser.
/// - Otherwise, loads the list of providers from `ProviderService.fetchProviders` and displays
///   a scrollable list of reusable [ProviderCard] widgets, filtering only those where
///   `isPublish == true`.
/// - Tapping a card triggers a version‑guard check: if the app build number is lower than
///   `minRequiredBuild`, a notification is shown instead of navigation.
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _checkingUpdate = true;
  bool _forceUpdate = false;
  String? _updateUrl;
  List<ProviderItem> _providers = [];
  bool _loadingProviders = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    // 1. Check for update
    final updateInfo = await UpdateService.checkUpdate();
    if (updateInfo != null) {
      setState(() {
        _forceUpdate = updateInfo.isForceUpdate;
        _updateUrl = updateInfo.updateUrl;
        _checkingUpdate = false;
      });
      if (_forceUpdate) {
        _showForceUpdateDialog();
        return;
      }
    }
    // 2. Load providers
    final providers = await ProviderService.fetchProviders();
    setState(() {
      _providers = providers.where((p) => p.isPublish).toList();
      _loadingProviders = false;
      _checkingUpdate = false;
    });
  }

  void _showForceUpdateDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Update Required'),
        content: const Text('A new version of the app is required.'),
        actions: [
          TextButton(
            onPressed: () async {
              if (_updateUrl != null) {
                await launchUrl(Uri.parse(_updateUrl!));
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingUpdate) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: _loadingProviders
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _providers.length,
              itemBuilder: (context, index) {
                final provider = _providers[index];
                return ProviderCard(
                  provider: provider,
                  onTap: () => _handleProviderTap(provider),
                );
              },
            ),
    );
  }

  void _handleProviderTap(ProviderItem provider) {
    final currentBuild = 1; // TODO: replace with actual app build number.
    if (currentBuild < provider.minRequiredBuild) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please update the app to access ${provider.name}.'),
        ),
      );
      return;
    }
    // TODO: navigate to provider detail page using provider.slug
  }
}
