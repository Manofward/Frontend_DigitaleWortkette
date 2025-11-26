import 'package:flutter/material.dart';

class DropdownRow extends StatefulWidget {
  final String label;
  final String initialValue;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const DropdownRow({
    super.key,
    required this.label,
    required this.initialValue,
    required this.items,
    required this.onChanged,
  });

  @override
  State<DropdownRow> createState() => _DropdownRowState();
}

class _DropdownRowState extends State<DropdownRow> {
  late String selectedValue;

  @override
  void initState() {
    super.initState();
    selectedValue = widget.items.contains(widget.initialValue)
        ? widget.initialValue
        : (widget.items.isNotEmpty ? widget.items.first : '');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              widget.label,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          Expanded(
            flex: 3,
            child: DropdownButton<String>(
              isExpanded: true,
              value: selectedValue,
              items: widget.items
                  .map((item) => DropdownMenuItem(
                        value: item,
                        child: Text(item),
                      ))
                  .toList(),
              onChanged: (v) {
                if (v == null) return;
                setState(() => selectedValue = v); // rebuilds only this dropdown
                widget.onChanged(v); // notify parent
              },
            ),
          ),
        ],
      ),
    );
  }
}
