import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_notifier.dart';

/// Placeholder Me page for authenticated users.
/// Full implementation is out of scope for this feature.
class MePage extends ConsumerWidget {
  const MePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Me')),
      body: Center(
        child: TextButton(
          onPressed: () => ref.read(authProvider.notifier).logout(),
          child: const Text('Log out'),
        ),
      ),
    );
  }
}
