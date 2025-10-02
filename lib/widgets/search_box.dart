import 'package:flutter/material.dart';

class SearchBox extends StatelessWidget {
  final String hint;
  final Function(String) onSearch;

  const SearchBox({super.key, required this.hint, required this.onSearch});

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.search),
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onSubmitted: (val) => onSearch(val),
    );
  }
}
