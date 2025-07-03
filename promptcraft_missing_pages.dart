// ============================================
// MISSING ESSENTIAL PAGES
// ============================================
// These pages complete the PromptCraft application

// ============================================
// 1. LOGIN PAGE
// ============================================
// lib/presentation/pages/auth/login_page.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../../core/design_system/discord_design_system.dart';

class LoginPage extends GetView<AuthController> {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo and title
                  Icon(
                    Icons.psychology,
                    size: 80,
                    color: DiscordDesignSystem.blurple,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'PromptCraft',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'AI Prompt Management System',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[400],
                    ),
                  ),
                  const SizedBox(height: 48),
                  Obx(() => Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                'Welcome Back!',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              // Username field
                              TextField(
                                controller: controller.loginUsernameController,
                                decoration: const InputDecoration(
                                  labelText: 'Username',
                                  prefixIcon: Icon(Icons.person),
                                ),
                                textInputAction: TextInputAction.next,
                              ),
                              const SizedBox(height: 16),
                              // Password field
                              TextField(
                                controller: controller.loginPasswordController,
                                decoration: const InputDecoration(
                                  labelText: 'Password',
                                  prefixIcon: Icon(Icons.lock),
                                ),
                                obscureText: true,
                                onSubmitted: (_) => _onLogin(context),
                              ),
                              const SizedBox(height: 24),
                              controller.isLoading.value
                                  ? const Center(
                                      child: CircularProgressIndicator())
                                  : ElevatedButton(
                                      onPressed: () => _onLogin(context),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            DiscordDesignSystem.blurple,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: const Text(
                                        'Login',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                              const SizedBox(height: 12),
                              TextButton(
                                onPressed: () => Get.toNamed('/register'),
                                child: const Text(
                                    'Don\'t have an account? Register'),
                              ),
                            ],
                          ),
                        ),
                      )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onLogin(BuildContext context) async {
    final authController = Get.find<AuthController>();
    try {
      await authController.login();
      if (authController.isLoggedInRx.value) {
        // Navigate to dashboard/home
        Get.offAllNamed('/mobile');
      }
    } catch (e) {
      // Show error snackbar
      Get.snackbar(
        'Login Failed',
        e.toString(),
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    }
  }
}
