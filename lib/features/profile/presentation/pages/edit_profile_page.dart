import 'package:askdev/core/utils/extensions_context.dart';
import 'package:askdev/core/utils/validators.dart';
import 'package:askdev/features/profile/presentation/manager/profile_cubit.dart';
import 'package:askdev/features/profile/presentation/manager/profile_state.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

const _maxTopics = 15;

@RoutePage()
class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _pseudoController = TextEditingController();
  final _bioController = TextEditingController();
  late final List<String> _topics = <String>[];
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    final profile = context.read<ProfileCubit>().state.profile;
    if (profile != null) {
      _pseudoController.text = profile.pseudo;
      _bioController.text = profile.bio ?? '';
      _topics = List.of(profile.topics);
    }
  }

  @override
  void dispose() {
    _pseudoController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _submit(ProfileCubit cubit) {
    if (!_formKey.currentState!.validate()) return;
    cubit.updateProfile(
      pseudo: _pseudoController.text,
      bio: _bioController.text,
      topics: _topics,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ProfileCubit>();
    return BlocListener<ProfileCubit, ProfileState>(
      listenWhen: (prev, curr) => prev.isSaving && !curr.isSaving,
      listener: (context, state) {
        if (state.error != null) {
          context.showError(state.error!);
        } else {
          context.router.maybePop();
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Modifier le profil')),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: BlocBuilder<ProfileCubit, ProfileState>(
                    builder: (context, state) {
                      final isSaving = state.isSaving;
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            controller: _pseudoController,
                            enabled: !isSaving,
                            autocorrect: false,
                            decoration: const InputDecoration(
                              labelText: 'Pseudo',
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                            validator: Validators.pseudo,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _bioController,
                            enabled: !isSaving,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              labelText: 'Bio',
                              alignLabelWithHint: true,
                              prefixIcon: Icon(Icons.info_outline),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _TopicInput(
                            enabled: !isSaving,
                            initialTopics: _topics,
                            canAddMore: _topics.length < _maxTopics,
                            onAdded: (topic) {
                              setState(() {
                                if (!_topics.contains(topic)) {
                                  _topics.add(topic);
                                }
                              });
                            },
                            onRemoved: (topic) {
                              setState(() {
                                _topics.remove(topic);
                              });
                            },
                          ),
                          const SizedBox(height: 28),
                          FilledButton(
                            onPressed: isSaving ? null : () => _submit(cubit),
                            child: isSaving
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Text('Enregistrer'),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Saisie des topics sous forme de chips ajoutables un à un.
class _TopicInput extends StatefulWidget {
  const _TopicInput({
    required this.initialTopics,
    required this.canAddMore,
    required this.onAdded,
    required this.onRemoved,
    this.enabled = true,
  });

  final List<String> initialTopics;
  final bool canAddMore;
  final ValueChanged<String> onAdded;
  final ValueChanged<String> onRemoved;
  final bool enabled;

  @override
  State<_TopicInput> createState() => _TopicInputState();
}

class _TopicInputState extends State<_TopicInput> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _add(String raw) {
    final topic = _cleaned(raw);
    if (topic.isEmpty) return;
    _controller.clear();
    widget.onAdded(topic);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.initialTopics.isNotEmpty) ...[
          Wrap(
            spacing: 6,
            runSpacing: 7,
            children: [
              for (final topic in widget.initialTopics)
                InputChip(
                  label: Text(topic),
                  onDeleted:
                      widget.enabled ? () => widget.onRemoved(topic) : null,
                ),
            ],
          ),
          const SizedBox(height: 12),
        ],
        TextField(
          controller: _controller,
          enabled: widget.enabled && widget.canAddMore,
          decoration: InputDecoration(
            labelText: 'Topics',
            hintText: widget.canAddMore
                ? 'Ajouter un topic (Entrée)'
                : 'Limite de $_maxTopics topics atteinte',
            prefixIcon: Icon(Icons.tag, color: colors.onSurfaceVariant),
          ),
          onSubmitted: widget.enabled && widget.canAddMore ? _add : null,
        ),
      ],
    );
  }
}

String _cleaned(String raw) {
  final trimmed = raw
      .trim()
      .replaceAll(',', '')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  return trimmed;
}