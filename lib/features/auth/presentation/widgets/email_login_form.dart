import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// Stateful email + password form.
/// All input is surfaced via [onSubmit]; no business logic lives here.
class EmailLoginForm extends StatefulWidget {
  const EmailLoginForm({
    super.key,
    required this.onSubmit,
    required this.onForgotPassword,
    this.isLoading = false,
    this.errorMessage,
  });

  final void Function({required String email, required String password})
  onSubmit;
  final VoidCallback onForgotPassword;
  final bool isLoading;
  final String? errorMessage;

  @override
  State<EmailLoginForm> createState() => _EmailLoginFormState();
}

class _EmailLoginFormState extends State<EmailLoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) return;
    widget.onSubmit(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label(AppStrings.loginEmail),
          const SizedBox(height: AppSpacing.sm),
          _emailField(),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _label(AppStrings.loginPassword),
              TextButton(
                onPressed: widget.onForgotPassword,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  AppStrings.loginForgot,
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          _passwordField(),
          if (widget.errorMessage != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              widget.errorMessage!,
              style: AppTypography.bodySmall.copyWith(color: AppColors.error),
            ),
          ],
          const SizedBox(height: AppSpacing.xxl),
          _loginButton(),
        ],
      ),
    );
  }

  Widget _label(String text) => Text(
    text,
    style: AppTypography.labelSmall.copyWith(
      color: const Color(0xFF888888),
      letterSpacing: 0.8,
    ),
  );

  Widget _emailField() => TextFormField(
    controller: _emailController,
    keyboardType: TextInputType.emailAddress,
    textInputAction: TextInputAction.next,
    decoration: InputDecoration(
      hintText: AppStrings.loginEmailHint,
      prefixIcon: const Icon(Icons.mail_outline, size: 18),
      border: OutlineInputBorder(
        borderRadius: AppRadius.lgAll,
        borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppRadius.lgAll,
        borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
      ),
      filled: true,
      fillColor: const Color(0xFFF5F5F5),
    ),
    validator: (v) {
      if (v == null || v.trim().isEmpty) {
        return AppStrings.validationEmailInvalid;
      }
      final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
      if (!emailRegex.hasMatch(v.trim())) {
        return AppStrings.validationEmailInvalid;
      }
      return null;
    },
  );

  Widget _passwordField() => TextFormField(
    controller: _passwordController,
    obscureText: _obscurePassword,
    textInputAction: TextInputAction.done,
    onFieldSubmitted: (_) => _submit(),
    decoration: InputDecoration(
      prefixIcon: const Icon(Icons.lock_outline, size: 18),
      suffixIcon: TextButton(
        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        child: Text(
          _obscurePassword ? AppStrings.loginShow : AppStrings.loginHide,
          style: AppTypography.labelSmall.copyWith(
            color: const Color(0xFF888888),
          ),
        ),
      ),
      border: OutlineInputBorder(
        borderRadius: AppRadius.lgAll,
        borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppRadius.lgAll,
        borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
      ),
      filled: true,
      fillColor: const Color(0xFFF5F5F5),
    ),
    validator: (v) =>
        (v == null || v.isEmpty) ? AppStrings.validationPasswordEmpty : null,
  );

  Widget _loginButton() => SizedBox(
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
      child: ElevatedButton(
        onPressed: widget.isLoading ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.fullAll),
        ),
        child: widget.isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                AppStrings.loginButton,
                style: AppTypography.labelLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    ),
  );
}
