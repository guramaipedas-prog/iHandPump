import 'package:flutter/material.dart';
import '../data/java_cities.dart';
import '../theme/app_theme.dart';

class SearchableCityDropdown extends StatefulWidget {
  final String label;
  final JavaCity? selectedCity;
  final ValueChanged<JavaCity> onSelected;

  const SearchableCityDropdown({
    super.key,
    required this.label,
    this.selectedCity,
    required this.onSelected,
  });

  @override
  State<SearchableCityDropdown> createState() => _SearchableCityDropdownState();
}

class _SearchableCityDropdownState extends State<SearchableCityDropdown> {
  void _openCityPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.card,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _CityPickerSheet(
        onSelected: (city) {
          Navigator.pop(context);
          widget.onSelected(city);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _openCityPicker,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: widget.label,
          suffixIcon: const Icon(Icons.arrow_drop_down),
        ),
        child: Text(
          widget.selectedCity?.name ?? 'Pilih kota...',
          style: TextStyle(
            color: widget.selectedCity != null ? Colors.white : AppTheme.muted,
          ),
        ),
      ),
    );
  }
}

class _CityPickerSheet extends StatefulWidget {
  final ValueChanged<JavaCity> onSelected;

  const _CityPickerSheet({required this.onSelected});

  @override
  State<_CityPickerSheet> createState() => _CityPickerSheetState();
}

class _CityPickerSheetState extends State<_CityPickerSheet> {
  final _searchCtrl = TextEditingController();
  List<JavaCity> _filtered = javaCities;

  void _filter(String query) {
    setState(() {
      _filtered = javaCities
          .where((c) => c.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.muted,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Title
          const Text(
            'Pilih Kota',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          // Search
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchCtrl,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Cari kota...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: _filter,
            ),
          ),
          const SizedBox(height: 8),
          // List
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _filtered.length,
              itemBuilder: (context, index) {
                final city = _filtered[index];
                return ListTile(
                  title: Text(city.name),
                  onTap: () => widget.onSelected(city),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
