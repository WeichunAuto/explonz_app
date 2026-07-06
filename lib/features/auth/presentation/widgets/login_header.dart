import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/explonz_logo.dart';

/// Orange gradient header shown at the top of the Me-unlogin (login) page.
class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  static const _height = 220.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: _height,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.highlight, Colors.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: const SafeArea(
        bottom: false,
        child: Center(
          child: ExplonzLogo(variant: ExplonzLogoVariant.onLight, height: 48),
        ),
      ),
    );
  }
}
