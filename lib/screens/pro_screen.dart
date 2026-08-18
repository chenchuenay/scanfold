import 'package:flutter/material.dart';

import '../services/pro_service.dart';
import '../theme/app_theme.dart';

class ProScreen extends StatelessWidget {
  const ProScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ProService.instance,
      builder: (context, _) {
        final service = ProService.instance;
        return Scaffold(
          appBar: AppBar(title: const Text('ScanFold Pro')),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Icon(
                Icons.auto_awesome,
                color: ScanFoldColors.amber,
                size: 52,
              ),
              const SizedBox(height: 18),
              const Text(
                'Keep your workflow clean.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              const Text(
                'Remove ads and unlock unlimited batch tools while your files remain on your device.',
                textAlign: TextAlign.center,
                style: TextStyle(color: ScanFoldColors.secondary, height: 1.4),
              ),
              const SizedBox(height: 26),
              ...const [
                _Benefit(icon: Icons.block, text: 'No visible advertising'),
                _Benefit(
                  icon: Icons.collections_outlined,
                  text: 'Unlimited batch processing',
                ),
                _Benefit(
                  icon: Icons.lock_outline,
                  text: 'Private local-first workflow',
                ),
              ],
              const SizedBox(height: 24),
              if (service.product != null)
                FilledButton(
                  onPressed: service.loading ? null : () => service.buyPro(),
                  child: Text('Unlock Pro - ${service.product!.price}'),
                )
              else
                const Text(
                  'Pro purchase is not available in this build yet.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: ScanFoldColors.muted),
                ),
              TextButton(
                onPressed: service.loading ? null : () => service.restore(),
                child: const Text('Restore purchase'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Benefit extends StatelessWidget {
  final IconData icon;
  final String text;

  const _Benefit({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: ScanFoldColors.mint),
      title: Text(text),
    );
  }
}
