import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:promptcraft/app/themes/discord_design_system.dart';
import 'package:promptcraft/presentation/controllers/auth_controller.dart';

/// Professional Registration Page with Discord Design
class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController controller = Get.put(AuthController());

    return Scaffold(
      backgroundColor: DiscordDesignSystem.backgroundPrimary,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(DiscordDesignSystem.spacingXL),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo/Title
                  Text(
                    'Create Account',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          color: DiscordDesignSystem.blurple,
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: DiscordDesignSystem.spacingS),

                  Text(
                    'Join PromptCraft today',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: DiscordDesignSystem.textMuted,
                        ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: DiscordDesignSystem.spacingXL),

                  // Register Form
                  Form(
                    key: controller.registerFormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Email Field
                        _buildLabel(context, 'EMAIL'),
                        const SizedBox(height: DiscordDesignSystem.spacingS),
                        TextFormField(
                          controller: controller.emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: controller.validateEmail,
                          decoration: _buildInputDecoration(
                            hintText: 'Enter your email',
                            prefixIcon: Icons.email_outlined,
                          ),
                        ),

                        const SizedBox(height: DiscordDesignSystem.spacingM),

                        // Username Field
                        _buildLabel(context, 'USERNAME'),
                        const SizedBox(height: DiscordDesignSystem.spacingS),
                        TextFormField(
                          controller: controller.usernameController,
                          validator: controller.validateUsername,
                          decoration: _buildInputDecoration(
                            hintText: 'Choose a username',
                            prefixIcon: Icons.person_outline,
                          ),
                        ),

                        const SizedBox(height: DiscordDesignSystem.spacingM),

                        // Password Field
                        _buildLabel(context, 'PASSWORD'),
                        const SizedBox(height: DiscordDesignSystem.spacingS),
                        Obx(
                          () => TextFormField(
                            controller: controller.passwordController,
                            obscureText: !controller.isPasswordVisible.value,
                            validator: controller.validatePassword,
                            decoration: _buildInputDecoration(
                              hintText: 'Create a password',
                              prefixIcon: Icons.lock_outline,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  controller.isPasswordVisible.value
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: DiscordDesignSystem.textMuted,
                                ),
                                onPressed: controller.togglePasswordVisibility,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: DiscordDesignSystem.spacingM),

                        // Confirm Password Field
                        _buildLabel(context, 'CONFIRM PASSWORD'),
                        const SizedBox(height: DiscordDesignSystem.spacingS),
                        Obx(
                          () => TextFormField(
                            controller: controller.confirmPasswordController,
                            obscureText:
                                !controller.isConfirmPasswordVisible.value,
                            validator: controller.validateConfirmPassword,
                            decoration: _buildInputDecoration(
                              hintText: 'Confirm your password',
                              prefixIcon: Icons.lock_outline,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  controller.isConfirmPasswordVisible.value
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: DiscordDesignSystem.textMuted,
                                ),
                                onPressed:
                                    controller.toggleConfirmPasswordVisibility,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: DiscordDesignSystem.spacingL),

                        // Register Button
                        Obx(
                          () => ElevatedButton(
                            onPressed: controller.isLoading.value
                                ? null
                                : controller.register,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: DiscordDesignSystem.green,
                              foregroundColor: DiscordDesignSystem.white,
                              padding: const EdgeInsets.symmetric(
                                vertical: DiscordDesignSystem.spacingM,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  DiscordDesignSystem.radiusS,
                                ),
                              ),
                            ),
                            child: controller.isLoading.value
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: DiscordDesignSystem.white,
                                    ),
                                  )
                                : const Text(
                                    'Create Account',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: DiscordDesignSystem.spacingL),

                        // Login Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already have an account? ',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: DiscordDesignSystem.textMuted,
                                  ),
                            ),
                            TextButton(
                              onPressed: controller.goToLogin,
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(0, 0),
                                tapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                'Log In',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: DiscordDesignSystem.textLink,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(BuildContext context, String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: DiscordDesignSystem.textMuted,
            fontWeight: FontWeight.w600,
          ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hintText,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      prefixIcon: Icon(
        prefixIcon,
        color: DiscordDesignSystem.textMuted,
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: DiscordDesignSystem.backgroundTertiary,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          DiscordDesignSystem.radiusS,
        ),
        borderSide: BorderSide.none,
      ),
    );
  }
}
