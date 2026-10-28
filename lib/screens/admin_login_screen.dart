import 'package:flutter/material.dart';

import 'admin_dashboard_screen.dart';
import '../theme/app_colors.dart';
import '../widgets/eco_image_banner.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  // Keep your existing admin credentials.
  static const String adminEmail = 'admin@gmail.com';
  static const String adminPassword = 'Admin@123';

  static const Color adminBlue = Color(0xFF1565C0);
  static const Color adminDarkBlue = Color(0xFF0D47A1);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ========================================================
  // ADMIN LOGIN
  // ========================================================

  Future<void> _adminLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    final email = _emailController.text.trim().toLowerCase();

    final password = _passwordController.text;

    if (email == adminEmail && password == adminPassword) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AdminDashboardScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid admin email or password.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // ========================================================
  // INPUT DECORATION
  // ========================================================

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,

      prefixIcon: Icon(icon, color: adminBlue, size: 21),

      suffixIcon: suffixIcon,

      filled: true,
      fillColor: Colors.white,

      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 16),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.border),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.border),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: adminBlue, width: 1.8),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.error),
      ),

      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
    );
  }

  // ========================================================
  // BUILD
  // ========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),

              child: Column(
                children: [
                  const SizedBox(height: 25),

                  const EcoImageBanner(
                    imageAsset: 'assets/images/admin_login.jpg',
                    label: 'Welcome to your eco workspace',
                  ),

                  const SizedBox(height: 24),

                  _buildHeader(),

                  const SizedBox(height: 24),

                  _buildLoginCard(),

                  const SizedBox(height: 20),

                  _buildFooter(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ========================================================
  // HEADER
  // ========================================================

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 82,
          height: 82,

          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [adminDarkBlue, adminBlue],

              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),

            borderRadius: BorderRadius.circular(24),

            boxShadow: [
              BoxShadow(
                color: adminBlue.withValues(alpha: 0.20),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),

          child: const Icon(
            Icons.admin_panel_settings_rounded,
            size: 42,
            color: Colors.white,
          ),
        ),

        const SizedBox(height: 18),

        const Text(
          'Admin Portal',
          textAlign: TextAlign.center,

          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),

        const SizedBox(height: 6),

        const Text(
          'Manage Personal Eco Tracker',
          textAlign: TextAlign.center,

          style: TextStyle(fontSize: 13.5, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  // ========================================================
  // LOGIN CARD
  // ========================================================

  Widget _buildLoginCard() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.fromLTRB(24, 24, 24, 22),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(22),

        border: Border.all(color: AppColors.border),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.055),
            blurRadius: 22,
            offset: const Offset(0, 9),
          ),
        ],
      ),

      child: Form(
        key: _formKey,

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,

          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,

                  decoration: BoxDecoration(
                    color: adminBlue.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),

                  child: const Icon(
                    Icons.lock_outline_rounded,
                    color: adminBlue,
                    size: 21,
                  ),
                ),

                const SizedBox(width: 11),

                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Administrator Sign In',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),

                      SizedBox(height: 2),

                      Text(
                        'Enter your admin credentials',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // EMAIL
            const Text(
              'Admin Email',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 7),

            TextFormField(
              controller: _emailController,

              keyboardType: TextInputType.emailAddress,

              textInputAction: TextInputAction.next,

              decoration: _inputDecoration(
                hint: 'Enter admin email',
                icon: Icons.email_outlined,
              ),

              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter admin email';
                }

                return null;
              },
            ),

            const SizedBox(height: 17),

            // PASSWORD
            const Text(
              'Admin Password',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 7),

            TextFormField(
              controller: _passwordController,

              obscureText: _obscurePassword,

              textInputAction: TextInputAction.done,

              onFieldSubmitted: (_) {
                if (!_isLoading) {
                  _adminLogin();
                }
              },

              decoration: _inputDecoration(
                hint: 'Enter admin password',
                icon: Icons.lock_outline_rounded,

                suffixIcon: IconButton(
                  tooltip: _obscurePassword ? 'Show password' : 'Hide password',

                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },

                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,

                    color: AppColors.textMuted,
                  ),
                ),
              ),

              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter admin password';
                }

                return null;
              },
            ),

            const SizedBox(height: 23),

            // LOGIN BUTTON
            SizedBox(
              height: 52,

              child: ElevatedButton(
                onPressed: _isLoading ? null : _adminLogin,

                style: ElevatedButton.styleFrom(
                  backgroundColor: adminBlue,
                  foregroundColor: Colors.white,

                  disabledBackgroundColor: adminBlue.withValues(alpha: 0.55),

                  elevation: 0,

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),

                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,

                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.2,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,

                        children: [
                          Icon(Icons.login_rounded, size: 20),

                          SizedBox(width: 9),

                          Text(
                            'Sign In as Admin',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 18),

            // SECURITY NOTE
            Container(
              padding: const EdgeInsets.all(12),

              decoration: BoxDecoration(
                color: adminBlue.withValues(alpha: 0.06),

                borderRadius: BorderRadius.circular(12),
              ),

              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Icon(Icons.shield_outlined, color: adminBlue, size: 19),

                  SizedBox(width: 9),

                  Expanded(
                    child: Text(
                      'Administrator access is restricted to authorized users.',
                      style: TextStyle(
                        fontSize: 11,
                        height: 1.4,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========================================================
  // FOOTER
  // ========================================================

  Widget _buildFooter() {
    return TextButton.icon(
      onPressed: () {
        Navigator.pop(context);
      },

      icon: const Icon(Icons.arrow_back_rounded, size: 18),

      label: const Text(
        'Back to User Login',
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
      ),

      style: TextButton.styleFrom(foregroundColor: AppColors.primary),
    );
  }
}
