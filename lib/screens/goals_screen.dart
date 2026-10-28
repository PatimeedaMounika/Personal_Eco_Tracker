import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/goal.dart';
import '../services/database_service.dart';
import '../theme/app_colors.dart';
import '../widgets/eco_image_banner.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  final DatabaseService _databaseService = DatabaseService();

  final TextEditingController _titleController = TextEditingController();

  final TextEditingController _targetController = TextEditingController();

  final TextEditingController _progressController = TextEditingController();

  DateTime? _selectedDeadline;

  List<Goal> _goals = [];

  bool _isLoading = true;

  // Goal-specific colors
  static const Color goalBlue = Color(0xFF1976D2);
  static const Color goalBlueDark = Color(0xFF1565C0);
  static const Color goalBlueSoft = Color(0xFFE3F2FD);
  static const Color goalTeal = Color(0xFF00897B);

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _targetController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  // ==========================================================
  // LOAD GOALS
  // ==========================================================

  Future<void> _loadGoals() async {
    final goals = await _databaseService.getGoals();

    if (!mounted) return;

    setState(() {
      _goals = goals;
      _isLoading = false;
    });
  }

  // ==========================================================
  // SELECT DEADLINE
  // ==========================================================

  Future<void> _selectDeadline() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: goalBlue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDeadline = pickedDate;
      });
    }
  }

  // ==========================================================
  // ADD GOAL
  // ==========================================================

  Future<void> _addGoal() async {
    final title = _titleController.text.trim();

    final target = double.tryParse(_targetController.text.trim());

    final progress = double.tryParse(_progressController.text.trim()) ?? 0;

    if (title.isEmpty || target == null || target <= 0) {
      _showMessage('Please enter a valid title and target.', isError: true);
      return;
    }

    if (progress < 0 || progress > target) {
      _showMessage('Progress must be between 0 and the target.', isError: true);
      return;
    }

    if (_selectedDeadline == null) {
      _showMessage('Please select a deadline.', isError: true);
      return;
    }

    final goal = Goal(
      title: title,
      target: target,
      progress: progress,
      deadline: DateFormat('yyyy-MM-dd').format(_selectedDeadline!),
    );

    await _databaseService.addGoal(goal);

    _titleController.clear();
    _targetController.clear();
    _progressController.clear();

    setState(() {
      _selectedDeadline = null;
    });

    await _loadGoals();

    if (!mounted) return;

    Navigator.pop(context);

    _showMessage('Goal added successfully.');
  }

  // ==========================================================
  // UPDATE PROGRESS
  // ==========================================================

  Future<void> _updateProgress(Goal goal) async {
    final controller = TextEditingController(text: goal.progress.toString());

    final newProgress = await showDialog<double>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text(
            'Update Progress',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: goalBlueSoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  goal.title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: goalBlueDark,
                  ),
                ),
              ),

              const SizedBox(height: 18),

              TextField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: 'Progress',
                  hintText: '0 - ${goal.target}',
                  prefixIcon: const Icon(
                    Icons.trending_up_rounded,
                    color: goalBlue,
                  ),
                  filled: true,
                  fillColor: AppColors.inputFill,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: goalBlue, width: 2),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: goalBlue,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                final value = double.tryParse(controller.text.trim());

                if (value == null || value < 0 || value > goal.target) {
                  return;
                }

                Navigator.pop(context, value);
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (newProgress == null) return;

    final updatedGoal = Goal(
      id: goal.id,
      title: goal.title,
      target: goal.target,
      progress: newProgress,
      deadline: goal.deadline,
    );

    await _databaseService.updateGoal(updatedGoal);

    await _loadGoals();
  }

  // ==========================================================
  // DELETE GOAL
  // ==========================================================

  Future<void> _deleteGoal(Goal goal) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text(
            'Delete Goal?',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          content: Text(
            'Are you sure you want to delete '
            '"${goal.title}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm == true && goal.id != null) {
      await _databaseService.deleteGoal(goal.id!);

      await _loadGoals();

      _showMessage('Goal deleted.');
    }
  }

  // ==========================================================
  // ADD GOAL BOTTOM SHEET
  // ==========================================================

  void _showAddGoalDialog() {
    _titleController.clear();
    _targetController.clear();
    _progressController.text = '0';

    setState(() {
      _selectedDeadline = null;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // HEADER
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: goalBlueSoft,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.flag_rounded, color: goalBlue),
                    ),

                    const SizedBox(width: 13),

                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Create New Goal',
                            style: TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Set a target and track your progress.',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                _buildInputLabel('Goal Title'),

                const SizedBox(height: 8),

                TextField(
                  controller: _titleController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: _inputDecoration(
                    hintText: 'Example: Reduce plastic waste',
                    icon: Icons.flag_outlined,
                    color: goalBlue,
                  ),
                ),

                const SizedBox(height: 18),

                _buildInputLabel('Target'),

                const SizedBox(height: 8),

                TextField(
                  controller: _targetController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: _inputDecoration(
                    hintText: 'Example: 10',
                    icon: Icons.track_changes_rounded,
                    color: goalTeal,
                  ),
                ),

                const SizedBox(height: 18),

                _buildInputLabel('Current Progress'),

                const SizedBox(height: 8),

                TextField(
                  controller: _progressController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: _inputDecoration(
                    hintText: 'Example: 2',
                    icon: Icons.trending_up_rounded,
                    color: goalBlue,
                  ),
                ),

                const SizedBox(height: 18),

                _buildInputLabel('Deadline'),

                const SizedBox(height: 8),

                InkWell(
                  onTap: _selectDeadline,
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.inputFill,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: goalBlueSoft,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.calendar_month_rounded,
                            color: goalBlue,
                            size: 21,
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: Text(
                            _selectedDeadline == null
                                ? 'Select Deadline'
                                : DateFormat(
                                    'dd MMM yyyy',
                                  ).format(_selectedDeadline!),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: _selectedDeadline == null
                                  ? FontWeight.w400
                                  : FontWeight.w600,
                              color: _selectedDeadline == null
                                  ? AppColors.textSecondary
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),

                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 15,
                          color: AppColors.textMuted,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _addGoal,
                    icon: const Icon(Icons.add_rounded),
                    label: const Text(
                      'Add Goal',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: goalBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    required IconData icon,
    required Color color,
  }) {
    return InputDecoration(
      hintText: hintText,
      prefixIcon: Icon(icon, color: color),
      filled: true,
      fillColor: AppColors.inputFill,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: color, width: 2),
      ),
    );
  }

  Widget _buildInputLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
      ),
    );
  }

  // ==========================================================
  // PERCENTAGE
  // ==========================================================

  double _percentage(Goal goal) {
    if (goal.target <= 0) {
      return 0;
    }

    final value = goal.progress / goal.target;

    return value.clamp(0.0, 1.0);
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        title: const Text(
          'My Eco Goals',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _loadGoals,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddGoalDialog,
        backgroundColor: goalBlue,
        foregroundColor: Colors.white,
        elevation: 3,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Add Goal',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),

      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 18, 20, 0),
            child: EcoImageBanner(
              imageAsset: 'assets/images/goals.jpg',
              label: 'Set goals for a greener future',
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: goalBlue),
                  )
                : _goals.isEmpty
                ? _emptyState()
                : RefreshIndicator(
                    color: goalBlue,
                    onRefresh: _loadGoals,
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 100),
                      itemCount: _goals.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return _bannerCard();
                        }

                        return _goalCard(_goals[index - 1]);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // BANNER CARD
  // ==========================================================

  Widget _bannerCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [goalBlueDark, goalTeal],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: goalBlue.withValues(alpha: 0.15),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.flag_rounded,
              color: Colors.white,
              size: 29,
            ),
          ),

          const SizedBox(width: 14),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Eco Goals',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Set targets and turn them into daily progress.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12.5,
                    height: 1.4,
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
  // EMPTY STATE
  // ==========================================================

  Widget _emptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 112,
              height: 112,
              decoration: BoxDecoration(
                color: goalBlueSoft,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFBBDEFB), width: 2),
              ),
              child: const Icon(Icons.flag_rounded, size: 52, color: goalBlue),
            ),

            const SizedBox(height: 24),

            const Text(
              'No Goals Yet',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              'Create your first eco goal and start\n'
              'tracking your progress.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _showAddGoalDialog,
                icon: const Icon(Icons.add_rounded),
                label: const Text(
                  'Create Goal',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  backgroundColor: goalBlue,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // GOAL CARD
  // ==========================================================

  Widget _goalCard(Goal goal) {
    final percentage = _percentage(goal);

    final completed = percentage >= 1.0;

    final progressColor = completed ? AppColors.green700 : goalBlue;

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: completed ? AppColors.green50 : goalBlueSoft,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  completed ? Icons.emoji_events_rounded : Icons.flag_rounded,
                  color: progressColor,
                  size: 27,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal.title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 13,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          _formatDeadline(goal.deadline ?? ''),
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              PopupMenuButton<String>(
                tooltip: 'Goal options',
                icon: const Icon(
                  Icons.more_vert_rounded,
                  color: AppColors.textSecondary,
                ),
                onSelected: (value) {
                  if (value == 'update') {
                    _updateProgress(goal);
                  } else if (value == 'delete') {
                    _deleteGoal(goal);
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'update',
                    child: Row(
                      children: [
                        Icon(Icons.trending_up_rounded, size: 19),
                        SizedBox(width: 10),
                        Text('Update Progress'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_outline_rounded,
                          size: 19,
                          color: AppColors.error,
                        ),
                        SizedBox(width: 10),
                        Text('Delete'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_cleanNumber(goal.progress)} / '
                '${_cleanNumber(goal.target)}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: progressColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${(percentage * 100).round()}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: progressColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 10,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),

          const SizedBox(height: 16),

          if (completed)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.green50,
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.green700,
                    size: 21,
                  ),
                  SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      'Goal completed! Great job.',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.green800,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            Row(
              children: [
                const Icon(
                  Icons.flag_outlined,
                  size: 17,
                  color: AppColors.textMuted,
                ),
                const SizedBox(width: 6),
                const Text(
                  'Keep working towards your goal',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  // ==========================================================
  // DEADLINE FORMAT
  // ==========================================================

  String _formatDeadline(String deadline) {
    try {
      final date = DateTime.parse(deadline);

      return DateFormat('dd MMM yyyy').format(date);
    } catch (_) {
      return deadline;
    }
  }

  // ==========================================================
  // NUMBER FORMAT
  // ==========================================================

  String _cleanNumber(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(2);
  }

  // ==========================================================
  // MESSAGE
  // ==========================================================

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? AppColors.error : AppColors.primary,
      ),
    );
  }
}
