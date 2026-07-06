import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../providers/auth_notifier.dart';
import '../providers/auth_state.dart';
import '../widgets/email_login_form.dart';
import '../widgets/login_header.dart';
import '../widgets/social_login_button.dart';

/// The "Me" tab content when the user is not logged in.
/// The bottom navigation bar remains visible (provided by the shell route).
class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final isLoading = authState is AuthLoading;

    final errorMessage = switch (authState) {
      AuthError(:final failure) => _mapFailureMessage(failure),
      _ => null,
    };

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  LoginHeader(), // 顶部随着整页滚动

                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.xxl,
                      AppSpacing.xxxl,
                      AppSpacing.xxl,
                      AppSpacing.xxl,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          AppStrings.loginTitle,
                          style: AppTypography.headlineSmall,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          AppStrings.loginSubtitle,
                          style: AppTypography.bodyMedium.copyWith(
                            color: const Color(0xFF888888),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.xxxl),
                        EmailLoginForm(
                          isLoading: isLoading,
                          errorMessage: errorMessage,
                          onSubmit: ({required email, required password}) {
                            ref
                                .read(authProvider.notifier)
                                .loginWithEmail(
                                  email: email,
                                  password: password,
                                );
                          },
                          onForgotPassword: () {
                            // TODO: Navigate to Forgot Password page.
                          },
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                        _buildDivider(),
                        const SizedBox(height: AppSpacing.xl),
                        SocialLoginButton(
                          label: AppStrings.loginGoogle,
                          isLoading: isLoading,
                          icon: _GoogleIcon(),
                          onTap: () =>
                              ref.read(authProvider.notifier).loginWithGoogle(),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        SocialLoginButton(
                          label: AppStrings.loginFacebook,
                          isLoading: isLoading,
                          icon: _FacebookIcon(),
                          onTap: () => ref
                              .read(authProvider.notifier)
                              .loginWithFacebook(),
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                        _buildSignUpRow(context),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(
            AppStrings.loginOrWith,
            style: AppTypography.labelSmall.copyWith(
              color: const Color(0xFF888888),
            ),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }

  Widget _buildSignUpRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          AppStrings.loginNoAccount,
          style: AppTypography.bodyMedium.copyWith(
            color: const Color(0xFF888888),
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        GestureDetector(
          onTap: () {
            // TODO: Navigate to Sign Up page.
          },
          child: Text(
            AppStrings.loginSignUp,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  String? _mapFailureMessage(Failure failure) => switch (failure) {
    NetworkFailure() => AppStrings.errorNetwork,
    UnauthorizedFailure() => AppStrings.validationIncorrectPassword,
    ServerFailure(:final message) => message,
    _ => AppStrings.errorLoginFailed,
  };
}

/// Google "G" logo painted with the brand colours.
class _GoogleIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const SizedBox(width: 20, height: 20, child: _GoogleLogoPainter());
  }
}

class _GoogleLogoPainter extends StatelessWidget {
  const _GoogleLogoPainter();

  @override
  Widget build(BuildContext context) {
    // Simple coloured "G" text as a stand-in until a real SVG asset is provided.
    return const Text(
      'G',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF4285F4),
        height: 1,
      ),
    );
  }
}

class _FacebookIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Icon(Icons.facebook, color: Color(0xFF1877F2), size: 22);
  }
}
