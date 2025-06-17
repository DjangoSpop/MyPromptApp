// lib/core/utils/string_utils.dart
/// Utility functions for string manipulation
extension StringExtensions on String {
  /// Converts string to title case
  String toTitleCase() {
    if (isEmpty) return this;
    return split(' ')
        .map((word) => word.isEmpty
            ? word
            : word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  /// Extracts variables from template string
  List<String> extractVariables() {
    final regex = RegExp(r'\{\{(\w+)\}\}');
    return regex
        .allMatches(this)
        .map((match) => match.group(1))
        .where((variable) => variable != null)
        .cast<String>()
        .toSet()
        .toList();
  }

  /// Truncates string with ellipsis
  String truncate(int maxLength) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}...';
  }
}
