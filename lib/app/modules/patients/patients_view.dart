import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/app_routes.dart';
import '../shared_widgets/loading_shimmer.dart';
import '../shared_widgets/patient_tile.dart';
import 'patients_controller.dart';

class PatientsView extends GetView<PatientsController> {
  const PatientsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final searchController = TextEditingController();

    // Reset search on build to sync
    searchController.text = controller.searchQuery.value;

    return Scaffold(
      appBar: AppBar(title: const Text('Clinic Patients')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(Routes.ADD_PATIENT),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, size: 28),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            // Search Bar
            TextField(
              controller: searchController,
              onChanged: controller.updateSearchQuery,
              decoration: InputDecoration(
                hintText: 'Search patients by name or condition...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    searchController.clear();
                    controller.updateSearchQuery('');
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Filter Chips
            Obx(() {
              final selected = controller.selectedFilter.value;
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildFilterChip('All', selected, theme),
                  _buildFilterChip('Stable', selected, theme),
                  _buildFilterChip('Critical', selected, theme),
                ],
              );
            }),
            const SizedBox(height: 16),

            // Patient List Section
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value && controller.patients.isEmpty) {
                  return ListView.builder(
                    itemCount: 6,
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: LoadingShimmer(
                        width: double.infinity,
                        height: 72,
                        borderRadius: 16,
                      ),
                    ),
                  );
                }

                final list = controller.filteredPatients;
                if (list.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person_search_rounded,
                          size: 64,
                          color: theme.brightness == Brightness.light
                              ? Colors.grey.shade400
                              : Colors.grey.shade700,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No Patients Found',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Try modifying your search or filters.',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => controller.fetchPatients(size: 'small'),
                  child: ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final patient = list[index];
                      return PatientTile(
                        patient: patient,
                        onTap: () {
                          // Navigate to details and pass patient as argument
                          Get.toNamed(
                            Routes.PATIENT_DETAILS,
                            arguments: patient,
                          );
                        },
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String selected, ThemeData theme) {
    final bool isSelected = label == selected;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (bool val) {
        if (val) {
          controller.updateFilter(label);
        }
      },
      selectedColor: theme.primaryColor.withOpacity(0.15),
      labelStyle: TextStyle(
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        color: isSelected
            ? theme.primaryColor
            : (theme.brightness == Brightness.light
                  ? Colors.black87
                  : Colors.white70),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? theme.primaryColor : Colors.grey.shade300,
          width: 0.8,
        ),
      ),
    );
  }
}
