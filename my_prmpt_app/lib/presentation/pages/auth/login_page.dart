import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:promptcraft/app/themes/discord_design_system.dart';
import 'package:promptcraft/presentation/controllers/auth_controller.dart';

/// Professional Login Page with Discord Design
///
/// Features:
/// - Discord-inspired design
/// - Form validation
/// - Loading states
/// - Error handling
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

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
                    'PromptCraft',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          color: DiscordDesignSystem.blurple,
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: DiscordDesignSystem.spacingS),

                  Text(
                    'Welcome back!',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: DiscordDesignSystem.textMuted,
                        ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: DiscordDesignSystem.spacingXL),

                  // Login Form
                  Form(
                    key: controller.loginFormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Email Field
                        Text(
                          'EMAIL',
                          style:
                              Theme.of(context).textTheme.labelMedium?.copyWith(
                                    color: DiscordDesignSystem.textMuted,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        const SizedBox(height: DiscordDesignSystem.spacingS),
                        TextFormField(
                          controller: controller.emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: controller.validateEmail,
                          decoration: InputDecoration(
                            hintText: 'Enter your email',
                            prefixIcon: const Icon(
                              Icons.email_outlined,
                              color: DiscordDesignSystem.textMuted,
                            ),
                            filled: true,
                            fillColor: DiscordDesignSystem.backgroundTertiary,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                DiscordDesignSystem.radiusS,
                              ),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),

                        const SizedBox(height: DiscordDesignSystem.spacingM),

                        // Password Field
                        Text(
                          'PASSWORD',
                          style:
                              Theme.of(context).textTheme.labelMedium?.copyWith(
                                    color: DiscordDesignSystem.textMuted,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        const SizedBox(height: DiscordDesignSystem.spacingS),
                        Obx(
                          () => TextFormField(
                            controller: controller.passwordController,
                            obscureText: !controller.isPasswordVisible.value,
                            validator: controller.validatePassword,
                            decoration: InputDecoration(
                              hintText: 'Enter your password',
                              prefixIcon: const Icon(
                                Icons.lock_outline,
                                color: DiscordDesignSystem.textMuted,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  controller.isPasswordVisible.value
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: DiscordDesignSystem.textMuted,
                                ),
                                onPressed: controller.togglePasswordVisibility,
                              ),
                              filled: true,
                              fillColor:
                                  DiscordDesignSystem.backgroundTertiary,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  DiscordDesignSystem.radiusS,
                                ),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: DiscordDesignSystem.spacingS),

                        // Forgot Password
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              // TODO: Implement forgot password
                            },
                            child: Text(
                              'Forgot Password?',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: DiscordDesignSystem.textLink,
                                  ),
                            ),
                          ),
                        ),

                        const SizedBox(height: DiscordDesignSystem.spacingM),

                        // Login Button
                        Obx(
                          () => ElevatedButton(
                            onPressed: controller.isLoading.value
                                ? null
                                : controller.login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: DiscordDesignSystem.blurple,
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
                                    'Log In',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: DiscordDesignSystem.spacingL),

                        // Register Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Need an account? ',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: DiscordDesignSystem.textMuted,
                                  ),
                            ),
                            TextButton(
                              onPressed: controller.goToRegister,
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(0, 0),
                                tapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                'Register',
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
}
