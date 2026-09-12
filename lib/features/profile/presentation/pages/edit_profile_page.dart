import 'package:askdev/core/utils/extensions_context.dart';
import 'package:askdev/core/utils/validators.dart';
import 'package:askdev/features/profile/presentation/manager/profile_cubit.dart';
import 'package:askdev/features/profile/presentation/manager/profile_state.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
  final _skillsController = TextEditingController();
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
      _skillsController.text = profile.skills.join(', ');
    }
  }

  @override
  void dispose() {
    _pseudoController.dispose();
    _bioController.dispose();
    _skillsController.dispose();
    super.dispose();
  }

  void _submit(ProfileCubit cubit) {
    if (!_formKey.currentState!.validate()) return;
    final skills = _skillsController.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    cubit.updateProfile(
      pseudo: _pseudoController.text,
      bio: _bioController.text,
      skills: skills,
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
                          TextFormField(
                            controller: _skillsController,
                            enabled: !isSaving,
                            decoration: const InputDecoration(
                              labelText: 'Compétences (séparées par des virgules)',
                              prefixIcon: Icon(Icons.code_outlined),
                            ),
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