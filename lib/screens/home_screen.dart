import 'package:flutter/material.dart';

import '../models/activity.dart';
import '../models/energy.dart';
import '../models/transport.dart';
import '../models/waste.dart';
import '../services/database_service.dart';
import '../theme/app_colors.dart';
import '../widgets/eco_image_banner.dart';

import 'eco_habits_screen.dart';
import 'energy_screen.dart';
import 'goals_screen.dart';
import 'profile_screen.dart';
import 'reports_screen.dart';
import 'transport_screen.dart';
import 'waste_screen.dart';

class HomeScreen extends StatefulWidget {
  final String userName;
  final String userEmail;

  const HomeScreen({
    super.key,
    required this.userName,
    required this.userEmail,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseService _db = DatabaseService();

  List<Activity> _activities = [];
  List<Transport> _transport = [];
  List<Energy> _energy = [];
  List<Waste> _waste = [];

  bool _isLoading = true;

  // ----------------------------------------------------------
  // INIT
  // ----------------------------------------------------------

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  // ----------------------------------------------------------
  // LOAD DASHBOARD DATA
  // ----------------------------------------------------------

  Future<void> _loadDashboard() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final results = await Future.wait([
        _db.getActivities(),
        _db.getTransport(),
        _db.getEnergy(),
        _db.getWaste(),
      ]);

      if (!mounted) return;

      setState(() {
        _activities = results[0] as List<Activity>;
        _transport = results[1] as List<Transport>;
        _energy = results[2] as List<Energy>;
        _waste = results[3] as List<Waste>;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to load dashboard data.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  // ----------------------------------------------------------
  // DASHBOARD CALCULATIONS
  // ----------------------------------------------------------

  double get _totalCo2Saved {
    return _activities.fold(0.0, (sum, item) => sum + item.co2Saved) +
        _transport.fold(0.0, (sum, item) => sum + item.co2Emission);
  }

  double get _totalEnergy {
    return _energy.fold(0.0, (sum, item) => sum + item.estimatedUnits);
  }

  double get _totalWaste {
    return _waste.fold(0.0, (sum, item) => sum + item.quantity);
  }

  double get _recycledWaste {
    return _waste
        .where((item) => item.recycled)
        .fold(0.0, (sum, item) => sum + item.quantity);
  }

  // ----------------------------------------------------------
  // NAVIGATION
  // ----------------------------------------------------------

  void _openProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileScreen(
          userName: widget.userName,
          userEmail: widget.userEmail,
        ),
      ),
    );
  }

  void _openReports() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ReportsScreen()),
    );
  }

  void _openGoals() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const GoalsScreen()),
    );
  }

  Future<void> _openScreen(Widget screen) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );

    // Refresh dashboard after returning.
    if (mounted) {
      _loadDashboard();
    }
  }

  // ----------------------------------------------------------
  // BUILD
  // ----------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      // ------------------------------------------------------
      // APP BAR
      // ------------------------------------------------------
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,

        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Personal Eco Tracker',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Your sustainability dashboard',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),

        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _isLoading ? null : _loadDashboard,
            icon: const Icon(
              Icons.refresh_rounded,
              color: AppColors.textSecondary,
            ),
          ),

          IconButton(
            tooltip: 'Profile',
            onPressed: _openProfile,
            icon: const Icon(
              Icons.person_outline_rounded,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(width: 6),
        ],
      ),

      // ------------------------------------------------------
      // BODY
      // ------------------------------------------------------
      body: RefreshIndicator(
        onRefresh: _loadDashboard,
        color: AppColors.primary,

        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),

          padding: const EdgeInsets.fromLTRB(20, 22, 20, 35),

          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  // ------------------------------------------------
                  // GREETING
                  // ------------------------------------------------

                  Text(
                    'Hello, ${widget.userName} 👋',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,

                    style: const TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    'Track your everyday impact and build better habits.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.4,
                      color: AppColors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 18),

                  const EcoImageBanner(
                    imageAsset: 'assets/images/home.jpg',
                    label: 'Your greener journey starts here',
                  ),

                  const SizedBox(height: 22),

                  // ------------------------------------------------
                  // ECO JOURNEY
                  // ------------------------------------------------
                  _buildJourneyCard(),

                  const SizedBox(height: 30),

                  // ------------------------------------------------
                  // QUICK ACTIONS
                  // ------------------------------------------------
                  _sectionHeading(
                    title: 'Quick Actions',
                    subtitle:
                        'Choose an area to track your environmental impact.',
                  ),

                  const SizedBox(height: 14),

                  LayoutBuilder(
                    builder: (context, constraints) {
                      int columns = 2;

                      if (constraints.maxWidth >= 950) {
                        columns = 3;
                      }

                      const spacing = 14.0;

                      final cardWidth =
                          (constraints.maxWidth - ((columns - 1) * spacing)) /
                          columns;

                      return Wrap(
                        spacing: spacing,
                        runSpacing: spacing,

                        children: [
                          _quickAction(
                            width: cardWidth,
                            icon: Icons.directions_car_rounded,
                            title: 'Transport',
                            subtitle: 'Track your journeys',
                            color: AppColors.secondary,
                            onTap: () => _openScreen(const TransportScreen()),
                          ),

                          _quickAction(
                            width: cardWidth,
                            icon: Icons.bolt_rounded,
                            title: 'Energy',
                            subtitle: 'Monitor energy usage',
                            color: AppColors.energy,
                            onTap: () => _openScreen(const EnergyScreen()),
                          ),

                          _quickAction(
                            width: cardWidth,
                            icon: Icons.delete_outline_rounded,
                            title: 'Waste',
                            subtitle: 'Manage your waste',
                            color: AppColors.waste,
                            onTap: () => _openScreen(const WasteScreen()),
                          ),

                          _quickAction(
                            width: cardWidth,
                            icon: Icons.eco_rounded,
                            title: 'Eco Habits',
                            subtitle: 'Build better habits',
                            color: AppColors.green600,
                            onTap: () => _openScreen(const EcoHabitsScreen()),
                          ),

                          _quickAction(
                            width: cardWidth,
                            icon: Icons.flag_outlined,
                            title: 'Goals',
                            subtitle: 'Track your goals',
                            color: AppColors.secondary,
                            onTap: _openGoals,
                          ),

                          _quickAction(
                            width: cardWidth,
                            icon: Icons.bar_chart_rounded,
                            title: 'Reports',
                            subtitle: 'View your progress',
                            color: AppColors.energy,
                            onTap: _openReports,
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 30),

                  // ------------------------------------------------
                  // OVERVIEW
                  // ------------------------------------------------
                  _sectionHeading(
                    title: 'Your Overview',
                    subtitle: 'A quick summary of your recorded activities.',
                  ),

                  const SizedBox(height: 14),

                  LayoutBuilder(
                    builder: (context, constraints) {
                      int columns = 2;

                      if (constraints.maxWidth >= 900) {
                        columns = 4;
                      }

                      const spacing = 14.0;

                      final width =
                          (constraints.maxWidth - ((columns - 1) * spacing)) /
                          columns;

                      return Wrap(
                        spacing: spacing,
                        runSpacing: spacing,

                        children: [
                          _overviewCard(
                            width: width,
                            icon: Icons.cloud_outlined,
                            title: 'CO₂ Tracked',
                            value: '${_totalCo2Saved.toStringAsFixed(1)} kg',
                            color: AppColors.primary,
                          ),

                          _overviewCard(
                            width: width,
                            icon: Icons.bolt_rounded,
                            title: 'Energy Used',
                            value: '${_totalEnergy.toStringAsFixed(2)} kWh',
                            color: AppColors.energy,
                          ),

                          _overviewCard(
                            width: width,
                            icon: Icons.delete_outline_rounded,
                            title: 'Total Waste',
                            value: '${_totalWaste.toStringAsFixed(1)} kg',
                            color: AppColors.waste,
                          ),

                          _overviewCard(
                            width: width,
                            icon: Icons.recycling_rounded,
                            title: 'Recycled',
                            value: '${_recycledWaste.toStringAsFixed(1)} kg',
                            color: AppColors.green600,
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 30),

                  // ------------------------------------------------
                  // RECENT ACTIVITY
                  // ------------------------------------------------
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,

                    children: [
                      const Text(
                        'Recent Activity',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),

                      TextButton(
                        onPressed: _openReports,
                        child: const Text(
                          'View all',
                          style: TextStyle(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  _recentActivity(),

                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.all(25),

                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),

      // ----------------------------------------------------------
      // BOTTOM NAVIGATION
      // ----------------------------------------------------------
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,

        backgroundColor: Colors.white,

        indicatorColor: AppColors.primary.withValues(alpha: 0.12),

        elevation: 10,

        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,

        onDestinationSelected: (index) {
          switch (index) {
            case 1:
              _openReports();
              break;

            case 2:
              _openGoals();
              break;

            case 3:
              _openProfile();
              break;

            default:
              break;
          }
        },

        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),

          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart_rounded),
            label: 'Reports',
          ),

          NavigationDestination(
            icon: Icon(Icons.flag_outlined),
            selectedIcon: Icon(Icons.flag_rounded),
            label: 'Goals',
          ),

          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  // SECTION HEADING
  // ----------------------------------------------------------

  Widget _sectionHeading({required String title, required String subtitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),

        const SizedBox(height: 5),

        Text(
          subtitle,
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  // ----------------------------------------------------------
  // ECO JOURNEY CARD
  // ----------------------------------------------------------

  Widget _buildJourneyCard() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(22),

      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],

          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),

        borderRadius: BorderRadius.circular(22),

        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.16),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),

      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 500) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                _journeyText(),

                const SizedBox(height: 18),

                Align(alignment: Alignment.centerRight, child: _journeyIcon()),
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: _journeyText()),

              const SizedBox(width: 18),

              _journeyIcon(),
            ],
          );
        },
      ),
    );
  }

  Widget _journeyText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),

          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(20),
          ),

          child: const Text(
            'YOUR ECO JOURNEY',
            style: TextStyle(
              fontSize: 10,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),

        const SizedBox(height: 13),

        const Text(
          'Small actions matter.',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),

        const SizedBox(height: 7),

        const Text(
          'Track your daily activities and understand how your choices affect the environment.',
          style: TextStyle(fontSize: 13, height: 1.5, color: Colors.white70),
        ),
      ],
    );
  }

  Widget _journeyIcon() {
    return Container(
      width: 72,
      height: 72,

      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(22),
      ),

      child: const Icon(Icons.eco_rounded, size: 42, color: Colors.white),
    );
  }

  // ----------------------------------------------------------
  // QUICK ACTION CARD
  // ----------------------------------------------------------

  Widget _quickAction({
    required double width,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: width,
      height: 100,

      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),

        child: InkWell(
          onTap: onTap,

          borderRadius: BorderRadius.circular(18),

          child: Container(
            padding: const EdgeInsets.all(15),

            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),

              border: Border.all(color: AppColors.border),

              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.035),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),

            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,

                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(14),
                  ),

                  child: Icon(icon, color: color, size: 25),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,

                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,

                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,

                        style: const TextStyle(
                          fontSize: 11.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 4),

                const Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: AppColors.textMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // OVERVIEW CARD
  // ----------------------------------------------------------

  Widget _overviewCard({
    required double width,
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return SizedBox(
      width: width,
      height: 128,

      child: Container(
        padding: const EdgeInsets.all(16),

        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius: BorderRadius.circular(18),

          border: Border.all(color: AppColors.border),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.035),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Container(
              width: 43,
              height: 43,

              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(13),
              ),

              child: Icon(icon, color: color, size: 23),
            ),

            const Spacer(),

            Text(
              title,
              style: const TextStyle(
                fontSize: 11.5,
                color: AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: 3),

            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,

              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // RECENT ACTIVITY
  // ----------------------------------------------------------

  Widget _recentActivity() {
    if (_transport.isEmpty &&
        _energy.isEmpty &&
        _waste.isEmpty &&
        _activities.isEmpty) {
      return Container(
        width: double.infinity,

        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),

        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius: BorderRadius.circular(18),

          border: Border.all(color: AppColors.border),
        ),

        child: Column(
          children: [
            Container(
              width: 58,
              height: 58,

              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),

              child: const Icon(
                Icons.insights_outlined,
                size: 29,
                color: AppColors.primary,
              ),
            ),

            const SizedBox(height: 13),

            const Text(
              'No activity yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 5),

            const Text(
              'Start tracking an activity to see your progress here.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    // Transport
    if (_transport.isNotEmpty) {
      final item = _transport.first;

      return _activityTile(
        icon: Icons.directions_car_rounded,
        iconColor: AppColors.secondary,
        title: '${item.mode} Travel',
        subtitle: '${item.distance.toStringAsFixed(1)} km',
        value: '${item.co2Emission.toStringAsFixed(2)} kg CO₂',
      );
    }

    // Energy
    if (_energy.isNotEmpty) {
      final item = _energy.first;

      return _activityTile(
        icon: Icons.bolt_rounded,
        iconColor: AppColors.energy,
        title: '${item.appliance} Usage',
        subtitle: '${item.usageHours.toStringAsFixed(1)} hours',
        value: '${item.estimatedUnits.toStringAsFixed(2)} kWh',
      );
    }

    // Waste
    if (_waste.isNotEmpty) {
      final item = _waste.first;

      return _activityTile(
        icon: Icons.delete_outline_rounded,
        iconColor: AppColors.waste,
        title: '${item.wasteType} Waste',
        subtitle: '${item.quantity.toStringAsFixed(1)} kg',
        value: item.recycled ? 'Recycled' : 'Not recycled',
      );
    }

    // General activity
    if (_activities.isNotEmpty) {
      final item = _activities.first;

      return _activityTile(
        icon: Icons.eco_rounded,
        iconColor: AppColors.green600,
        title: item.activityType,
        subtitle: item.description,
        value: '${item.co2Saved.toStringAsFixed(2)} kg CO₂',
      );
    }

    return const SizedBox.shrink();
  }

  // ----------------------------------------------------------
  // ACTIVITY TILE
  // ----------------------------------------------------------

  Widget _activityTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String value,
  }) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(18),

        border: Border.all(color: AppColors.border),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
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
              color: iconColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),

            child: Icon(icon, color: iconColor, size: 25),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,

                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,

                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,

                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: iconColor,
                  ),
                ),
              ],
            ),
          ),

          const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
        ],
      ),
    );
  }
}
