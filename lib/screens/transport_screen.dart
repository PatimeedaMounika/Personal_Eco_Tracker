import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/transport.dart';
import '../services/database_service.dart';
import '../theme/app_colors.dart';
import '../widgets/eco_image_banner.dart';

class TransportScreen extends StatefulWidget {
  const TransportScreen({super.key});

  @override
  State<TransportScreen> createState() => _TransportScreenState();
}

class _TransportScreenState extends State<TransportScreen> {
  final DatabaseService _databaseService = DatabaseService();

  final TextEditingController _distanceController = TextEditingController();

  String _selectedMode = 'Cycling';
  double _estimatedEmission = 0.0;

  List<Transport> _transportList = [];

  // kg CO₂e per km
  final Map<String, double> _emissionFactors = {
    'Walking': 0.000,
    'Cycling': 0.021,
    'Bus': 0.089,
    'Train': 0.041,
    'Car': 0.192,
    'Bike': 0.103,
  };

  @override
  void initState() {
    super.initState();
    _loadTransport();
  }

  @override
  void dispose() {
    _distanceController.dispose();
    super.dispose();
  }

  // ==========================================================
  // DATABASE
  // ==========================================================

  Future<void> _loadTransport() async {
    final data = await _databaseService.getTransport();

    if (!mounted) return;

    setState(() {
      _transportList = data;
    });
  }

  Future<void> _saveJourney() async {
    final distance = double.tryParse(_distanceController.text);

    if (distance == null || distance <= 0) {
      _showMessage('Please enter a valid distance.', isError: true);
      return;
    }

    final emission = _calculateEmission(_selectedMode, distance);

    final transport = Transport(
      mode: _selectedMode,
      distance: distance,
      co2Emission: emission,
      date: DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
    );

    await _databaseService.addTransport(transport);

    _distanceController.clear();

    setState(() {
      _estimatedEmission = 0.0;
    });

    await _loadTransport();

    if (!mounted) return;

    _showMessage('Journey saved successfully.');
  }

  Future<void> _deleteTransport(int id) async {
    await _databaseService.deleteTransport(id);

    await _loadTransport();

    if (!mounted) return;

    _showMessage('Journey deleted.');
  }

  // ==========================================================
  // CALCULATIONS
  // ==========================================================

  double _calculateEmission(String mode, double distance) {
    final factor = _emissionFactors[mode] ?? 0.0;

    return factor * distance;
  }

  void _calculate() {
    final distance = double.tryParse(_distanceController.text);

    if (distance == null || distance <= 0) {
      setState(() {
        _estimatedEmission = 0.0;
      });
      return;
    }

    setState(() {
      _estimatedEmission = _calculateEmission(_selectedMode, distance);
    });
  }

  // ==========================================================
  // MESSAGES
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
  // ICONS & COLORS
  // ==========================================================

  IconData _getTransportIcon(String mode) {
    switch (mode) {
      case 'Walking':
        return Icons.directions_walk_rounded;

      case 'Cycling':
        return Icons.directions_bike_rounded;

      case 'Bus':
        return Icons.directions_bus_rounded;

      case 'Train':
        return Icons.train_rounded;

      case 'Car':
        return Icons.directions_car_rounded;

      case 'Bike':
        return Icons.two_wheeler_rounded;

      default:
        return Icons.directions_rounded;
    }
  }

  Color _getTransportColor(String mode) {
    switch (mode) {
      case 'Walking':
        return AppColors.green700;

      case 'Cycling':
        return AppColors.primary;

      case 'Bus':
        return AppColors.secondary;

      case 'Train':
        return AppColors.energy;

      case 'Car':
        return const Color(0xFFE65100);

      case 'Bike':
        return AppColors.waste;

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
              'Transport',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            Text(
              'Track your travel impact',
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
        color: AppColors.secondary,
        onRefresh: _loadTransport,

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
                    imageAsset: 'assets/images/transport.jpg',
                    label: 'Choose low-impact ways to get around',
                  ),

                  const SizedBox(height: 18),

                  // ==================================================
                  // HERO
                  // ==================================================
                  _buildHero(),

                  const SizedBox(height: 28),

                  // ==================================================
                  // ADD JOURNEY
                  // ==================================================
                  const Text(
                    'Add a Journey',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 5),

                  const Text(
                    'Record how you travelled today.',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 14),

                  _buildJourneyForm(),

                  const SizedBox(height: 30),

                  // ==================================================
                  // RECENT JOURNEYS
                  // ==================================================
                  _buildRecentJourneys(),
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
          colors: [AppColors.secondary, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),

        borderRadius: BorderRadius.circular(22),

        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withValues(alpha: 0.16),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),

      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),

                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(20),
                  ),

                  child: const Text(
                    'SMARTER TRAVEL',
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
                  'Track your journey.',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 7),

                const Text(
                  'Record your travel and understand its estimated environmental impact.',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: Colors.white70,
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
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(20),
            ),

            child: const Icon(
              Icons.route_rounded,
              size: 40,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // JOURNEY FORM
  // ==========================================================

  Widget _buildJourneyForm() {
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
          // ==================================================
          // TRANSPORT MODE
          // ==================================================

          const Text(
            'Transport Mode',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 8),

          _buildModeSelector(),

          const SizedBox(height: 20),

          // ==================================================
          // DISTANCE
          // ==================================================
          const Text(
            'Distance Travelled',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 8),

          TextField(
            controller: _distanceController,

            keyboardType: const TextInputType.numberWithOptions(decimal: true),

            onChanged: (_) => _calculate(),

            decoration: InputDecoration(
              hintText: 'Enter distance',

              suffixText: 'km',

              prefixIcon: const Icon(
                Icons.route_rounded,
                color: AppColors.secondary,
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
                borderSide: const BorderSide(
                  color: AppColors.secondary,
                  width: 2,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ==================================================
          // EMISSION PREVIEW
          // ==================================================
          _buildEmissionCard(),

          const SizedBox(height: 10),

          const Text(
            'CO₂ values are illustrative estimates based on the selected transport mode.',
            style: TextStyle(
              fontSize: 11.5,
              height: 1.45,
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 20),

          // ==================================================
          // SAVE
          // ==================================================
          SizedBox(
            width: double.infinity,
            height: 52,

            child: ElevatedButton.icon(
              onPressed: _saveJourney,

              icon: const Icon(Icons.add_rounded),

              label: const Text(
                'Save Journey',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // MODE SELECTOR
  // ==========================================================

  Widget _buildModeSelector() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedMode,

      decoration: InputDecoration(
        hintText: 'Select transport mode',

        prefixIcon: Icon(
          _getTransportIcon(_selectedMode),
          color: _getTransportColor(_selectedMode),
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
          borderSide: const BorderSide(color: AppColors.secondary, width: 2),
        ),
      ),

      items: _emissionFactors.keys.map((mode) {
        final color = _getTransportColor(mode);

        return DropdownMenuItem<String>(
          value: mode,

          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,

                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                ),

                child: Icon(_getTransportIcon(mode), color: color, size: 20),
              ),

              const SizedBox(width: 11),

              Text(
                mode,
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
          _selectedMode = value;
        });

        _calculate();
      },
    );
  }

  // ==========================================================
  // CO2 CARD
  // ==========================================================

  Widget _buildEmissionCard() {
    final color = _getTransportColor(_selectedMode);

    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(17),

      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),

        borderRadius: BorderRadius.circular(18),

        border: Border.all(color: color.withValues(alpha: 0.20)),
      ),

      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,

            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(15),
            ),

            child: Icon(Icons.cloud_outlined, color: color, size: 27),
          ),

          const SizedBox(width: 14),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  'Estimated CO₂ Impact',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),

                SizedBox(height: 4),

                Text(
                  'Based on your selected journey',
                  style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
              ],
            ),
          ),

          Text(
            '${_estimatedEmission.toStringAsFixed(2)} kg',

            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // RECENT JOURNEYS
  // ==========================================================

  Widget _buildRecentJourneys() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,

          children: [
            const Text(
              'Recent Journeys',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),

            if (_transportList.isNotEmpty)
              Text(
                '${_transportList.length} recorded',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
          ],
        ),

        const SizedBox(height: 14),

        if (_transportList.isEmpty)
          _buildEmptyState()
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),

            itemCount: _transportList.length,

            itemBuilder: (context, index) {
              final transport = _transportList[index];

              return _buildJourneyTile(transport);
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
              color: AppColors.secondary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),

            child: const Icon(
              Icons.route_outlined,
              color: AppColors.secondary,
              size: 30,
            ),
          ),

          const SizedBox(height: 14),

          const Text(
            'No journeys recorded yet',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 5),

          const Text(
            'Add your first journey above to start tracking your transport impact.',
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
  // JOURNEY TILE
  // ==========================================================

  Widget _buildJourneyTile(Transport transport) {
    final color = _getTransportColor(transport.mode);

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
              _getTransportIcon(transport.mode),
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
                  transport.mode,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  '${transport.distance.toStringAsFixed(1)} km',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  transport.date,
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
                '${transport.co2Emission.toStringAsFixed(2)} kg',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),

              const SizedBox(height: 6),

              InkWell(
                onTap: () {
                  if (transport.id != null) {
                    _deleteTransport(transport.id!);
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
