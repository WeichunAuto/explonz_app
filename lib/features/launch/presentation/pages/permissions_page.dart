import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/explonz_logo.dart';
import '../../../auth/data/datasources/auth_local_datasource.dart';

class PermissionsPage extends ConsumerStatefulWidget {
  const PermissionsPage({super.key});

  @override
  ConsumerState<PermissionsPage> createState() => _PermissionsPageState();
}

class _PermissionsPageState extends ConsumerState<PermissionsPage> {
  bool _isLoading = false;

  Future<void> _onAllow() async {
    setState(() => _isLoading = true);
    await ref.read(notificationServiceProvider).requestPermission();
    await _completeAndNavigate();
  }

  Future<void> _onLater() => _completeAndNavigate();

  Future<void> _completeAndNavigate() async {
    await ref.read(authLocalDatasourceProvider).setFirstLaunchDone();
    if (mounted) context.go(AppRoutes.discover);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F4),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.xxl),
              const ExplonzLogo(
                variant: ExplonzLogoVariant.onLight,
                height: 36,
              ),
              const Spacer(),
              _buildIllustration(),
              const SizedBox(height: AppSpacing.xxxl),
              Text(
                AppStrings.permissionsTitle,
                style: AppTypography.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                AppStrings.permissionsSubtitle,
                style: AppTypography.bodyMedium.copyWith(
                  color: const Color(0xFF888888),
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              _buildAllowButton(),
              const SizedBox(height: AppSpacing.lg),
              TextButton(
                onPressed: _isLoading ? null : _onLater,
                child: Text(
                  AppStrings.permissionsLater,
                  style: AppTypography.labelLarge.copyWith(
                    color: const Color(0xFF888888),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIllustration() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.xlAll,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.15),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Icon(
        Icons.notifications_active_outlined,
        size: 56,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildAllowButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.highlight, AppColors.primary],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: AppRadius.fullAll,
        ),
        child: ElevatedButton.icon(
          onPressed: _isLoading ? null : _onAllow,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: AppRadius.fullAll),
          ),
          icon: _isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.arrow_forward, color: Colors.white),
          label: Text(
            AppStrings.permissionsAllow,
            style: AppTypography.labelLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
