import 'package:askdev/core/themes/app_tokens.dart';
import 'package:askdev/core/utils/extensions_context.dart';
import 'package:askdev/dependency_injection/injection.dart';
import 'package:askdev/features/forum/presentation/manager/ask_question_cubit.dart';
import 'package:askdev/features/forum/presentation/manager/ask_question_state.dart';
import 'package:askdev/features/forum/presentation/widgets/question_form.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Formulaire de création d'une question, ouvert en plein écran depuis
/// l'accueil. Se ferme avec la question publiée.
@RoutePage()
class AskQuestionPage extends StatelessWidget {
  const AskQuestionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AskQuestionCubit>(
      create: (_) => sl<AskQuestionCubit>(),
      child: const AskQuestionView(),
    );
  }
}

class AskQuestionView extends StatefulWidget {
  const AskQuestionView({super.key});

  @override
  State<AskQuestionView> createState() => _AskQuestionViewState();
}

class _AskQuestionViewState extends State<AskQuestionView> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _onStateChanged(BuildContext context, AskQuestionState state) {
    final published = state.published;
    if (published != null) {
      HapticFeedback.mediumImpact();
      if (context.router.canPop()) {
        context.router.pop(published);
      } else {
        _titleController.clear();
        _contentController.clear();
        context.showSuccess('Question publiée.');
      }
      return;
    }
    final error = state.error;
    if (error != null) context.showError(error);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AskQuestionCubit>();

    return BlocListener<AskQuestionCubit, AskQuestionState>(
      listenWhen: (previous, current) =>
          previous.published != current.published ||
          (current.error != null && previous.error != current.error),
      listener: _onStateChanged,
      child: BlocBuilder<AskQuestionCubit, AskQuestionState>(
        buildWhen: (previous, current) =>
            previous.type != current.type ||
            previous.tags != current.tags ||
            previous.showErrors != current.showErrors ||
            previous.isSubmitting != current.isSubmitting ||
            (current.showErrors &&
                (previous.title != current.title ||
                    previous.content != current.content)),
        builder: (context, state) {
          final showErrors = state.showErrors;
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                onPressed: () => context.router.maybePop(),
                icon: const Icon(Icons.close_rounded),
                tooltip: 'Fermer',
              ),
              title: const Text('Poser une question'),
            ),
            bottomNavigationBar: FormActionBar(
              label: 'Publier la question',
              onPressed: cubit.submit,
              isBusy: state.isSubmitting,
            ),
            body: ListView(
              padding: AppLayout.listPadding(context),
              children: [
                const QuestionWritingTips(),
                const SizedBox(height: AppSpacing.xl),
                QuestionFormFields(
                  type: state.type,
                  onTypeChanged: cubit.typeChanged,
                  titleController: _titleController,
                  onTitleChanged: cubit.titleChanged,
                  contentController: _contentController,
                  onContentChanged: cubit.contentChanged,
                  tags: state.tags,
                  onTagAdded: cubit.tagAdded,
                  onTagRemoved: cubit.tagRemoved,
                  titleError: showErrors ? state.titleError : null,
                  contentError: showErrors ? state.contentError : null,
                  tagsError: showErrors ? state.tagsError : null,
                  enabled: !state.isSubmitting,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
