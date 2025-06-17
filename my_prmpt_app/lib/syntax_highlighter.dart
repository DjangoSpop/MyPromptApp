// lib/presentation/widgets/syntax_highlighter.dart
import 'package:flutter/material.dart';

/// A widget that highlights placeholder syntax in template content
class SyntaxHighlighter extends StatelessWidget {
  final String content;
  final TextStyle? defaultStyle;
  final TextStyle? placeholderStyle;
  final TextStyle? specialTagStyle;
  final bool enableSelection;

  const SyntaxHighlighter({
    super.key,
    required this.content,
    this.defaultStyle,
    this.placeholderStyle,
    this.specialTagStyle,
    this.enableSelection = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    final TextStyle defaultTextStyle = defaultStyle ?? const TextStyle(
      fontFamily: 'monospace',
      fontSize: 14,
      height: 1.5,
    );
    
    final TextStyle placeholderTextStyle = placeholderStyle ?? TextStyle(
      color: theme.primaryColor,
      fontWeight: FontWeight.w600,
      backgroundColor: theme.primaryColor.withOpacity(0.1),
      fontFamily: 'monospace',
      fontSize: 14,
      height: 1.5,
    );
    
    final TextStyle specialTextStyle = specialTagStyle ?? TextStyle(
      color: theme.colorScheme.secondary,
      fontWeight: FontWeight.w600,
      fontFamily: 'monospace',
      fontSize: 14,
      height: 1.5,
    );

    return enableSelection 
        ? SelectableText.rich(
            _buildHighlightedText(
              defaultTextStyle, 
              placeholderTextStyle,
              specialTextStyle,
            ),
          )
        : RichText(
            text: _buildHighlightedText(
              defaultTextStyle, 
              placeholderTextStyle,
              specialTextStyle,
            ),
          );
  }

  /// Builds text span with highlighted syntax
  TextSpan _buildHighlightedText(
    TextStyle defaultStyle,
    TextStyle placeholderStyle,
    TextStyle specialStyle,
  ) {
    final List<TextSpan> spans = [];
    int lastIndex = 0;

    // Pattern for {{variable}} placeholders
    final placeholderRegex = RegExp(r'\{\{(\w+)\}\}');
    
    // Pattern for special Handlebars tags like {{#if}} and {{/if}}
    final specialTagRegex = RegExp(r'\{\{[#\/](\w+).*?\}\}');
    
    // Combined pattern to match both types
    final combinedRegex = RegExp(r'\{\{[#\/]?(\w+).*?\}\}');
    
    // Find all matches of combined pattern
    final allMatches = combinedRegex.allMatches(content);
    
    for (final match in allMatches) {
      // Add text before the match
      if (match.start > lastIndex) {
        spans.add(TextSpan(
          text: content.substring(lastIndex, match.start),
          style: defaultStyle,
        ));
      }
      
      final matchedText = match.group(0) ?? '';
      
      // Determine which regex matched
      if (specialTagRegex.hasMatch(matchedText)) {
        // Special tag like {{#if}} or {{/if}}
        spans.add(TextSpan(
          text: matchedText,
          style: specialStyle,
        ));
      } else if (placeholderRegex.hasMatch(matchedText)) {
        // Regular placeholder like {{variable}}
        spans.add(TextSpan(
          text: matchedText,
          style: placeholderStyle,
        ));
      } else {
        // Fallback (should not happen with our regex)
        spans.add(TextSpan(
          text: matchedText,
          style: defaultStyle,
        ));
      }
      
      lastIndex = match.end;
    }

    // Add remaining text
    if (lastIndex < content.length) {
      spans.add(TextSpan(
        text: content.substring(lastIndex),
        style: defaultStyle,
      ));
    }

    return TextSpan(children: spans);
  }
}