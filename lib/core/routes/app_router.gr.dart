// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

/// generated route for
/// [AppNavigationShellPage]
class AppNavigationShellRoute extends PageRouteInfo<void> {
  const AppNavigationShellRoute({List<PageRouteInfo>? children})
    : super(AppNavigationShellRoute.name, initialChildren: children);

  static const String name = 'AppNavigationShellRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const AppNavigationShellPage();
    },
  );
}

/// generated route for
/// [AskQuestionPage]
class AskQuestionRoute extends PageRouteInfo<void> {
  const AskQuestionRoute({List<PageRouteInfo>? children})
    : super(AskQuestionRoute.name, initialChildren: children);

  static const String name = 'AskQuestionRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const AskQuestionPage();
    },
  );
}

/// generated route for
/// [EditProfilePage]
class EditProfileRoute extends PageRouteInfo<void> {
  const EditProfileRoute({List<PageRouteInfo>? children})
    : super(EditProfileRoute.name, initialChildren: children);

  static const String name = 'EditProfileRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const EditProfilePage();
    },
  );
}

/// generated route for
/// [EditQuestionPage]
class EditQuestionRoute extends PageRouteInfo<EditQuestionRouteArgs> {
  EditQuestionRoute({
    Key? key,
    required Question question,
    List<PageRouteInfo>? children,
  }) : super(
         EditQuestionRoute.name,
         args: EditQuestionRouteArgs(key: key, question: question),
         initialChildren: children,
       );

  static const String name = 'EditQuestionRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<EditQuestionRouteArgs>();
      return EditQuestionPage(key: args.key, question: args.question);
    },
  );
}

class EditQuestionRouteArgs {
  const EditQuestionRouteArgs({this.key, required this.question});

  final Key? key;

  final Question question;

  @override
  String toString() {
    return 'EditQuestionRouteArgs{key: $key, question: $question}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! EditQuestionRouteArgs) return false;
    return key == other.key && question == other.question;
  }

  @override
  int get hashCode => key.hashCode ^ question.hashCode;
}

/// generated route for
/// [LoginPage]
class LoginRoute extends PageRouteInfo<void> {
  const LoginRoute({List<PageRouteInfo>? children})
    : super(LoginRoute.name, initialChildren: children);

  static const String name = 'LoginRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const LoginPage();
    },
  );
}

/// generated route for
/// [MyContributionsPage]
class MyContributionsRoute extends PageRouteInfo<void> {
  const MyContributionsRoute({List<PageRouteInfo>? children})
    : super(MyContributionsRoute.name, initialChildren: children);

  static const String name = 'MyContributionsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const MyContributionsPage();
    },
  );
}

/// generated route for
/// [ProfilePage]
class ProfileRoute extends PageRouteInfo<void> {
  const ProfileRoute({List<PageRouteInfo>? children})
    : super(ProfileRoute.name, initialChildren: children);

  static const String name = 'ProfileRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ProfilePage();
    },
  );
}

/// generated route for
/// [QuestionDetailPage]
class QuestionDetailRoute extends PageRouteInfo<QuestionDetailRouteArgs> {
  QuestionDetailRoute({
    Key? key,
    required String questionId,
    List<PageRouteInfo>? children,
  }) : super(
         QuestionDetailRoute.name,
         args: QuestionDetailRouteArgs(key: key, questionId: questionId),
         initialChildren: children,
       );

  static const String name = 'QuestionDetailRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<QuestionDetailRouteArgs>();
      return QuestionDetailPage(key: args.key, questionId: args.questionId);
    },
  );
}

class QuestionDetailRouteArgs {
  const QuestionDetailRouteArgs({this.key, required this.questionId});

  final Key? key;

  final String questionId;

  @override
  String toString() {
    return 'QuestionDetailRouteArgs{key: $key, questionId: $questionId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! QuestionDetailRouteArgs) return false;
    return key == other.key && questionId == other.questionId;
  }

  @override
  int get hashCode => key.hashCode ^ questionId.hashCode;
}

/// generated route for
/// [QuestionsHomePage]
class QuestionsHomeRoute extends PageRouteInfo<void> {
  const QuestionsHomeRoute({List<PageRouteInfo>? children})
    : super(QuestionsHomeRoute.name, initialChildren: children);

  static const String name = 'QuestionsHomeRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const QuestionsHomePage();
    },
  );
}

/// generated route for
/// [RegisterPage]
class RegisterRoute extends PageRouteInfo<void> {
  const RegisterRoute({List<PageRouteInfo>? children})
    : super(RegisterRoute.name, initialChildren: children);

  static const String name = 'RegisterRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const RegisterPage();
    },
  );
}

/// generated route for
/// [SettingsPage]
class SettingsRoute extends PageRouteInfo<void> {
  const SettingsRoute({List<PageRouteInfo>? children})
    : super(SettingsRoute.name, initialChildren: children);

  static const String name = 'SettingsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SettingsPage();
    },
  );
}

/// generated route for
/// [WelcomePage]
class WelcomeRoute extends PageRouteInfo<void> {
  const WelcomeRoute({List<PageRouteInfo>? children})
    : super(WelcomeRoute.name, initialChildren: children);

  static const String name = 'WelcomeRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const WelcomePage();
    },
  );
}
