import 'package:flutter/material.dart';
import '../../app/routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../data/services/api_service.dart';
import '../../data/repositories/customer_repository.dart';
import '../../models/customer/charger.dart';

class CustomerSearchScreen extends StatefulWidget {
  const CustomerSearchScreen({super.key});

  @override
  State<CustomerSearchScreen> createState() => _CustomerSearchScreenState();
}

class _CustomerSearchScreenState extends State<CustomerSearchScreen> {
  late Future<List<Charger>> _chargersFuture;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadChargers();
  }

  void _loadChargers() {
    setState(() {
      _chargersFuture = CustomerRepositoryImpl(apiService: ApiService()).getChargers(
        filters: _searchQuery.isNotEmpty ? {'search': _searchQuery} : null,
      );
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text('Search Chargers'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenHorizontalPadding),
          child: Column(
            children: [
              // Search Location Bar & Filter Button
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search, color: AppColors.textMuted),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              onChanged: (val) {
                                setState(() {
                                  _searchQuery = val;
                                });
                                _loadChargers();
                              },
                              decoration: const InputDecoration(
                                hintText: 'Search Jamnagar Location / Station',
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                filled: false,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                          if (_searchQuery.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.clear, size: 18, color: AppColors.textMuted),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                                _loadChargers();
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.customerFilters);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.primaryDarkGreen,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.tune, color: AppColors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Search Results from Backend API
              Expanded(
                child: FutureBuilder<List<Charger>>(
                  future: _chargersFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: AppColors.primaryDarkGreen));
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Failed to load chargers from server.', style: TextStyle(color: AppColors.textMuted)),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: _loadChargers,
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryDarkGreen),
                              child: const Text('Retry', style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      );
                    }

                    final chargers = snapshot.data ?? [];
                    if (chargers.isEmpty) {
                      return const Center(
                        child: Text('No charging stations found matching your search.', style: TextStyle(color: AppColors.textMuted)),
                      );
                    }

                    return ListView.builder(
                      itemCount: chargers.length,
                      itemBuilder: (context, index) {
                        final charger = chargers[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border, width: 0.5),
                          ),
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              charger.name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary),
                            ),
                            subtitle: Text(
                              '${charger.locationAddress.isNotEmpty ? charger.locationAddress : "Jamnagar, Gujarat"} · ${charger.connectorType} · ₹${charger.pricePerKwh}/kWh · ${charger.isAvailable ? "Available" : "Busy"}',
                              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                            ),
                            trailing: Text(
                              '${charger.powerKw} kW',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryDarkGreen, fontSize: 13),
                            ),
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.customerDetails,
                                arguments: {'chargerName': charger.name, 'charger': charger},
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
