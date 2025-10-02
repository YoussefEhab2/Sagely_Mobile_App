
import 'package:flutter/material.dart';

class CustomDropdown<T> extends StatefulWidget {
  final List<DropdownMenuItem<T>> items;
  final T? value;
  final String placeholder;
  final ValueChanged<T?> onChanged;

  const CustomDropdown({
    super.key,
    required this.items,
    this.value,
    required this.placeholder,
    required this.onChanged,
  });

  @override
  State<CustomDropdown<T>> createState() => _CustomDropdownState<T>();
}

class _CustomDropdownState<T> extends State<CustomDropdown<T>> {
  bool isOpen = false;

  @override
  Widget build(BuildContext context) {
    final selectedLabel = widget.items
        .firstWhere(
          (item) => item.value == widget.value,
          orElse: () => DropdownMenuItem(value: null, child: Text(widget.placeholder)),
        )
        .child;

    return GestureDetector(
      onTap: () => setState(() => isOpen = !isOpen),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: DefaultTextStyle(
                style: TextStyle(
                  color: widget.value != null ? Colors.black : Colors.grey,
                  overflow: TextOverflow.ellipsis,
                ),
                child: selectedLabel,
              ),
            ),
            Icon(
              isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: Colors.grey.shade600,
            ),
          ],
        ),
      ),
    );
  }
}
