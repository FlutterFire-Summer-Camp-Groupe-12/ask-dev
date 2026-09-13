import 'package:askdev/core/themes/app_colors.dart';
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
    required this.maxTags,
    this.suggestions = const [],
    this.enabled = true,
    this.hasError = false,
  });

  final List<String> tags;
  final ValueChanged<String> onTagAdded;
  final ValueChanged<String> onTagRemoved;
  final int maxTags;
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

  bool get _isFull => widget.tags.length >= widget.maxTags;

  void _submit(String value) {
    if (value.trim().isEmpty) return;
    widget.onTagAdded(value);
    _controller.clear();
    setState(() {});
    _focusNode.requestFocus();
  }

  /// Suggestions restantes : celles qui contiennent la saisie courante et qui
  /// ne sont pas déjà sélectionnées.
  List<String> get _visibleSuggestions {
    if (_isFull) return const [];
    final query = _controller.text.trim().toLowerCase();
    return widget.suggestions
        .where((tag) => !widget.tags.contains(tag))
        .where((tag) => query.isEmpty || tag.contains(query))
        .take(8)
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final suggestions = _visibleSuggestions;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.tags.isNotEmpty) ...[
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final tag in widget.tags)
                _SelectedTagChip(
                  label: tag,
                  onRemoved:
                      widget.enabled ? () => widget.onTagRemoved(tag) : null,
                ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          enabled: widget.enabled && !_isFull,
          onChanged: (_) => setState(() {}),
          onSubmitted: _submit,
          textInputAction: TextInputAction.done,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
          inputFormatters: [
            // Un espace ou une virgule valide le tag en cours.
            FilteringTextInputFormatter.deny(
              RegExp(r'[\s,]'),
              replacementString: '',
            ),
          ],
          decoration: questionFieldDecoration(
            hintText: _isFull
                ? '${widget.maxTags} tags maximum atteints'
                : 'ex. (flutter dart firebase)',
            hasError: widget.hasError,
          ).copyWith(
            prefixIcon: const Icon(
              Icons.search,
              size: 18,
              color: AppColors.textMuted,
            ),
            prefixIconConstraints: const BoxConstraints.tightFor(
              width: 38,
              height: 20,
            ),
            suffixIcon: _controller.text.trim().isEmpty
                ? null
                : IconButton(
                    onPressed: () => _submit(_controller.text),
                    icon: const Icon(Icons.add, size: 18),
                    color: AppColors.accent,
                    tooltip: 'Ajouter ce tag',
                  ),
          ),
        ),
        if (suggestions.isNotEmpty && _focusNode.hasFocus) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final suggestion in suggestions)
                _SuggestionChip(
                  label: suggestion,
                  onTap: widget.enabled ? () => _submit(suggestion) : null,
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _SelectedTagChip extends StatelessWidget {
  const _SelectedTagChip({required this.label, required this.onRemoved});

  final String label;
  final VoidCallback? onRemoved;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 10, right: 4, top: 4, bottom: 4),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.accent, fontSize: 12),
          ),
          const SizedBox(width: 2),
          InkWell(
            onTap: onRemoved,
            borderRadius: BorderRadius.circular(10),
            child: const Padding(
              padding: EdgeInsets.all(2),
              child: Icon(Icons.close, size: 14, color: AppColors.accent),
            ),
          ),
        ],
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  const _SuggestionChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surfaceHigh,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
      ),
    );
  }
}
