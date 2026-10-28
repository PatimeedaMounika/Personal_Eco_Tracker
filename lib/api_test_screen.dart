import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'widgets/eco_image_banner.dart';

class ApiTestScreen extends StatefulWidget {
  const ApiTestScreen({super.key});

  @override
  State<ApiTestScreen> createState() => _ApiTestScreenState();
}

class _ApiTestScreenState extends State<ApiTestScreen> {
  late Future<List<dynamic>> postsFuture;

  static const List<Map<String, String>> ecoTips = [
    {
      'title': 'Save Water',
      'description': 'Turn off the tap while brushing your teeth.',
      'icon': 'water',
    },
    {
      'title': 'Save Electricity',
      'description': 'Switch off lights and fans when not in use.',
      'icon': 'electricity',
    },
    {
      'title': 'Reduce Plastic',
      'description': 'Carry a reusable bag and water bottle.',
      'icon': 'plastic',
    },
    {
      'title': 'Manage Waste',
      'description': 'Separate wet waste from dry waste.',
      'icon': 'waste',
    },
    {
      'title': 'Eco-Friendly Travel',
      'description': 'Walk, cycle, or use public transport when possible.',
      'icon': 'travel',
    },
    {
      'title': 'Plant More Trees',
      'description': 'Grow plants and take care of green spaces.',
      'icon': 'tree',
    },
  ];

  @override
  void initState() {
    super.initState();
    postsFuture = ApiService.fetchPosts();
  }

  void refreshTips() {
    setState(() {
      postsFuture = ApiService.fetchPosts();
    });
  }

  IconData getIcon(String name) {
    switch (name) {
      case 'water':
        return Icons.water_drop_rounded;
      case 'electricity':
        return Icons.bolt_rounded;
      case 'plastic':
        return Icons.shopping_bag_rounded;
      case 'waste':
        return Icons.recycling_rounded;
      case 'travel':
        return Icons.directions_bike_rounded;
      default:
        return Icons.park_rounded;
    }
  }

  Widget buildTips() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Small Steps, Greener Planet!',
          style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Simple habits you can follow every day.',
          style: TextStyle(fontSize: 15, color: Colors.black54),
        ),
        const SizedBox(height: 12),
        const Text(
          'Sample API connection successful. '
          'These eco tips are examples shown by the app.',
          style: TextStyle(fontSize: 12, color: Color(0xFF00695C)),
        ),
        const SizedBox(height: 16),
        ...ecoTips.map((tip) {
          return Card(
            margin: const EdgeInsets.only(bottom: 14),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: CircleAvatar(
                radius: 25,
                backgroundColor: const Color(0xFFE0F2F1),
                child: Icon(
                  getIcon(tip['icon']!),
                  color: const Color(0xFF00695C),
                  size: 28,
                ),
              ),
              title: Text(
                tip['title']!,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  tip['description']!,
                  style: const TextStyle(fontSize: 15),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Eco Tips 🌱'),
        backgroundColor: const Color(0xFF00695C),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: refreshTips,
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: EcoImageBanner(
              imageAsset: 'assets/images/api_tips.jpg',
              label: 'Eco tips for a healthier planet',
            ),
          ),
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: postsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: Color(0xFF00695C)),
                        SizedBox(height: 16),
                        Text('Connecting to API...'),
                      ],
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.wifi_off_rounded,
                            size: 56,
                            color: Colors.redAccent,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Unable to connect to the API.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Check your internet connection and try again.',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: refreshTips,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Try Again'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  return buildTips();
                }

                return Center(
                  child: ElevatedButton(
                    onPressed: refreshTips,
                    child: const Text('Try Again'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
