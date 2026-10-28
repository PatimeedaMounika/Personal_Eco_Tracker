import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/eco_image_banner.dart';

class EcoHabitsScreen extends StatefulWidget {
  const EcoHabitsScreen({super.key});

  @override
  State<EcoHabitsScreen> createState() => _EcoHabitsScreenState();
}

class _EcoHabitsScreenState extends State<EcoHabitsScreen> {
  static const Color habitGreen = Color(0xFF388E3C);
  static const Color habitGreenSoft = Color(0xFFE8F5E9);

  final List<Map<String, dynamic>> _habits = [
    {
      'title': 'Use reusable water bottle',
      'description': 'Avoid single-use plastic bottles',
      'icon': Icons.water_drop_rounded,
      'color': Color(0xFF1976D2),
      'completed': false,
    },
    {
      'title': 'Use public transport',
      'description': 'Choose bus, train or shared transport',
      'icon': Icons.directions_bus_rounded,
      'color': Color(0xFF00897B),
      'completed': false,
    },
    {
      'title': 'Switch off unused lights',
      'description': 'Save electricity when not needed',
      'icon': Icons.lightbulb_rounded,
      'color': Color(0xFFF9A825),
      'completed': false,
    },
    {
      'title': 'Avoid food waste',
      'description': 'Take only the food you need',
      'icon': Icons.restaurant_rounded,
      'color': Color(0xFFEF6C00),
      'completed': false,
    },
    {
      'title': 'Carry reusable bags',
      'description': 'Avoid unnecessary plastic bags',
      'icon': Icons.shopping_bag_rounded,
      'color': Color(0xFF7B1FA2),
      'completed': false,
    },
    {
      'title': 'Plant or care for a plant',
      'description': 'Add more greenery to your surroundings',
      'icon': Icons.local_florist_rounded,
      'color': Color(0xFF388E3C),
      'completed': false,
    },
  ];

  int get completedHabits {
    return _habits.where((habit) => habit['completed'] == true).length;
  }

  double get progress {
    if (_habits.isEmpty) return 0;

    return completedHabits / _habits.length;
  }

  void _toggleHabit(int index) {
    setState(() {
      _habits[index]['completed'] = !(_habits[index]['completed'] as bool);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Eco Habits',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: habitGreenSoft,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$completedHabits/${_habits.length}',
                  style: const TextStyle(
                    color: habitGreen,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 35),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 850),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const EcoImageBanner(
                    imageAsset: 'assets/images/eco_habits.jpg',
                    label: 'Simple habits make a lasting difference',
                  ),

                  const SizedBox(height: 18),

                  _buildHero(),

                  const SizedBox(height: 22),

                  _buildProgressCard(),

                  const SizedBox(height: 18),

                  _buildMotivationCard(),

                  const SizedBox(height: 28),

                  const Text(
                    "Today's Eco Habits",
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 5),

                  const Text(
                    'Complete simple actions to build sustainable habits.',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: AppColors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 14),

                  ...List.generate(_habits.length, (index) {
                    return _buildHabitCard(index, _habits[index]);
                  }),

                  if (completedHabits == _habits.length) ...[
                    const SizedBox(height: 6),
                    _buildCompletionCard(),
                  ],

                  const SizedBox(height: 15),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // HERO
  // ----------------------------------------------------------

  Widget _buildHero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF263238), habitGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: habitGreen.withValues(alpha: 0.18),
            blurRadius: 22,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Build Better Habits',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Small daily actions can create a greener '
                  'and healthier future.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13.5,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 17),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Small actions • Big impact',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 15),

          Container(
            width: 82,
            height: 82,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.12),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.65),
                width: 2,
              ),
            ),
            child: const Icon(Icons.eco_rounded, size: 42, color: Colors.white),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  // PROGRESS
  // ----------------------------------------------------------

  Widget _buildProgressCard() {
    final percentage = (progress * 100).round();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: habitGreenSoft,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.track_changes_rounded,
                  color: habitGreen,
                  size: 25,
                ),
              ),

              const SizedBox(width: 13),

              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Today's Progress",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Keep completing your daily habits.',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              Text(
                '$percentage%',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: habitGreen,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$completedHabits of ${_habits.length} completed',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),

              Text(
                progress == 1 ? 'Completed!' : 'Keep going',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: progress == 1 ? const Color(0xFF2E7D32) : habitGreen,
                ),
              ),
            ],
          ),

          const SizedBox(height: 9),

          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: const Color(0xFFE5E9EC),
              valueColor: const AlwaysStoppedAnimation<Color>(habitGreen),
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  // MOTIVATION
  // ----------------------------------------------------------

  Widget _buildMotivationCard() {
    final remaining = _habits.length - completedHabits;

    final message = remaining == 0
        ? 'You completed every habit today!'
        : remaining == 1
        ? 'Only one more habit to complete!'
        : '$remaining habits left for today. Keep going!';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F7F4),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFDCE9DF)),
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              remaining == 0
                  ? Icons.emoji_events_rounded
                  : Icons.lightbulb_outline_rounded,
              color: habitGreen,
              size: 25,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  remaining == 0 ? 'Great work!' : 'Keep going!',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2E5D35),
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  message,
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
      ),
    );
  }

  // ----------------------------------------------------------
  // HABIT CARD
  // ----------------------------------------------------------

  Widget _buildHabitCard(int index, Map<String, dynamic> habit) {
    final bool isCompleted = habit['completed'] as bool;

    final Color color = habit['color'] as Color;

    final IconData icon = habit['icon'] as IconData;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: isCompleted ? habitGreenSoft : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isCompleted ? const Color(0xFFA5D6A7) : AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _toggleHabit(index),
        borderRadius: BorderRadius.circular(18),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: isCompleted
                    ? color.withValues(alpha: 0.15)
                    : color.withValues(alpha: 0.09),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                isCompleted ? Icons.check_rounded : icon,
                color: color,
                size: 26,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    habit['title'] as String,
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: isCompleted
                          ? AppColors.textSecondary
                          : AppColors.textPrimary,
                      decoration: isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    habit['description'] as String,
                    style: const TextStyle(
                      fontSize: 11.5,
                      height: 1.35,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            Transform.scale(
              scale: 1.05,
              child: Checkbox(
                value: isCompleted,
                activeColor: color,
                checkColor: Colors.white,
                side: BorderSide(
                  color: color.withValues(alpha: 0.55),
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                onChanged: (_) {
                  _toggleHabit(index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // COMPLETION CARD
  // ----------------------------------------------------------

  Widget _buildCompletionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE8F5E9), Color(0xFFF3F8F3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFA5D6A7)),
      ),
      child: Column(
        children: [
          Container(
            width: 65,
            height: 65,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.celebration_rounded,
              color: Color(0xFF2E7D32),
              size: 36,
            ),
          ),

          const SizedBox(height: 12),

          const Text(
            'Amazing!',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w800,
              color: Color(0xFF2E7D32),
            ),
          ),

          const SizedBox(height: 5),

          const Text(
            'You completed all your eco habits today!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12.5, color: Color(0xFF388E3C)),
          ),
        ],
      ),
    );
  }
}
