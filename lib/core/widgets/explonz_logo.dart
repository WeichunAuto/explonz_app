import 'package:flutter/widgets.dart';

enum ExplonzLogoVariant { onDark, onLight }

/// Displays the Explonz brand lockup (icon + wordmark).
///
/// Use [ExplonzLogoVariant.onDark] on gradient / coloured backgrounds.
/// Use [ExplonzLogoVariant.onLight] on white / light backgrounds.
class ExplonzLogo extends StatelessWidget {
  const ExplonzLogo({
    super.key,
    this.variant = ExplonzLogoVariant.onLight,
    this.height = 40,
  });

  final ExplonzLogoVariant variant;
  final double height;

  @override
  Widget build(BuildContext context) {
    final asset = variant == ExplonzLogoVariant.onDark
        ? 'assets/images/launch and authentication/lockup-on-dark.png'
        : 'assets/images/launch and authentication/lockup-on-light.png';

    return Image.asset(asset, height: height, fit: BoxFit.contain);
  }
}
