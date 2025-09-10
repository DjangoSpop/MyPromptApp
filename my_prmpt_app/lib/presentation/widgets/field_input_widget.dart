// lib/presentation/widgets/field_input_widget.dart

import 'package:flutter/material.dart';
import '../../data/models/prompt_field.dart';

class FieldInputWidget extends StatelessWidget {
  final PromptField field;
  final Function(String) onChanged;
  final String? value;

  const FieldInputWidget({
    super.key,
    required this.field,
    required this.onChanged,
    this.value,
  });

  @override
  Widget build(BuildContext context) {
    switch (field.type) {
      case FieldType.text:
        return _buildTextInput();
      case FieldType.number:
        return _buildNumberInput();
      case FieldType.dropdown:
        return _buildDropdownInput();
      case FieldType.multiline:
        return _buildMultilineInput();
      default:
        return _buildTextInput();
    }
  }

  Widget _buildTextInput() {
    return TextFormField(
      initialValue: value,
      decoration: InputDecoration(
        labelText: field.name,
        hintText: field.placeholder,
        border: const OutlineInputBorder(),
      ),
      validator: field.required
          ? (value) => value?.isEmpty == true ? 'This field is required' : null
          : null,
      onChanged: onChanged,
    );
  }

  Widget _buildNumberInput() {
    return TextFormField(
      initialValue: value,
      decoration: InputDecoration(
        labelText: field.name,
        hintText: field.placeholder,
        border: const OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      validator: field.required
          ? (value) => value?.isEmpty == true ? 'This field is required' : null
          : null,
      onChanged: onChanged,
    );
  }

  Widget _buildDropdownInput() {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: field.name,
        border: const OutlineInputBorder(),
      ),
      items: field.options?.map((option) {
        return DropdownMenuItem<String>(
          value: option,
          child: Text(option),
        );
      }).toList() ?? [],
      validator: field.required
          ? (value) => value?.isEmpty == true ? 'This field is required' : null
          : null,
      onChanged: (newValue) => onChanged(newValue ?? ''),
    );
  }

  Widget _buildMultilineInput() {
    return TextFormField(
      initialValue: value,
      decoration: InputDecoration(
        labelText: field.name,
        hintText: field.placeholder,
        border: const OutlineInputBorder(),
      ),
      maxLines: 3,
      validator: field.required
          ? (value) => value?.isEmpty == true ? 'This field is required' : null
          : null,
      onChanged: onChanged,
    );
  }
}