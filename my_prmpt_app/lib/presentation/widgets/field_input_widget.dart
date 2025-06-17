
import 'package:flutter/material.dart';
import '../../data/models/prompt_field.dart';

/// Widget for rendering different types of form inputs
class FieldInputWidget extends StatelessWidget {
  final PromptField field;
  final dynamic value;
  final Function(dynamic) onChanged;
  final String? errorText;

  const FieldInputWidget({
    super.key,
    required this.field,
    required this.value,
    required this.onChanged,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    switch (field.type) {
      case FieldType.text:
        return _buildTextField();
      case FieldType.textarea:
        return _buildTextArea();
      case FieldType.dropdown:
        return _buildDropdown();
      case FieldType.checkbox:
        return _buildCheckboxList();
      case FieldType.radio:
        return _buildRadioList();
      case FieldType.number:
        return _buildNumberField();
    }
  }

  /// Builds a text field
  Widget _buildTextField() {
    return TextFormField(
      initialValue: value?.toString(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: field.label,
        hintText: field.placeholder,
        errorText: errorText,
        border: const OutlineInputBorder(),
      ),
    );
  }

  /// Builds a text area
  Widget _buildTextArea() {
    return TextFormField(
      initialValue: value?.toString(),
      onChanged: onChanged,
      maxLines: 5,
      decoration: InputDecoration(
        labelText: field.label,
        hintText: field.placeholder,
        errorText: errorText,
        border: const OutlineInputBorder(),
        alignLabelWithHint: true,
      ),
    );
  }

  /// Builds a dropdown
  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      value: value?.toString(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: field.label,
        errorText: errorText,
        border: const OutlineInputBorder(),
      ),
      items: field.options?.map((option) {
        return DropdownMenuItem<String>(
          value: option,
          child: Text(option),
        );
      }).toList(),
    );
  }

  /// Builds a checkbox list
  Widget _buildCheckboxList() {
    final selectedOptions = value as List<String>? ?? [];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          field.label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 4),
          Text(
            errorText!,
            style: const TextStyle(
              color: Colors.red,
              fontSize: 12,
            ),
          ),
        ],
        const SizedBox(height: 8),
        ...field.options?.map((option) {
          return CheckboxListTile(
            title: Text(option),
            value: selectedOptions.contains(option),
            onChanged: (isSelected) {
              final updatedList = List<String>.from(selectedOptions);
              if (isSelected == true) {
                updatedList.add(option);
              } else {
                updatedList.remove(option);
              }
              onChanged(updatedList);
            },
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          );
        }).toList() ?? [],
      ],
    );
  }

  /// Builds a radio list
  Widget _buildRadioList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          field.label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 4),
          Text(
            errorText!,
            style: const TextStyle(
              color: Colors.red,
              fontSize: 12,
            ),
          ),
        ],
        const SizedBox(height: 8),
        ...field.options?.map((option) {
          return RadioListTile<String>(
            title: Text(option),
            value: option,
            groupValue: value?.toString(),
            onChanged: onChanged,
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          );
        }).toList() ?? [],
      ],
    );
  }

  /// Builds a number field
  Widget _buildNumberField() {
    return TextFormField(
      initialValue: value?.toString(),
      onChanged: (val) => onChanged(int.tryParse(val) ?? val),
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: field.label,
        hintText: field.placeholder,
        errorText: errorText,
        border: const OutlineInputBorder(),
      ),
    );
  }
}