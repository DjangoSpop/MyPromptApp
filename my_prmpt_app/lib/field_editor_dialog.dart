// lib/presentation/widgets/field_editor_dialog.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/prompt_field.dart';

/// Dialog for editing field properties
class FieldEditorDialog extends StatefulWidget {
  final PromptField field;
  final bool isNew;
  final List<String> existingIds;

  const FieldEditorDialog({
    super.key,
    required this.field,
    required this.isNew,
    required this.existingIds,
  });

  @override
  State<FieldEditorDialog> createState() => _FieldEditorDialogState();
}

class _FieldEditorDialogState extends State<FieldEditorDialog> {
  late PromptField editedField;
  final formKey = GlobalKey<FormState>();
  
  // Text controllers
  late TextEditingController idController;
  late TextEditingController labelController;
  late TextEditingController placeholderController;
  late TextEditingController helpTextController;
  late TextEditingController validationPatternController;
  late TextEditingController defaultValueController;
  
  // For options management
  late List<String> options;
  final optionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    
    // Create a copy of the field for editing
    editedField = PromptField(
      id: widget.field.id,
      label: widget.field.label,
      placeholder: widget.field.placeholder,
      type: widget.field.type,
      isRequired: widget.field.isRequired,
      options: widget.field.options != null ? List.from(widget.field.options!) : null,
      defaultValue: widget.field.defaultValue,
      validationPattern: widget.field.validationPattern,
      helpText: widget.field.helpText,
    );
    
    // Initialize controllers
    idController = TextEditingController(text: editedField.id);
    labelController = TextEditingController(text: editedField.label);
    placeholderController = TextEditingController(text: editedField.placeholder);
    helpTextController = TextEditingController(text: editedField.helpText ?? '');
    validationPatternController = TextEditingController(text: editedField.validationPattern ?? '');
    defaultValueController = TextEditingController(text: editedField.defaultValue ?? '');
    
    // Initialize options
    options = editedField.options != null ? List.from(editedField.options!) : [];
  }

  @override
  void dispose() {
    idController.dispose();
    labelController.dispose();
    placeholderController.dispose();
    helpTextController.dispose();
    validationPatternController.dispose();
    defaultValueController.dispose();
    optionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.maxFinite,
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBasicFields(),
                      const SizedBox(height: 16),
                      _buildTypeSection(),
                      const SizedBox(height: 16),
                      _buildOptionsSection(),
                      const SizedBox(height: 16),
                      _buildAdvancedSettings(),
                    ],
                  ),
                ),
              ),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  /// Builds the dialog header
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Icon(
            widget.isNew ? Icons.add_circle : Icons.edit,
            color: Colors.white,
          ),
          const SizedBox(width: 12),
          Text(
            widget.isNew ? 'Add New Field' : 'Edit Field',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds basic field properties
  Widget _buildBasicFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Basic Information',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        // Field ID
        TextFormField(
          controller: idController,
          decoration: const InputDecoration(
            labelText: 'Field ID *',
            helperText: 'Used in template placeholders: {{field_id}}',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Field ID is required';
            }
            
            // Check ID format (alphanumeric, underscore only)
            if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
              return 'ID must contain only letters, numbers, and underscores';
            }
            
            // Check for duplicate IDs (except the current field)
            if (widget.existingIds.contains(value) && value != widget.field.id) {
              return 'This ID is already in use';
            }
            
            return null;
          },
          onChanged: (value) {
            setState(() {
              editedField.id = value;
            });
          },
        ),
        const SizedBox(height: 16),
        
        // Field Label
        TextFormField(
          controller: labelController,
          decoration: const InputDecoration(
            labelText: 'Field Label *',
            helperText: 'Text shown to users in the form',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Field label is required';
            }
            return null;
          },
          onChanged: (value) {
            setState(() {
              editedField.label = value;
            });
          },
        ),
        const SizedBox(height: 16),
        
        // Field Placeholder
        TextFormField(
          controller: placeholderController,
          decoration: const InputDecoration(
            labelText: 'Placeholder Text',
            helperText: 'Hint text shown inside the empty field',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            setState(() {
              editedField.placeholder = value;
            });
          },
        ),
        const SizedBox(height: 16),
        
        // Required checkbox
        Row(
          children: [
            Checkbox(
              value: editedField.isRequired,
              onChanged: (value) {
                setState(() {
                  editedField.isRequired = value ?? false;
                });
              },
            ),
            const Text('Required Field'),
            const Tooltip(
              message: 'User must provide a value for this field',
              child: Icon(Icons.info_outline, size: 16),
            ),
          ],
        ),
      ],
    );
  }

  /// Builds field type selection
  Widget _buildTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Field Type',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: FieldType.values.map((type) {
            return ChoiceChip(
              label: Text(_getFieldTypeName(type)),
              selected: editedField.type == type,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    editedField.type = type;
                    
                    // Reset options if changing to/from option-based types
                    if (!_hasOptions(type) && editedField.options != null) {
                      editedField.options = null;
                      options = [];
                    } else if (_hasOptions(type) && editedField.options == null) {
                      editedField.options = [];
                      options = [];
                    }
                  });
                }
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        Text(
          _getFieldTypeDescription(editedField.type),
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  /// Builds options section for select fields
  Widget _buildOptionsSection() {
    if (!_hasOptions(editedField.type)) {
      return const SizedBox.shrink();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Options',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _getOptionsDescription(editedField.type),
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 16),
        
        // Add option row
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: optionController,
                decoration: const InputDecoration(
                  labelText: 'Add Option',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: _addOption,
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                if (optionController.text.trim().isNotEmpty) {
                  _addOption(optionController.text);
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Options list
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: options.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(
                      'No options added yet',
                      style: TextStyle(
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                )
              : ReorderableListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: options.length,
                  onReorder: (oldIndex, newIndex) {
                    setState(() {
                      if (oldIndex < newIndex) {
                        newIndex -= 1;
                      }
                      final item = options.removeAt(oldIndex);
                      options.insert(newIndex, item);
                      editedField.options = List.from(options);
                    });
                  },
                  itemBuilder: (context, index) {
                    return ListTile(
                      key: ValueKey('option_$index'),
                      leading: const Icon(Icons.drag_indicator),
                      title: Text(options[index]),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            options.removeAt(index);
                            editedField.options = List.from(options);
                            
                            // Clear default value if it's removed
                            if (editedField.defaultValue == options[index]) {
                              editedField.defaultValue = null;
                              defaultValueController.text = '';
                            }
                          });
                        },
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  /// Builds advanced settings section
  Widget _buildAdvancedSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Advanced Settings',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        // Help Text
        TextFormField(
          controller: helpTextController,
          decoration: const InputDecoration(
            labelText: 'Help Text',
            helperText: 'Additional instructions for the user',
            border: OutlineInputBorder(),
          ),
          maxLines: 2,
          onChanged: (value) {
            setState(() {
              editedField.helpText = value.isEmpty ? null : value;
            });
          },
        ),
        const SizedBox(height: 16),
        
        // Default Value
        if (editedField.type != FieldType.checkbox) ...[
          TextFormField(
            controller: defaultValueController,
            decoration: InputDecoration(
              labelText: 'Default Value',
              helperText: _hasOptions(editedField.type) 
                  ? 'Must match one of the options above'
                  : 'Pre-filled value for this field',
              border: const OutlineInputBorder(),
            ),
            validator: (value) {
              if (value != null && value.isNotEmpty && _hasOptions(editedField.type)) {
                if (!options.contains(value)) {
                  return 'Default value must match one of the options';
                }
              }
              return null;
            },
            onChanged: (value) {
              setState(() {
                editedField.defaultValue = value.isEmpty ? null : value;
              });
            },
          ),
          const SizedBox(height: 16),
        ],
        
        // Validation Pattern (for text fields)
        if (editedField.type == FieldType.text || editedField.type == FieldType.textarea) ...[
          TextFormField(
            controller: validationPatternController,
            decoration: const InputDecoration(
              labelText: 'Validation Pattern (RegEx)',
              helperText: 'Optional regular expression for validation',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                try {
                  RegExp(value);
                } catch (e) {
                  return 'Invalid regular expression';
                }
              }
              return null;
            },
            onChanged: (value) {
              setState(() {
                editedField.validationPattern = value.isEmpty ? null : value;
              });
            },
          ),
        ],
      ],
    );
  }

  /// Builds footer with action buttons
  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: _saveField,
            child: const Text('Save Field'),
          ),
        ],
      ),
    );
  }

  /// Adds an option to the list
  void _addOption(String value) {
    final option = value.trim();
    if (option.isNotEmpty) {
      setState(() {
        if (!options.contains(option)) {
          options.add(option);
          editedField.options = List.from(options);
          optionController.clear();
        } else {
          // Show snackbar for duplicate option
          Get.snackbar(
            'Duplicate Option',
            'This option already exists',
            backgroundColor: Colors.orange[100],
            colorText: Colors.orange[800],
            margin: const EdgeInsets.all(16),
          );
        }
      });
    }
  }

  /// Saves the field and closes the dialog
  void _saveField() {
    if (formKey.currentState!.validate()) {
      // Ensure options are set if required
      if (_hasOptions(editedField.type) && (options.isEmpty)) {
        Get.snackbar(
          'Missing Options',
          'Please add at least one option for this field type',
          backgroundColor: Colors.red[100],
          colorText: Colors.red[800],
          margin: const EdgeInsets.all(16),
        );
        return;
      }
      
      // Return the edited field
      Get.back(result: editedField);
    }
  }

  /// Gets readable name for field type
  String _getFieldTypeName(FieldType type) {
    switch (type) {
      case FieldType.text:
        return 'Text Field';
      case FieldType.textarea:
        return 'Multi-line Text';
      case FieldType.dropdown:
        return 'Dropdown';
      case FieldType.checkbox:
        return 'Checkboxes';
      case FieldType.radio:
        return 'Radio Buttons';
      case FieldType.number:
        return 'Number';
    }
  }

  /// Gets description for field type
  String _getFieldTypeDescription(FieldType type) {
    switch (type) {
      case FieldType.text:
        return 'Single-line text input for short answers';
      case FieldType.textarea:
        return 'Multi-line text area for longer responses';
      case FieldType.dropdown:
        return 'Dropdown select menu with single selection';
      case FieldType.checkbox:
        return 'Multiple checkboxes allowing multiple selections';
      case FieldType.radio:
        return 'Radio buttons for mutually exclusive options';
      case FieldType.number:
        return 'Numeric input field for numbers only';
    }
  }

  /// Gets description for options section
  String _getOptionsDescription(FieldType type) {
    switch (type) {
      case FieldType.dropdown:
        return 'Add options for the dropdown select menu';
      case FieldType.checkbox:
        return 'Add options for the checkbox group';
      case FieldType.radio:
        return 'Add options for the radio button group';
      default:
        return '';
    }
  }

  /// Checks if field type has options
  bool _hasOptions(FieldType type) {
    return type == FieldType.dropdown || 
           type == FieldType.checkbox || 
           type == FieldType.radio;
  }
}