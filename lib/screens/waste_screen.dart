import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/waste.dart';
import '../services/database_service.dart';
import '../theme/app_colors.dart';
import '../widgets/eco_image_banner.dart';

class WasteScreen extends StatefulWidget {
  const WasteScreen({super.key});

  @override
  State<WasteScreen> createState() => _WasteScreenState();
}

class _WasteScreenState extends State<WasteScreen> {
  final DatabaseService _databaseService = DatabaseService();
  final TextEditingController _quantityController = TextEditingController();

  String _selectedWasteType = 'Plastic';
  bool _isRecycled = true;

  List<Waste> _wasteList = [];

  static const Color wastePurple = Color(0xFF7B1FA2);
  static const Color wastePurpleLight = Color(0xFFAB47BC);
  static const Color wastePurpleSoft = Color(0xFFF3E5F5);
  static const Color wastePurpleVeryLight = Color(0xFFFAF5FC);

  final List<String> _wasteTypes = [
    'Plastic',
    'Paper',
    'Glass',
    'Metal',
    'Food Waste',
    'E-Waste',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _loadWaste();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  // ----------------------------------------------------------
  // DATABASE
  // ----------------------------------------------------------

  Future<void> _loadWaste() async {
    final data = await _databaseService.getWaste();

    if (!mounted) return;

    setState(() {
      _wasteList = data;
    });
  }

  Future<void> _saveWaste() async {
    final quantity = double.tryParse(_quantityController.text.trim());

    if (quantity == null || quantity <= 0) {
      _showMessage('Please enter a valid waste quantity.', isError: true);
      return;
    }

    final waste = Waste(
      wasteType: _selectedWasteType,
      quantity: quantity,
      recycled: _isRecycled,
      date: DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
    );

    await _databaseService.addWaste(waste);

    _quantityController.clear();

    setState(() {
      _isRecycled = true;
    });

    await _loadWaste();

    if (!mounted) return;

    _showMessage('Waste record saved successfully.');
  }

  Future<void> _deleteWaste(int id) async {
    await _databaseService.deleteWaste(id);

    await _loadWaste();

    if (!mounted) return;

    _showMessage('Waste record deleted.');
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? AppColors.error : AppColors.primary,
      ),
    );
  }

  // ----------------------------------------------------------
  // HELPERS
  // ----------------------------------------------------------

  IconData _getWasteIcon(String type) {
    switch (type) {
      case 'Plastic':
        return Icons.local_drink_rounded;

      case 'Paper':
        return Icons.description_rounded;

      case 'Glass':
        return Icons.wine_bar_rounded;

      case 'Metal':
        return Icons.build_rounded;

      case 'Food Waste':
        return Icons.restaurant_rounded;

      case 'E-Waste':
        return Icons.devices_rounded;

      case 'Other':
        return Icons.delete_outline_rounded;

      default:
        return Icons.delete_outline_rounded;
    }
  }

  Color _getWasteColor(String type) {
    switch (type) {
      case 'Plastic':
        return const Color(0xFF1976D2);

      case 'Paper':
        return const Color(0xFF795548);

      case 'Glass':
        return const Color(0xFF00897B);

      case 'Metal':
        return const Color(0xFF607D8B);

      case 'Food Waste':
        return const Color(0xFFEF6C00);

      case 'E-Waste':
        return const Color(0xFF5E35B1);

      case 'Other':
        return const Color(0xFF757575);

      default:
        return const Color(0xFF757575);
    }
  }

  double get _totalWaste {
    return _wasteList.fold(0.0, (sum, item) => sum + item.quantity);
  }

  double get _recycledWaste {
    return _wasteList
        .where((item) => item.recycled)
        .fold(0.0, (sum, item) => sum + item.quantity);
  }

  double get _nonRecycledWaste {
    return _totalWaste - _recycledWaste;
  }

  // ----------------------------------------------------------
  // BUILD
  // ----------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Waste',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _loadWaste,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: wastePurple,
        onRefresh: _loadWaste,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 35),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 850),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const EcoImageBanner(
                    imageAsset: 'assets/images/recycling.jpg',
                    label: 'Sort waste today to protect tomorrow',
                  ),

                  const SizedBox(height: 18),

                  _buildHero(),

                  const SizedBox(height: 22),

                  _buildSummary(),

                  const SizedBox(height: 28),

                  _buildSectionTitle(
                    'Add Waste Record',
                    'Record the type and quantity of waste you generate.',
                  ),

                  const SizedBox(height: 14),

                  _buildWasteForm(),

                  const SizedBox(height: 30),

                  _buildRecentWaste(),
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
          colors: [wastePurple, wastePurpleLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: wastePurple.withValues(alpha: 0.20),
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
                  'Manage Your Waste',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Track the waste you generate and '
                  'record your recycling activities.',
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
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Reduce • Reuse • Recycle',
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
              color: Colors.white.withValues(alpha: 0.13),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.65),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.recycling_rounded,
              size: 43,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  // SUMMARY
  // ----------------------------------------------------------

  Widget _buildSummary() {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            title: 'Total Waste',
            value: '${_totalWaste.toStringAsFixed(1)} kg',
            icon: Icons.delete_outline_rounded,
            color: wastePurple,
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: _buildSummaryCard(
            title: 'Recycled',
            value: '${_recycledWaste.toStringAsFixed(1)} kg',
            icon: Icons.recycling_rounded,
            color: const Color(0xFF00897B),
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: _buildSummaryCard(
            title: 'Other',
            value: '${_nonRecycledWaste.toStringAsFixed(1)} kg',
            icon: Icons.delete_sweep_outlined,
            color: const Color(0xFFEF6C00),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 21),
          ),

          const SizedBox(height: 9),

          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10.5,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  // SECTION TITLE
  // ----------------------------------------------------------

  Widget _buildSectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 12.5,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  // ----------------------------------------------------------
  // FORM
  // ----------------------------------------------------------

  Widget _buildWasteForm() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Waste Type',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 9),

          _buildWasteSelector(),

          const SizedBox(height: 20),

          const Text(
            'Quantity',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 9),

          TextField(
            controller: _quantityController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              hintText: 'Enter waste quantity',
              suffixText: 'kg',
              prefixIcon: const Icon(Icons.scale_outlined, color: wastePurple),
              filled: true,
              fillColor: wastePurpleVeryLight,
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
                borderSide: const BorderSide(color: wastePurple, width: 2),
              ),
            ),
          ),

          const SizedBox(height: 20),

          _buildRecyclingSelector(),

          const SizedBox(height: 22),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _saveWaste,
              icon: const Icon(Icons.add_rounded, size: 21),
              label: const Text(
                'Save Waste Record',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: wastePurple,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  // WASTE SELECTOR
  // ----------------------------------------------------------

  Widget _buildWasteSelector() {
    final selectedColor = _getWasteColor(_selectedWasteType);

    return DropdownButtonFormField<String>(
      initialValue: _selectedWasteType,
      decoration: InputDecoration(
        prefixIcon: Icon(
          _getWasteIcon(_selectedWasteType),
          color: selectedColor,
        ),
        filled: true,
        fillColor: wastePurpleVeryLight,
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
          borderSide: const BorderSide(color: wastePurple, width: 2),
        ),
      ),
      items: _wasteTypes.map((type) {
        final color = _getWasteColor(type);

        return DropdownMenuItem<String>(
          value: type,
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(_getWasteIcon(type), color: color, size: 20),
              ),

              const SizedBox(width: 11),

              Text(
                type,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        if (value == null) return;

        setState(() {
          _selectedWasteType = value;
        });
      },
    );
  }

  // ----------------------------------------------------------
  // RECYCLING SELECTOR
  // ----------------------------------------------------------

  Widget _buildRecyclingSelector() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: wastePurpleVeryLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _isRecycled
                  ? const Color(0xFFE8F5E9)
                  : const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              _isRecycled
                  ? Icons.recycling_rounded
                  : Icons.delete_outline_rounded,
              color: _isRecycled
                  ? const Color(0xFF2E7D32)
                  : const Color(0xFFEF6C00),
            ),
          ),

          const SizedBox(width: 12),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recycling Status',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),

                SizedBox(height: 3),

                Text(
                  'Was this waste recycled?',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          Switch(
            value: _isRecycled,
            activeThumbColor: const Color(0xFF2E7D32),
            onChanged: (value) {
              setState(() {
                _isRecycled = value;
              });
            },
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  // RECENT WASTE
  // ----------------------------------------------------------

  Widget _buildRecentWaste() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Waste Records',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),

            if (_wasteList.isNotEmpty)
              Text(
                '${_wasteList.length} recorded',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
          ],
        ),

        const SizedBox(height: 14),

        if (_wasteList.isEmpty)
          _buildEmptyState()
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _wasteList.length,
            itemBuilder: (context, index) {
              final waste = _wasteList[index];

              return _buildWasteTile(waste);
            },
          ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: const BoxDecoration(
              color: wastePurpleSoft,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.recycling_outlined,
              color: wastePurple,
              size: 32,
            ),
          ),

          const SizedBox(height: 14),

          const Text(
            'No waste records yet',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 5),

          const Text(
            'Add your first waste record above\n'
            'to start tracking your waste management.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              height: 1.4,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  // WASTE TILE
  // ----------------------------------------------------------

  Widget _buildWasteTile(Waste waste) {
    final color = _getWasteColor(waste.wasteType);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
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
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(_getWasteIcon(waste.wasteType), color: color, size: 25),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  waste.wasteType,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  '${waste.quantity.toStringAsFixed(1)} kg',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  waste.date,
                  style: const TextStyle(
                    fontSize: 10.5,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: waste.recycled
                      ? const Color(0xFFE8F5E9)
                      : const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  waste.recycled ? 'Recycled' : 'Not Recycled',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: waste.recycled
                        ? const Color(0xFF2E7D32)
                        : const Color(0xFFEF6C00),
                  ),
                ),
              ),

              const SizedBox(height: 6),

              InkWell(
                onTap: () {
                  if (waste.id != null) {
                    _deleteWaste(waste.id!);
                  }
                },
                borderRadius: BorderRadius.circular(10),
                child: const Padding(
                  padding: EdgeInsets.all(5),
                  child: Icon(
                    Icons.delete_outline_rounded,
                    size: 20,
                    color: AppColors.error,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
