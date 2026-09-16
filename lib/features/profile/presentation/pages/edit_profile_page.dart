import 'dart:io';

import 'package:askdev/core/themes/app_tokens.dart';
import 'package:askdev/core/utils/extensions_context.dart';
import 'package:askdev/core/utils/validators.dart';
import 'package:askdev/core/widgets/tag_chip.dart';
import 'package:askdev/features/profile/presentation/manager/profile_cubit.dart';
import 'package:askdev/features/profile/presentation/manager/profile_state.dart';
import 'package:askdev/features/profile/presentation/pages/avatar_edit.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

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
  List<String> _topics = <String>[];
  XFile? _avatar;
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
      avatar: _avatar != null ? File(_avatar!.path) : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ProfileCubit>();
    final theme = Theme.of(context);

    return BlocListener<ProfileCubit, ProfileState>(
      listenWhen: (prev, curr) => prev.isSaving && !curr.isSaving,
      listener: (context, state) {
        if (state.error != null) {
          context.showError(state.error!);
        } else {
          context.showSuccess('Profil mis à jour.');
          context.router.maybePop();
        }
      },
      child: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          final isSaving = state.isSaving;
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                onPressed: () => context.router.maybePop(),
                icon: const Icon(Icons.close_rounded),
                tooltip: 'Fermer',
              ),
              title: const Text('Modifier le profil'),
            ),
            bottomNavigationBar: DecoratedBox(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                border: Border(
                  top: BorderSide(color: theme.colorScheme.outlineVariant),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: AppLayout.listPadding(
                    context,
                    maxWidth: AppLayout.formMaxWidth,
                    top: AppSpacing.md,
                    bottom: AppSpacing.md,
                  ),
                  child: FilledButton.icon(
                    onPressed: isSaving ? null : () => _submit(cubit),
                    icon: isSaving
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.check_rounded, size: 18),
                    label: const Text('Enregistrer'),
                  ),
                ),
              ),
            ),
            body: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: ListView(
                padding: AppLayout.listPadding(
                  context,
                  maxWidth: AppLayout.formMaxWidth,
                ),
                children: [
                  Center(
                    child: AvatarPicker(
                      enabled: !isSaving,
                      currentAvatarUrl: state.profile?.avatarUrl,
                      name: state.profile?.pseudo,
                      onImageSelected: (image) =>
                          setState(() => _avatar = image),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
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
                  const SizedBox(height: AppSpacing.lg),
                  TextFormField(
                    controller: _bioController,
                    enabled: !isSaving,
                    minLines: 3,
                    maxLines: 6,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Bio',
                      hintText: 'Votre parcours, vos technos, vos projets…',
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _TopicInput(
                    enabled: !isSaving,
                    topics: _topics,
                    canAddMore: _topics.length < _maxTopics,
                    onAdded: (topic) => setState(() {
                      if (!_topics.contains(topic)) _topics.add(topic);
                    }),
                    onRemoved: (topic) => setState(() => _topics.remove(topic)),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Saisie des topics sous forme de puces ajoutables une à une.
class _TopicInput extends StatefulWidget {
  const _TopicInput({
    required this.topics,
    required this.canAddMore,
    required this.onAdded,
    required this.onRemoved,
    this.enabled = true,
  });

  final List<String> topics;
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
    final topic = raw
        .trim()
        .replaceAll(',', '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (topic.isEmpty) return;
    _controller.clear();
    widget.onAdded(topic);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.topics.isNotEmpty) ...[
          Wrap(
            spacing: AppSpacing.xs + 2,
            runSpacing: AppSpacing.xs + 2,
            children: [
              for (final topic in widget.topics)
                TagChip(
                  topic,
                  onDeleted: widget.enabled
                      ? () => widget.onRemoved(topic)
                      : null,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        TextField(
          controller: _controller,
          enabled: widget.enabled && widget.canAddMore,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            labelText: 'Topics',
            hintText: widget.canAddMore
                ? 'Ajouter un topic, puis Entrée'
                : 'Limite de $_maxTopics topics atteinte',
            prefixIcon: const Icon(Icons.sell_outlined),
          ),
          onSubmitted: widget.enabled && widget.canAddMore ? _add : null,
        ),
      ],
    );
  }
}
