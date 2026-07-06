import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/explonz_logo.dart';
import '../providers/launch_notifier.dart';

class LaunchPage extends ConsumerWidget {
  const LaunchPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<LaunchDestination>>(launchProvider, (_, next) {
      next.whenData((destination) {
        switch (destination) {
          case LaunchDestination.permissions:
            context.go(AppRoutes.permissions);
          case LaunchDestination.home:
            context.go(AppRoutes.discover);
        }
      });
    });

    return const Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.highlight, AppColors.primary],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: ExplonzLogo(variant: ExplonzLogoVariant.onDark, height: 48),
        ),
      ),
    );
  }
}
