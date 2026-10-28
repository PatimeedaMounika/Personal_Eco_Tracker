import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/eco_image_banner.dart';
import 'login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 8),

                    const EcoImageBanner(
                      imageAsset: 'assets/images/lifestyle.jpg',
                      label: 'Bright flowers representing a greener lifestyle',
                      maxImageWidth: 260,
                      showCaption: false,
                    ),

                    const SizedBox(height: 18),

                    // Small heading
                    const Text(
                      'Welcome to',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),

                    const SizedBox(height: 6),

                    // App name
                    const Text(
                      'Personal Eco Tracker',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Tagline
                    const Text(
                      'Make every action count.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Track your everyday activities and understand your environmental impact.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.5,
                        color: AppColors.textSecondary,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Simple feature highlights
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        _MiniFeature(
                          icon: Icons.track_changes_rounded,
                          title: 'Track',
                          color: AppColors.secondary,
                        ),
                        SizedBox(width: 14),
                        _MiniFeature(
                          icon: Icons.insights_rounded,
                          title: 'Understand',
                          color: Color(0xFFF57C00),
                        ),
                        SizedBox(width: 14),
                        _MiniFeature(
                          icon: Icons.eco_rounded,
                          title: 'Improve',
                          color: AppColors.green600,
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // Get Started
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                          );
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Get Started',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 10),
                            Icon(Icons.arrow_forward_rounded),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      'Track better. Live greener.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniFeature extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;

  const _MiniFeature({
    required this.icon,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 95,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 7),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
