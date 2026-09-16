import 'package:askdev/core/themes/app_tokens.dart';
import 'package:askdev/core/widgets/tag_chip.dart';
import 'package:askdev/features/forum/presentation/widgets/question_form_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Champ de saisie des tags : chips sélectionnés, saisie libre et
/// suggestions filtrées au fil de la frappe.
class TagInputField extends StatefulWidget {
  const TagInputField({
    super.key,
    required this.tags,
    required this.onTagAdded,
    required this.onTagRemoved,
    this.suggestions = const [],
    this.enabled = true,
    this.hasError = false,
  });

  final List<String> tags;
  final ValueChanged<String> onTagAdded;
  final ValueChanged<String> onTagRemoved;
  final List<String> suggestions;
  final bool enabled;
  final bool hasError;

  @override
  State<TagInputField> createState() => _TagInputFieldState();
}

class _TagInputFieldState extends State<TagInputField> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submit(String value) {
    if (value.trim().isEmpty) return;
    widget.onTagAdded(value);
    _controller.clear();
    setState(() {});
    _focusNode.requestFocus();
  }

  List<String> get _visibleSuggestions {
    final query = _controller.text.trim().toLowerCase();
    return widget.suggestions
        .where((tag) => !widget.tags.contains(tag))
        .where((tag) => query.isEmpty || tag.contains(query))
        .take(8)
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final suggestions = _visibleSuggestions;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.tags.isNotEmpty) ...[
          Wrap(
            spacing: AppSpacing.xs + 2,
            runSpacing: AppSpacing.xs + 2,
            children: [
              for (final tag in widget.tags)
                TagChip(
                  tag,
                  onDeleted: widget.enabled
                      ? () => widget.onTagRemoved(tag)
                      : null,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          enabled: widget.enabled,
          onChanged: (_) => setState(() {}),
          onSubmitted: _submit,
          textInputAction: TextInputAction.done,
          style: Theme.of(context).textTheme.bodyMedium,
          inputFormatters: [
            // Un espace ou une virgule valide le tag en cours.
            FilteringTextInputFormatter.deny(
              RegExp(r'[\s,]'),
              replacementString: '',
            ),
          ],
          decoration:
              questionFieldDecoration(
                colors: colors,
                hintText: 'ex. flutter, firebase, bloc',
                hasError: widget.hasError,
              ).copyWith(
                prefixIcon: const Icon(Icons.sell_outlined, size: 18),
                suffixIcon: _controller.text.trim().isEmpty
                    ? null
                    : IconButton(
                        onPressed: () => _submit(_controller.text),
                        icon: const Icon(Icons.add, size: 18),
                        color: colors.primary,
                        tooltip: 'Ajouter ce tag',
                      ),
              ),
        ),
        if (suggestions.isNotEmpty && _focusNode.hasFocus) ...[
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.xs + 2,
            runSpacing: AppSpacing.xs + 2,
            children: [
              for (final suggestion in suggestions)
                TagChip(
                  suggestion,
                  muted: true,
                  onTap: widget.enabled ? () => _submit(suggestion) : null,
                ),
            ],
          ),
        ],
      ],
    );
  }
}
