import 'package:flutter/material.dart';
import '../../../services/product_service.dart';

class StationDropdown extends StatelessWidget {
  final List<Station> stations;
  final String? value;
  final String label;
  final IconData? icon;
  final ValueChanged<String?> onChanged;

  const StationDropdown({
    super.key,
    required this.stations,
    required this.value,
    required this.onChanged,
    this.label = 'Trạm',
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon) : null,
      ),
      items: stations
          .map((s) => DropdownMenuItem<String>(
                value: s.name,
                child: Text(
                  s.code.isEmpty ? s.name : '${s.name}  (${s.code})',
                  overflow: TextOverflow.ellipsis,
                ),
              ))
          .toList(),
      onChanged: onChanged,
      validator: (v) =>
          (v == null || v.isEmpty) ? 'Chọn trạm' : null,
    );
  }
}
