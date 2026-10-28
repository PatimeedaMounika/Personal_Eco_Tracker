import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/energy.dart';
import '../services/database_service.dart';
import '../theme/app_colors.dart';
import '../widgets/eco_image_banner.dart';

class EnergyScreen extends StatefulWidget {
  const EnergyScreen({super.key});

  @override
  State<EnergyScreen> createState() => _EnergyScreenState();
}

class _EnergyScreenState extends State<EnergyScreen> {
  final DatabaseService _databaseService = DatabaseService();
  final TextEditingController _hoursController = TextEditingController();

  String _selectedAppliance = 'Fan';
  double _estimatedUnits = 0.0;

  List<Energy> _energyList = [];

  // Power ratings in kW.
  final Map<String, double> _powerRatings = {
    'Fan': 0.075,
    'LED Light': 0.010,
    'TV': 0.100,
    'Refrigerator': 0.150,
    'Washing Machine': 0.500,
    'Air Conditioner': 1.500,
    'Laptop': 0.065,
    'Water Heater': 2.000,
  };

  @override
  void initState() {
    super.initState();
    _loadEnergy();
  }

  @override
  void dispose() {
    _hoursController.dispose();
    super.dispose();
  }

  // ==========================================================
  // DATABASE
  // ==========================================================

  Future<void> _loadEnergy() async {
    final data = await _databaseService.getEnergy();

    if (!mounted) return;

    setState(() {
      _energyList = data;
    });
  }

  Future<void> _saveEnergy() async {
    final hours = double.tryParse(_hoursController.text);

    if (hours == null || hours <= 0) {
      _showMessage('Please enter valid usage hours.', isError: true);
      return;
    }

    final units = _calculateUnits(_selectedAppliance, hours);

    final energy = Energy(
      appliance: _selectedAppliance,
      usageHours: hours,
      estimatedUnits: units,
      date: DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
    );

    await _databaseService.addEnergy(energy);

    _hoursController.clear();

    setState(() {
      _estimatedUnits = 0.0;
    });

    await _loadEnergy();

    if (!mounted) return;

    _showMessage('Energy usage saved successfully.');
  }

  Future<void> _deleteEnergy(int id) async {
    await _databaseService.deleteEnergy(id);

    await _loadEnergy();

    if (!mounted) return;

    _showMessage('Energy record deleted.');
  }

  // ==========================================================
  // CALCULATION
  // ==========================================================

  double _calculateUnits(String appliance, double hours) {
    final power = _powerRatings[appliance] ?? 0.0;

    return power * hours;
  }

  void _calculate() {
    final hours = double.tryParse(_hoursController.text);

    if (hours == null || hours <= 0) {
      setState(() {
        _estimatedUnits = 0.0;
      });
      return;
    }

    setState(() {
      _estimatedUnits = _calculateUnits(_selectedAppliance, hours);
    });
  }

  // ==========================================================
  // MESSAGE
  // ==========================================================

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? AppColors.error : AppColors.primary,
      ),
    );
  }

  // ==========================================================
  // ICON
  // ==========================================================

  IconData _getApplianceIcon(String appliance) {
    switch (appliance) {
      case 'Fan':
        return Icons.toys_rounded;
      case 'LED Light':
        return Icons.lightbulb_rounded;
      case 'TV':
        return Icons.tv_rounded;
      case 'Refrigerator':
        return Icons.kitchen_rounded;
      case 'Washing Machine':
        return Icons.local_laundry_service_rounded;
      case 'Air Conditioner':
        return Icons.ac_unit_rounded;
      case 'Laptop':
        return Icons.laptop_rounded;
      case 'Water Heater':
        return Icons.water_rounded;
      default:
        return Icons.electrical_services_rounded;
    }
  }

  Color _getApplianceColor(String appliance) {
    switch (appliance) {
      case 'Fan':
        return AppColors.secondary;
      case 'LED Light':
        return AppColors.energy;
      case 'TV':
        return const Color(0xFF7B1FA2);
      case 'Refrigerator':
        return AppColors.secondary;
      case 'Washing Machine':
        return const Color(0xFF00838F);
      case 'Air Conditioner':
        return const Color(0xFF1565C0);
      case 'Laptop':
        return AppColors.textSecondary;
      case 'Water Heater':
        return const Color(0xFFE65100);
      default:
        return AppColors.textSecondary;
    }
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Energy',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            Text(
              'Track your electricity usage',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),

      body: RefreshIndicator(
        color: AppColors.energy,
        onRefresh: _loadEnergy,

        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),

          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),

          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  const EcoImageBanner(
                    imageAsset: 'assets/images/energy.jpg',
                    label: 'Choose cleaner energy for a brighter future',
                  ),

                  const SizedBox(height: 18),

                  _buildHero(),

                  const SizedBox(height: 28),

                  const Text(
                    'Add Energy Usage',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 5),

                  const Text(
                    'Record how long you use an appliance.',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 14),

                  _buildEnergyForm(),

                  const SizedBox(height: 30),

                  _buildRecentEnergy(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // HERO
  // ==========================================================

  Widget _buildHero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),

      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF57C00), Color(0xFFFFA726)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),

        borderRadius: BorderRadius.circular(22),

        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF57C00).withValues(alpha: 0.18),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),

      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SMART ENERGY',
                  style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 0.9,
                    fontWeight: FontWeight.w700,
                    color: Colors.white70,
                  ),
                ),

                SizedBox(height: 10),

                Text(
                  'Track your energy.',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),

                SizedBox(height: 7),

                Text(
                  'Monitor appliance usage and understand your estimated electricity consumption.',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 18),

          Container(
            width: 72,
            height: 72,

            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(20),
            ),

            child: const Icon(
              Icons.bolt_rounded,
              size: 42,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // FORM
  // ==========================================================

  Widget _buildEnergyForm() {
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
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          const Text(
            'Appliance',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 8),

          _buildApplianceSelector(),

          const SizedBox(height: 20),

          const Text(
            'Usage Duration',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 8),

          TextField(
            controller: _hoursController,

            keyboardType: const TextInputType.numberWithOptions(decimal: true),

            onChanged: (_) => _calculate(),

            decoration: InputDecoration(
              hintText: 'Enter usage hours',
              suffixText: 'hours',

              prefixIcon: const Icon(
                Icons.schedule_rounded,
                color: AppColors.energy,
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
                borderSide: const BorderSide(color: AppColors.energy, width: 2),
              ),
            ),
          ),

          const SizedBox(height: 20),

          _buildEnergyResult(),

          const SizedBox(height: 10),

          const Text(
            'Estimated consumption is calculated using the selected appliance power rating.',
            style: TextStyle(
              fontSize: 11.5,
              height: 1.45,
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            height: 52,

            child: ElevatedButton.icon(
              onPressed: _saveEnergy,

              icon: const Icon(Icons.add_rounded),

              label: const Text(
                'Save Energy Usage',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),

              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.energy,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // APPLIANCE SELECTOR
  // ==========================================================

  Widget _buildApplianceSelector() {
    final selectedColor = _getApplianceColor(_selectedAppliance);

    return DropdownButtonFormField<String>(
      initialValue: _selectedAppliance,

      decoration: InputDecoration(
        hintText: 'Select appliance',

        prefixIcon: Icon(
          _getApplianceIcon(_selectedAppliance),
          color: selectedColor,
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
          borderSide: const BorderSide(color: AppColors.energy, width: 2),
        ),
      ),

      items: _powerRatings.keys.map((appliance) {
        final color = _getApplianceColor(appliance);

        return DropdownMenuItem<String>(
          value: appliance,

          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,

                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                ),

                child: Icon(
                  _getApplianceIcon(appliance),
                  color: color,
                  size: 20,
                ),
              ),

              const SizedBox(width: 11),

              Text(
                appliance,
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
          _selectedAppliance = value;
        });

        _calculate();
      },
    );
  }

  // ==========================================================
  // RESULT
  // ==========================================================

  Widget _buildEnergyResult() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(17),

      decoration: BoxDecoration(
        color: AppColors.energy.withValues(alpha: 0.07),

        borderRadius: BorderRadius.circular(18),

        border: Border.all(color: AppColors.energy.withValues(alpha: 0.20)),
      ),

      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,

            decoration: BoxDecoration(
              color: AppColors.energy.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(15),
            ),

            child: const Icon(
              Icons.bolt_rounded,
              color: AppColors.energy,
              size: 29,
            ),
          ),

          const SizedBox(width: 14),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Estimated Energy',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),

                SizedBox(height: 4),

                Text(
                  'Based on appliance and usage time',
                  style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
              ],
            ),
          ),

          Text(
            '${_estimatedUnits.toStringAsFixed(2)} kWh',
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: AppColors.energy,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // RECENT ENERGY
  // ==========================================================

  Widget _buildRecentEnergy() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,

          children: [
            const Text(
              'Recent Energy Usage',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),

            if (_energyList.isNotEmpty)
              Text(
                '${_energyList.length} recorded',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
          ],
        ),

        const SizedBox(height: 14),

        if (_energyList.isEmpty)
          _buildEmptyState()
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),

            itemCount: _energyList.length,

            itemBuilder: (context, index) {
              return _buildEnergyTile(_energyList[index]);
            },
          ),
      ],
    );
  }

  // ==========================================================
  // EMPTY STATE
  // ==========================================================

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(20),

        border: Border.all(color: AppColors.border),
      ),

      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,

            decoration: BoxDecoration(
              color: AppColors.energy.withValues(alpha: 0.09),
              shape: BoxShape.circle,
            ),

            child: const Icon(
              Icons.bolt_outlined,
              color: AppColors.energy,
              size: 30,
            ),
          ),

          const SizedBox(height: 14),

          const Text(
            'No energy records yet',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 5),

          const Text(
            'Add your first appliance usage above to start tracking energy consumption.',
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

  // ==========================================================
  // ENERGY TILE
  // ==========================================================

  Widget _buildEnergyTile(Energy energy) {
    final color = _getApplianceColor(energy.appliance);

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
            blurRadius: 8,
            offset: const Offset(0, 3),
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

            child: Icon(
              _getApplianceIcon(energy.appliance),
              color: color,
              size: 24,
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  energy.appliance,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  '${energy.usageHours.toStringAsFixed(1)} hours',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  energy.date,
                  style: const TextStyle(
                    fontSize: 10.5,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,

            children: [
              Text(
                '${energy.estimatedUnits.toStringAsFixed(2)} kWh',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),

              const SizedBox(height: 6),

              InkWell(
                onTap: () {
                  if (energy.id != null) {
                    _deleteEnergy(energy.id!);
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
