import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/eco_image_banner.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const Color blue = Color(0xFF1976D2);
  static const Color orange = Color(0xFFF57C00);
  static const Color purple = Color(0xFF7B1FA2);
  static const Color green = Color(0xFF388E3C);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      // ======================================================
      // APP BAR
      // ======================================================
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,

        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'About This App',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 2),
            Text(
              'Personal Eco Tracker',
              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),

      // ======================================================
      // BODY
      // ======================================================
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 35),

        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 950),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                const EcoImageBanner(
                  imageAsset: 'assets/images/about.jpg',
                  label: 'Protecting the planet starts with awareness',
                ),

                const SizedBox(height: 22),

                _buildHero(),

                const SizedBox(height: 28),

                _sectionTitle(
                  'What is Personal Eco Tracker?',
                  Icons.info_outline_rounded,
                  AppColors.primary,
                ),

                const SizedBox(height: 12),

                _buildDescriptionCard(),

                const SizedBox(height: 28),

                _sectionTitle(
                  'What You Can Track',
                  Icons.track_changes_rounded,
                  blue,
                ),

                const SizedBox(height: 12),

                _buildFeatureGrid(),

                const SizedBox(height: 28),

                _sectionTitle('How It Works', Icons.auto_graph_rounded, orange),

                const SizedBox(height: 12),

                _buildHowItWorks(),

                const SizedBox(height: 28),

                _sectionTitle(
                  'Why Use This App?',
                  Icons.workspace_premium_outlined,
                  purple,
                ),

                const SizedBox(height: 12),

                _buildBenefits(),

                const SizedBox(height: 28),

                _buildBottomCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ========================================================
  // HERO
  // ========================================================

  Widget _buildHero() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(24),

      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00695C), Color(0xFF1976D2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),

        borderRadius: BorderRadius.circular(24),

        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.15),
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
              children: [_appIcon(), const SizedBox(height: 18), _heroText()],
            );
          }

          return Row(
            children: [
              _appIcon(),

              const SizedBox(width: 20),

              Expanded(child: _heroText()),
            ],
          );
        },
      ),
    );
  }

  Widget _appIcon() {
    return Container(
      width: 76,
      height: 76,

      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(21),
      ),

      child: const Icon(Icons.eco_rounded, color: Colors.white, size: 43),
    );
  }

  Widget _heroText() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Text(
          'Personal Eco Tracker',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),

        SizedBox(height: 7),

        Text(
          'Track your actions. Understand your impact. Build better habits.',
          style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
        ),
      ],
    );
  }

  // ========================================================
  // SECTION TITLE
  // ========================================================

  Widget _sectionTitle(String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,

          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(13),
          ),

          child: Icon(icon, color: color, size: 22),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  // ========================================================
  // DESCRIPTION
  // ========================================================

  Widget _buildDescriptionCard() {
    return _whiteCard(
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Text(
            'Make everyday choices more visible.',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),

          SizedBox(height: 10),

          Text(
            'Personal Eco Tracker is designed to help you record everyday activities and understand their environmental impact.',
            style: TextStyle(
              fontSize: 13,
              height: 1.55,
              color: AppColors.textSecondary,
            ),
          ),

          SizedBox(height: 10),

          Text(
            'You can record transportation, energy usage and waste, follow eco-friendly habits, create personal goals and view your progress through reports.',
            style: TextStyle(
              fontSize: 13,
              height: 1.55,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ========================================================
  // FEATURE GRID
  // ========================================================

  Widget _buildFeatureGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 750 ? 3 : 2;

        const spacing = 12.0;

        final cardWidth =
            (constraints.maxWidth - ((columns - 1) * spacing)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,

          children: [
            _featureCard(
              width: cardWidth,
              icon: Icons.directions_car_outlined,
              title: 'Transport',
              description: 'Record journeys and view CO₂ impact.',
              color: blue,
            ),

            _featureCard(
              width: cardWidth,
              icon: Icons.bolt_outlined,
              title: 'Energy',
              description: 'Monitor appliance usage and energy consumption.',
              color: orange,
            ),

            _featureCard(
              width: cardWidth,
              icon: Icons.delete_outline_rounded,
              title: 'Waste',
              description: 'Track waste and recycling activity.',
              color: purple,
            ),

            _featureCard(
              width: cardWidth,
              icon: Icons.eco_outlined,
              title: 'Eco Habits',
              description: 'Build simple sustainable habits.',
              color: green,
            ),

            _featureCard(
              width: cardWidth,
              icon: Icons.flag_outlined,
              title: 'Goals',
              description: 'Create goals and monitor progress.',
              color: blue,
            ),

            _featureCard(
              width: cardWidth,
              icon: Icons.bar_chart_rounded,
              title: 'Reports',
              description: 'Understand your recorded environmental data.',
              color: orange,
            ),
          ],
        );
      },
    );
  }

  Widget _featureCard({
    required double width,
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return SizedBox(
      width: width,

      child: _whiteCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Container(
              width: 46,
              height: 46,

              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(13),
              ),

              child: Icon(icon, color: color, size: 24),
            ),

            const SizedBox(height: 13),

            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              description,
              style: const TextStyle(
                fontSize: 11.5,
                height: 1.4,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========================================================
  // HOW IT WORKS
  // ========================================================

  Widget _buildHowItWorks() {
    return _whiteCard(
      child: Column(
        children: [
          _stepItem(
            number: '01',
            icon: Icons.edit_note_rounded,
            title: 'Record',
            description:
                'Add your daily transport, energy and waste activities.',
            color: blue,
          ),

          _stepDivider(),

          _stepItem(
            number: '02',
            icon: Icons.insights_rounded,
            title: 'Understand',
            description:
                'View your environmental data through summaries and reports.',
            color: orange,
          ),

          _stepDivider(),

          _stepItem(
            number: '03',
            icon: Icons.flag_outlined,
            title: 'Improve',
            description: 'Set goals and develop better eco-friendly habits.',
            color: green,
          ),
        ],
      ),
    );
  }

  Widget _stepItem({
    required String number,
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Container(
          width: 45,
          height: 45,

          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(13),
          ),

          child: Icon(icon, color: color, size: 23),
        ),

        const SizedBox(width: 13),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Row(
                children: [
                  Text(
                    number,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),

                  const SizedBox(width: 8),

                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 4),

              Text(
                description,
                style: const TextStyle(
                  fontSize: 12,
                  height: 1.4,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _stepDivider() {
    return Padding(
      padding: const EdgeInsets.only(left: 22, top: 11, bottom: 11),

      child: Align(
        alignment: Alignment.centerLeft,

        child: Container(width: 1, height: 16, color: AppColors.border),
      ),
    );
  }

  // ========================================================
  // BENEFITS
  // ========================================================

  Widget _buildBenefits() {
    return _whiteCard(
      child: Column(
        children: [
          _benefitRow(
            icon: Icons.dashboard_outlined,
            title: 'One place for your eco activities',
            description:
                'Keep your environmental records organized in one app.',
          ),

          const SizedBox(height: 16),

          _benefitRow(
            icon: Icons.analytics_outlined,
            title: 'Simple progress tracking',
            description:
                'Use summaries, charts and goals to understand your progress.',
          ),

          const SizedBox(height: 16),

          _benefitRow(
            icon: Icons.lightbulb_outline_rounded,
            title: 'Encourages better choices',
            description: 'Small changes become easier to notice and maintain.',
          ),
        ],
      ),
    );
  }

  Widget _benefitRow({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Container(
          width: 42,
          height: 42,

          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),

          child: Icon(icon, color: AppColors.primary, size: 21),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                description,
                style: const TextStyle(
                  fontSize: 11.5,
                  height: 1.4,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ========================================================
  // BOTTOM CARD
  // ========================================================

  Widget _buildBottomCard() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(20),

        border: Border.all(color: AppColors.border),
      ),

      child: Column(
        children: [
          const Icon(Icons.eco_rounded, color: AppColors.primary, size: 30),

          const SizedBox(height: 9),

          const Text(
            'Personal Eco Tracker',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 5),

          const Text(
            'Track better. Live greener.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),

            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(20),
            ),

            child: const Text(
              'Version 1.0.0',
              style: TextStyle(
                fontSize: 10,
                color: AppColors.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ========================================================
  // COMMON WHITE CARD
  // ========================================================

  Widget _whiteCard({required Widget child}) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(18),

        border: Border.all(color: AppColors.border),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),

      child: child,
    );
  }
}
