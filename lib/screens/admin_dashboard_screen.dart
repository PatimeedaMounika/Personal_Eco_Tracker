import 'package:flutter/material.dart';

import '../models/user.dart';
import '../services/database_service.dart';
import '../theme/app_colors.dart';
import '../widgets/eco_image_banner.dart';
import 'login_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final DatabaseService _databaseService = DatabaseService();

  List<User> _users = [];
  bool _isLoading = true;

  // Admin colors
  static const Color adminBlue = Color(0xFF1565C0);
  static const Color adminDarkBlue = Color(0xFF0D47A1);
  static const Color pageBackground = Color(0xFFF7F9FC);
  static const Color cardBorder = Color(0xFFE2E8F0);
  static const Color textPrimary = Color(0xFF263238);
  static const Color textSecondary = Color(0xFF607D8B);

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  // ==========================================================
  // LOAD USERS
  // ==========================================================

  Future<void> _loadUsers() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final users = await _databaseService.getUsers();

      if (!mounted) return;

      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to load users: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ==========================================================
  // LOGOUT
  // ==========================================================

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  // ==========================================================
  // USER CARD
  // ==========================================================

  Widget _userCard(User user) {
    final firstLetter = user.fullName.isNotEmpty
        ? user.fullName[0].toUpperCase()
        : '?';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [adminBlue, Color(0xFF42A5F5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              firstLetter,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),

          const SizedBox(width: 14),

          // User details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),

                const SizedBox(height: 6),

                Row(
                  children: [
                    const Icon(
                      Icons.email_outlined,
                      size: 15,
                      color: textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        user.email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // User status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F1FB),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified_outlined, size: 14, color: adminBlue),
                SizedBox(width: 4),
                Text(
                  'User',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: adminBlue,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // STAT CARD
  // ==========================================================

  Widget _statCard({
    required IconData icon,
    required Color color,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 25),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: textPrimary,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 10.5, color: textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // EMPTY STATE
  // ==========================================================

  Widget _emptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cardBorder),
      ),
      child: Column(
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F1FB),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(
              Icons.people_outline_rounded,
              size: 40,
              color: adminBlue,
            ),
          ),

          const SizedBox(height: 18),

          const Text(
            'No registered users',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: textPrimary,
            ),
          ),

          const SizedBox(height: 7),

          const Text(
            'Users who create an account will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(color: textSecondary, fontSize: 13, height: 1.4),
          ),

          const SizedBox(height: 18),

          OutlinedButton.icon(
            onPressed: _loadUsers,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Refresh'),
            style: OutlinedButton.styleFrom(
              foregroundColor: adminBlue,
              side: const BorderSide(color: adminBlue),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBackground,

      // ======================================================
      // APP BAR
      // ======================================================
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: textPrimary,
        elevation: 0,

        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F1FB),
                borderRadius: BorderRadius.circular(11),
              ),
              child: const Icon(
                Icons.admin_panel_settings_outlined,
                color: adminBlue,
                size: 23,
              ),
            ),

            const SizedBox(width: 10),

            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Admin Dashboard',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: textPrimary,
                  ),
                ),
                Text(
                  'Personal Eco Tracker',
                  style: TextStyle(fontSize: 10.5, color: textSecondary),
                ),
              ],
            ),
          ],
        ),

        actions: [
          IconButton(
            tooltip: 'Refresh users',
            onPressed: _loadUsers,
            icon: const Icon(Icons.refresh_rounded, color: textSecondary),
          ),

          IconButton(
            tooltip: 'Logout',
            onPressed: _logout,
            icon: const Icon(Icons.logout_rounded, color: AppColors.error),
          ),

          const SizedBox(width: 6),
        ],
      ),

      // ======================================================
      // BODY
      // ======================================================
      body: RefreshIndicator(
        color: adminBlue,
        onRefresh: _loadUsers,

        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),

          padding: const EdgeInsets.fromLTRB(20, 20, 20, 35),

          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 950),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const EcoImageBanner(
                    imageAsset: 'assets/images/admin_dashboard.jpg',
                    label: 'A clear view of your eco community',
                  ),

                  const SizedBox(height: 18),

                  // ==================================================
                  // ADMIN HERO
                  // ==================================================
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
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
                          blurRadius: 22,
                          offset: const Offset(0, 9),
                        ),
                      ],
                    ),

                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isSmall = constraints.maxWidth < 500;

                        if (isSmall) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _adminIcon(),

                              const SizedBox(height: 18),

                              _heroText(),
                            ],
                          );
                        }

                        return Row(
                          children: [
                            _adminIcon(),

                            const SizedBox(width: 16),

                            Expanded(child: _heroText()),

                            const SizedBox(width: 15),

                            _adminCircle(),
                          ],
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 26),

                  // ==================================================
                  // OVERVIEW
                  // ==================================================
                  const Text(
                    'Overview',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: textPrimary,
                    ),
                  ),

                  const SizedBox(height: 5),

                  const Text(
                    'Quick summary of registered accounts.',
                    style: TextStyle(fontSize: 12.5, color: textSecondary),
                  ),

                  const SizedBox(height: 14),

                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth > 600;

                      if (isWide) {
                        return Row(
                          children: [
                            Expanded(
                              child: _statCard(
                                icon: Icons.people_alt_outlined,
                                color: adminBlue,
                                title: 'Registered Users',
                                value: '${_users.length}',
                                subtitle: 'Total accounts',
                              ),
                            ),

                            const SizedBox(width: 14),

                            Expanded(
                              child: _statCard(
                                icon: Icons.verified_user_outlined,
                                color: const Color(0xFF00897B),
                                title: 'Active Accounts',
                                value: '${_users.length}',
                                subtitle: 'Registered users',
                              ),
                            ),
                          ],
                        );
                      }

                      return Column(
                        children: [
                          _statCard(
                            icon: Icons.people_alt_outlined,
                            color: adminBlue,
                            title: 'Registered Users',
                            value: '${_users.length}',
                            subtitle: 'Total accounts',
                          ),

                          const SizedBox(height: 12),

                          _statCard(
                            icon: Icons.verified_user_outlined,
                            color: const Color(0xFF00897B),
                            title: 'Active Accounts',
                            value: '${_users.length}',
                            subtitle: 'Registered users',
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 30),

                  // ==================================================
                  // REGISTERED USERS HEADER
                  // ==================================================
                  Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Registered Users',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: textPrimary,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'User accounts available in the system.',
                              style: TextStyle(
                                fontSize: 12.5,
                                color: textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 10),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 11,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F1FB),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${_users.length}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: adminBlue,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ==================================================
                  // USER LIST
                  // ==================================================
                  if (_isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(55),
                        child: CircularProgressIndicator(color: adminBlue),
                      ),
                    )
                  else if (_users.isEmpty)
                    _emptyState()
                  else
                    ..._users.map((user) => _userCard(user)),

                  const SizedBox(height: 8),

                  // ==================================================
                  // SECURITY INFORMATION
                  // ==================================================
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(17),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F6FB),
                      borderRadius: BorderRadius.circular(17),
                      border: Border.all(color: const Color(0xFFD7E5F2)),
                    ),

                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE2EEF9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.lock_outline_rounded,
                            color: adminBlue,
                            size: 20,
                          ),
                        ),

                        const SizedBox(width: 12),

                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Security Notice',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: textPrimary,
                                ),
                              ),

                              SizedBox(height: 5),

                              Text(
                                'For security, user passwords are never displayed in the admin dashboard.',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  height: 1.45,
                                  color: textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),

                  // ==================================================
                  // FOOTER
                  // ==================================================
                  const Center(
                    child: Text(
                      'Personal Eco Tracker • Admin Panel',
                      style: TextStyle(fontSize: 11, color: Color(0xFF90A4AE)),
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

  // ==========================================================
  // HERO ICON
  // ==========================================================

  Widget _adminIcon() {
    return Container(
      width: 62,
      height: 62,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Icon(
        Icons.admin_panel_settings_outlined,
        color: Colors.white,
        size: 34,
      ),
    );
  }

  // ==========================================================
  // HERO TEXT
  // ==========================================================

  Widget _heroText() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome, Admin!',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),

        SizedBox(height: 6),

        Text(
          'Monitor registered users and manage your Eco Tracker application.',
          style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.45),
        ),
      ],
    );
  }

  // ==========================================================
  // HERO CIRCLE
  // ==========================================================

  Widget _adminCircle() {
    return Container(
      width: 82,
      height: 82,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.75),
          width: 2.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipOval(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [adminBlue, Color(0xFF42A5F5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Icon(
            Icons.admin_panel_settings_rounded,
            size: 40,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
