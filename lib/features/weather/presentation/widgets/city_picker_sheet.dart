import 'package:flutter/material.dart';
import 'package:study/features/weather/data/models/models.dart';

/// Bottom sheet for selecting a city for weather
class CityPickerSheet extends StatefulWidget {
  const CityPickerSheet({
    super.key,
    this.selectedCity,
    this.onCitySelected,
    this.onUseGPS,
  });

  final CityModel? selectedCity;
  final ValueChanged<CityModel>? onCitySelected;
  final VoidCallback? onUseGPS;

  static Future<void> show(
    BuildContext context, {
    CityModel? selectedCity,
    ValueChanged<CityModel>? onCitySelected,
    VoidCallback? onUseGPS,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CityPickerSheet(
        selectedCity: selectedCity,
        onCitySelected: onCitySelected,
        onUseGPS: onUseGPS,
      ),
    );
  }

  @override
  State<CityPickerSheet> createState() => _CityPickerSheetState();
}

class _CityPickerSheetState extends State<CityPickerSheet> {
  final _searchController = TextEditingController();
  List<CityModel> _filteredCities = CityModel.vietnamCities;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredCities = CityModel.vietnamCities;
      } else {
        _filteredCities = CityModel.vietnamCities
            .where((city) => city.name.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: cs.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.location_on, color: cs.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Chọn thành phố',
                    style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm thành phố...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: cs.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Use GPS button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: OutlinedButton.icon(
              onPressed: () {
                widget.onUseGPS?.call();
                Navigator.pop(context);
              },
              icon: const Icon(Icons.my_location),
              label: const Text('Sử dụng vị trí GPS'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
            ),
          ),

          Divider(color: cs.outlineVariant),

          // City list
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.only(bottom: bottomPadding + 16),
              itemCount: _filteredCities.length,
              itemBuilder: (context, index) {
                final city = _filteredCities[index];
                final isSelected = widget.selectedCity?.name == city.name;

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        isSelected ? cs.primaryContainer : cs.surfaceContainerHighest,
                    child: Icon(
                      Icons.location_city,
                      color: isSelected ? cs.primary : cs.onSurfaceVariant,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    city.name,
                    style: tt.bodyLarge?.copyWith(
                      fontWeight: isSelected ? FontWeight.w600 : null,
                      color: isSelected ? cs.primary : null,
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(Icons.check_circle, color: cs.primary)
                      : null,
                  onTap: () {
                    widget.onCitySelected?.call(city);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
