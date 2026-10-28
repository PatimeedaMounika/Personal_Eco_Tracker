import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../models/transport.dart';
import '../models/energy.dart';
import '../models/waste.dart';
import '../services/database_service.dart';
import '../theme/app_colors.dart';
import '../widgets/eco_image_banner.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final DatabaseService _db = DatabaseService();

  bool _loading = true;

  List<Transport> _transport = [];
  List<Energy> _energy = [];
  List<Waste> _waste = [];

  // ----------------------------------------------------------
  // COLORS
  // ----------------------------------------------------------

  static const Color transportColor = Color(0xFF1976D2);
  static const Color energyColor = Color(0xFFF57C00);
  static const Color wasteColor = Color(0xFF7B1FA2);
  static const Color recycledColor = Color(0xFF388E3C);
  static const Color notRecycledColor = Color(0xFFEF6C00);

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  // ----------------------------------------------------------
  // LOAD REPORTS
  // ----------------------------------------------------------

  Future<void> _loadReports() async {
    if (mounted) {
      setState(() {
        _loading = true;
      });
    }

    try {
      final results = await Future.wait([
        _db.getTransport(),
        _db.getEnergy(),
        _db.getWaste(),
      ]);

      final transport = results[0] as List<Transport>;
      final energy = results[1] as List<Energy>;
      final waste = results[2] as List<Waste>;

      if (!mounted) return;

      setState(() {
        _transport = transport;
        _energy = energy;
        _waste = waste;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not load reports: $e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  // ----------------------------------------------------------
  // CALCULATIONS
  // ----------------------------------------------------------

  double get _totalTransportEmission {
    return _transport.fold(0.0, (sum, item) => sum + item.co2Emission);
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

  double get _nonRecycledWaste {
    final value = _totalWaste - _recycledWaste;
    return value < 0 ? 0 : value;
  }

  double get _recyclingRate {
    if (_totalWaste == 0) return 0;

    return (_recycledWaste / _totalWaste) * 100;
  }

  // ----------------------------------------------------------
  // CHART DATA
  // ----------------------------------------------------------

  Map<String, double> _transportByMode() {
    final Map<String, double> data = {};

    for (final item in _transport) {
      data[item.mode] = (data[item.mode] ?? 0) + item.co2Emission;
    }

    return data;
  }

  Map<String, double> _energyByAppliance() {
    final Map<String, double> data = {};

    for (final item in _energy) {
      data[item.appliance] = (data[item.appliance] ?? 0) + item.estimatedUnits;
    }

    return data;
  }

  // ----------------------------------------------------------
  // BUILD
  // ----------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,

        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Eco Reports',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 2),
            Text(
              'Your environmental insights',
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
            onPressed: _loading ? null : _loadReports,
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 6),
        ],
      ),

      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 18, 20, 0),
            child: EcoImageBanner(
              imageAsset: 'assets/images/reports.jpg',
              label: 'See the impact of your everyday choices',
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: _loadReports,

                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),

                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 35),

                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1100),

                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              _buildHeader(),

                              const SizedBox(height: 22),

                              _buildSectionTitle(
                                'Your Summary',
                                'A quick look at your recorded environmental data.',
                                Icons.analytics_outlined,
                                AppColors.primary,
                              ),

                              const SizedBox(height: 13),

                              _summaryGrid(),

                              const SizedBox(height: 30),

                              _buildSectionTitle(
                                'Transport Impact',
                                'CO₂ emissions by transportation mode.',
                                Icons.directions_car_outlined,
                                transportColor,
                              ),

                              const SizedBox(height: 13),

                              _transportChart(),

                              const SizedBox(height: 30),

                              _buildSectionTitle(
                                'Energy Usage',
                                'Estimated electricity usage by appliance.',
                                Icons.bolt_outlined,
                                energyColor,
                              ),

                              const SizedBox(height: 13),

                              _energyChart(),

                              const SizedBox(height: 30),

                              _buildSectionTitle(
                                'Waste Recycling',
                                'Comparison between recycled and non-recycled waste.',
                                Icons.recycling_outlined,
                                wasteColor,
                              ),

                              const SizedBox(height: 13),

                              _wasteChart(),

                              const SizedBox(height: 30),

                              _buildSectionTitle(
                                'Eco Insights',
                                'A simple interpretation of your current data.',
                                Icons.lightbulb_outline_rounded,
                                AppColors.secondary,
                              ),

                              const SizedBox(height: 13),

                              _insightsCard(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  // HEADER
  // ----------------------------------------------------------

  Widget _buildHeader() {
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
            color: AppColors.primary.withValues(alpha: 0.16),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),

      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 500;

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                _headerIcon(),

                const SizedBox(height: 16),

                _headerText(),
              ],
            );
          }

          return Row(
            children: [
              _headerIcon(),

              const SizedBox(width: 17),

              Expanded(child: _headerText()),
            ],
          );
        },
      ),
    );
  }

  Widget _headerIcon() {
    return Container(
      width: 60,
      height: 60,

      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(17),
      ),

      child: const Icon(Icons.insights_rounded, color: Colors.white, size: 31),
    );
  }

  Widget _headerText() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Text(
          'Your Environmental Summary',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),

        SizedBox(height: 7),

        Text(
          'Understand your daily activities and see how your choices affect the environment.',
          style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.45),
        ),
      ],
    );
  }

  // ----------------------------------------------------------
  // SECTION TITLE
  // ----------------------------------------------------------

  Widget _buildSectionTitle(
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 11.5,
                  color: AppColors.textSecondary,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ----------------------------------------------------------
  // SUMMARY GRID
  // ----------------------------------------------------------

  Widget _summaryGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 850
            ? 4
            : constraints.maxWidth >= 550
            ? 2
            : 1;

        const spacing = 12.0;

        final width = columns == 1
            ? constraints.maxWidth
            : (constraints.maxWidth - ((columns - 1) * spacing)) / columns;

        final cards = [
          _summaryCard(
            width: width,
            title: 'Transport',
            value: '${_totalTransportEmission.toStringAsFixed(2)} kg',
            subtitle: 'CO₂ emission',
            icon: Icons.directions_car_outlined,
            color: transportColor,
          ),

          _summaryCard(
            width: width,
            title: 'Energy',
            value: '${_totalEnergy.toStringAsFixed(2)} kWh',
            subtitle: 'Estimated usage',
            icon: Icons.bolt_outlined,
            color: energyColor,
          ),

          _summaryCard(
            width: width,
            title: 'Waste',
            value: '${_totalWaste.toStringAsFixed(2)} kg',
            subtitle: 'Total recorded',
            icon: Icons.delete_outline_rounded,
            color: wasteColor,
          ),

          _summaryCard(
            width: width,
            title: 'Recycled',
            value: '${_recycledWaste.toStringAsFixed(2)} kg',
            subtitle: 'Recycled waste',
            icon: Icons.recycling_outlined,
            color: recycledColor,
          ),
        ];

        return Wrap(spacing: spacing, runSpacing: spacing, children: cards);
      },
    );
  }

  Widget _summaryCard({
    required double width,
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return SizedBox(
      width: width,

      child: Container(
        padding: const EdgeInsets.all(17),

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

        child: Row(
          children: [
            Container(
              width: 47,
              height: 47,

              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(14),
              ),

              child: Icon(icon, color: color, size: 24),
            ),

            const SizedBox(width: 13),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    value,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: color,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 2),

                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 10,
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

  // ----------------------------------------------------------
  // TRANSPORT CHART
  // ----------------------------------------------------------

  Widget _transportChart() {
    final data = _transportByMode();

    if (data.isEmpty) {
      return _emptyCard(
        'No transport records yet.',
        'Add a journey to see your transport impact.',
        Icons.directions_car_outlined,
        transportColor,
      );
    }

    final entries = data.entries.toList();

    return _chartCard(
      height: 345,
      accent: transportColor,

      child: BarChart(
        BarChartData(
          maxY: _maxChartValue(data.values.toList()),

          barGroups: List.generate(entries.length, (index) {
            return BarChartGroupData(
              x: index,

              barRods: [
                BarChartRodData(
                  toY: entries[index].value,
                  width: 25,
                  borderRadius: BorderRadius.circular(7),
                  color: transportColor,
                ),
              ],
            );
          }),

          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 42,

                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 9,
                      color: AppColors.textSecondary,
                    ),
                  );
                },
              ),
            ),

            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 48,

                getTitlesWidget: (value, meta) {
                  final index = value.toInt();

                  if (index < 0 || index >= entries.length) {
                    return const SizedBox();
                  }

                  return Padding(
                    padding: const EdgeInsets.only(top: 8),

                    child: SizedBox(
                      width: 58,

                      child: Text(
                        entries[index].key,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 9,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),

            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),

          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,

            getDrawingHorizontalLine: (value) {
              return const FlLine(color: AppColors.border, strokeWidth: 1);
            },
          ),

          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // ENERGY CHART
  // ----------------------------------------------------------

  Widget _energyChart() {
    final data = _energyByAppliance();

    if (data.isEmpty) {
      return _emptyCard(
        'No energy records yet.',
        'Add appliance usage to see your energy report.',
        Icons.bolt_outlined,
        energyColor,
      );
    }

    final entries = data.entries.toList();

    return _chartCard(
      height: 345,
      accent: energyColor,

      child: BarChart(
        BarChartData(
          maxY: _maxChartValue(data.values.toList()),

          barGroups: List.generate(entries.length, (index) {
            return BarChartGroupData(
              x: index,

              barRods: [
                BarChartRodData(
                  toY: entries[index].value,
                  width: 23,
                  borderRadius: BorderRadius.circular(7),
                  color: energyColor,
                ),
              ],
            );
          }),

          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 42,

                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 9,
                      color: AppColors.textSecondary,
                    ),
                  );
                },
              ),
            ),

            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 58,

                getTitlesWidget: (value, meta) {
                  final index = value.toInt();

                  if (index < 0 || index >= entries.length) {
                    return const SizedBox();
                  }

                  return Padding(
                    padding: const EdgeInsets.only(top: 8),

                    child: SizedBox(
                      width: 62,

                      child: Text(
                        entries[index].key,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 8.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),

            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),

          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,

            getDrawingHorizontalLine: (value) {
              return const FlLine(color: AppColors.border, strokeWidth: 1);
            },
          ),

          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // WASTE CHART
  // ----------------------------------------------------------

  Widget _wasteChart() {
    if (_totalWaste == 0) {
      return _emptyCard(
        'No waste records yet.',
        'Add waste data to see your recycling progress.',
        Icons.recycling_outlined,
        wasteColor,
      );
    }

    return _chartCard(
      height: 350,
      accent: wasteColor,

      child: Column(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                sectionsSpace: 4,
                centerSpaceRadius: 55,

                sections: [
                  PieChartSectionData(
                    value: _recycledWaste,
                    title: '${_recycledWaste.toStringAsFixed(1)} kg',
                    radius: 82,
                    color: recycledColor,

                    titleStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  PieChartSectionData(
                    value: _nonRecycledWaste,
                    title: '${_nonRecycledWaste.toStringAsFixed(1)} kg',
                    radius: 82,
                    color: notRecycledColor,

                    titleStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [
              _buildLegendItem(color: recycledColor, label: 'Recycled'),

              const SizedBox(width: 24),

              _buildLegendItem(color: notRecycledColor, label: 'Not Recycled'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({required Color color, required String label}) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,

          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),

        const SizedBox(width: 6),

        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ----------------------------------------------------------
  // CHART CARD
  // ----------------------------------------------------------

  Widget _chartCard({
    required double height,
    required Color accent,
    required Widget child,
  }) {
    return Container(
      height: height,

      padding: const EdgeInsets.fromLTRB(12, 18, 12, 14),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),

        border: Border.all(color: AppColors.border),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),

      child: Column(
        children: [
          Align(
            alignment: Alignment.centerRight,

            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),

              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
              ),

              child: Text(
                'Recorded data',
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w600,
                  color: accent,
                ),
              ),
            ),
          ),

          const SizedBox(height: 4),

          Expanded(child: child),
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  // ECO INSIGHTS
  // ----------------------------------------------------------

  Widget _insightsCard() {
    final rate = _recyclingRate;

    String message;
    String title;
    IconData icon;
    Color accent;

    if (_totalWaste == 0) {
      title = 'Start tracking';
      message = 'Record your waste to start seeing your recycling insights.';
      icon = Icons.add_chart_rounded;
      accent = AppColors.secondary;
    } else if (rate >= 75) {
      title = 'Strong recycling progress';
      message = 'A large portion of your recorded waste is marked as recycled.';
      icon = Icons.emoji_events_rounded;
      accent = recycledColor;
    } else if (rate >= 50) {
      title = 'Good recycling progress';
      message = 'More than half of your recorded waste is marked as recycled.';
      icon = Icons.trending_up_rounded;
      accent = AppColors.green400;
    } else {
      title = 'Room to improve';
      message =
          'A smaller portion of your recorded waste is marked as recycled. Try separating recyclable materials.';
      icon = Icons.lightbulb_outline_rounded;
      accent = wasteColor;
    }

    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(21),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),

        border: Border.all(color: AppColors.border),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 14,
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
                width: 50,
                height: 50,

                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14),
                ),

                child: Icon(icon, color: accent, size: 26),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: 3),

                    const Text(
                      'Your current recycling progress',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 21),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [
              const Text(
                'Recycling Rate',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),

              Text(
                '${rate.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: accent,
                ),
              ),
            ],
          ),

          const SizedBox(height: 9),

          ClipRRect(
            borderRadius: BorderRadius.circular(10),

            child: LinearProgressIndicator(
              value: rate / 100,
              minHeight: 10,
              color: accent,
              backgroundColor: accent.withValues(alpha: 0.10),
            ),
          ),

          const SizedBox(height: 17),

          Container(
            width: double.infinity,

            padding: const EdgeInsets.all(14),

            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(13),
            ),

            child: Text(
              message,
              style: const TextStyle(
                fontSize: 13,
                height: 1.45,
                color: AppColors.textSecondary,
              ),
            ),
          ),

          const SizedBox(height: 15),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Icon(
                Icons.tips_and_updates_outlined,
                color: AppColors.secondary,
                size: 20,
              ),

              const SizedBox(width: 8),

              const Expanded(
                child: Text(
                  'Tip: Reuse items whenever possible and separate recyclable materials before disposal.',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  // EMPTY STATE
  // ----------------------------------------------------------

  Widget _emptyCard(String title, String subtitle, IconData icon, Color color) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 32),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),

        border: Border.all(color: AppColors.border),
      ),

      child: Column(
        children: [
          Container(
            width: 68,
            height: 68,

            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),

            child: Icon(icon, size: 32, color: color),
          ),

          const SizedBox(height: 15),

          Text(
            title,
            textAlign: TextAlign.center,

            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            subtitle,
            textAlign: TextAlign.center,

            style: const TextStyle(
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
  // CHART MAX VALUE
  // ----------------------------------------------------------

  double _maxChartValue(List<double> values) {
    if (values.isEmpty) return 10;

    final maxValue = values.reduce((a, b) => a > b ? a : b);

    if (maxValue <= 0) return 10;

    return maxValue * 1.3;
  }
}
