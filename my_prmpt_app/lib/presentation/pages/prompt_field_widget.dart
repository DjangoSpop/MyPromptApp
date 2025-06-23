// lib/presentation/widgets/field_input_widget.dart
import 'package:flutter/material.dart';
import '../../data/models/prompt_field.dart';

/// Widget for rendering different types of form inputs based on field type
class FieldInputWidget extends StatelessWidget {
  final PromptField field;
  final dynamic value;
  final Function(dynamic) onChanged;
  final String? errorText;

  const FieldInputWidget({
    super.key,
    required this.field,
    required this.onChanged,
    this.value,
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

  /// Builds a text field input
  Widget _buildTextField() {
    return TextFormField(
      initialValue: value?.toString() ?? field.defaultValue,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: field.label,
        hintText: field.placeholder,
        errorText: errorText,
        border: const OutlineInputBorder(),
        helperText: field.helpText,
        suffixIcon: field.isRequired
            ? const Icon(Icons.star, size: 10, color: Colors.red)
            : null,
      ),
    );
  }

  /// Builds a multi-line text area
  Widget _buildTextArea() {
    return TextFormField(
      initialValue: value?.toString() ?? field.defaultValue,
      onChanged: onChanged,
      maxLines: 5,
      decoration: InputDecoration(
        labelText: field.label,
        hintText: field.placeholder,
        errorText: errorText,
        border: const OutlineInputBorder(),
        alignLabelWithHint: true,
        helperText: field.helpText,
        suffixIcon: field.isRequired
            ? const Padding(
                padding: EdgeInsets.only(top: 12.0),
                child: Icon(Icons.star, size: 10, color: Colors.red),
              )
            : null,
      ),
    );
  }

  /// Builds a dropdown selector
  Widget _buildDropdown() {
    if (field.options == null || field.options!.isEmpty) {
      return const Text('No options available');
    }

    return DropdownButtonFormField<String>(
      value: value?.toString() ?? field.defaultValue,
      onChanged: (newValue) {
        if (newValue != null) {
          onChanged(newValue);
        }
      },
      decoration: InputDecoration(
        labelText: field.label,
        errorText: errorText,
        border: const OutlineInputBorder(),
        helperText: field.helpText,
        suffixIcon: field.isRequired
            ? const Icon(Icons.star, size: 10, color: Colors.red)
            : null,
      ),
      items: field.options!.map((option) {
        return DropdownMenuItem<String>(
          value: option,
          child: Text(option),
        );
      }).toList(),
    );
  }

  /// Builds a checkbox list for multiple selections
  Widget _buildCheckboxList() {
    final selectedOptions = (value as List<String>?) ??
        (field.defaultValue != null ? [field.defaultValue!] : []);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              field.label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (field.isRequired) ...[
              const SizedBox(width: 4),
              const Icon(Icons.star, size: 10, color: Colors.red),
            ],
          ],
        ),
        if (field.helpText != null) ...[
          const SizedBox(height: 4),
          Text(
            field.helpText!,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
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

        // Options
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: field.options?.length ?? 0,
            separatorBuilder: (context, index) =>
                Divider(height: 1, color: Colors.grey[300]),
            itemBuilder: (context, index) {
              final option = field.options![index];
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
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Builds a radio button list for single selection
  Widget _buildRadioList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              field.label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (field.isRequired) ...[
              const SizedBox(width: 4),
              const Icon(Icons.star, size: 10, color: Colors.red),
            ],
          ],
        ),
        if (field.helpText != null) ...[
          const SizedBox(height: 4),
          Text(
            field.helpText!,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
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

        // Options
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: field.options?.length ?? 0,
            separatorBuilder: (context, index) =>
                Divider(height: 1, color: Colors.grey[300]),
            itemBuilder: (context, index) {
              final option = field.options![index];
              return RadioListTile<String>(
                title: Text(option),
                value: option,
                groupValue: value?.toString() ?? field.defaultValue,
                onChanged: (newValue) {
                  if (newValue != null) {
                    onChanged(newValue);
                  }
                },
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Builds a number input field
  Widget _buildNumberField() {
    return TextFormField(
      initialValue: value?.toString() ?? field.defaultValue,
      onChanged: (val) {
        final numValue = int.tryParse(val);
        onChanged(numValue ?? val);
      },
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: field.label,
        hintText: field.placeholder,
        errorText: errorText,
        border: const OutlineInputBorder(),
        helperText: field.helpText,
        suffixIcon: field.isRequired
            ? const Icon(Icons.star, size: 10, color: Colors.red)
            : null,
      ),
    );
  }
}
