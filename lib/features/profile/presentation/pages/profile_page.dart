import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D0F),
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back_ios_new),
          iconSize: 18,
          color: Colors.white,
          tooltip: 'Retour',
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.edit_outlined),
            iconSize: 20,
            color: Colors.white,
            tooltip: 'Modifier le profil',
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert),
            iconSize: 21,
            color: Colors.white,
            tooltip: 'Plus d’options',
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 5, 20, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white38),
                      ),
                      child: const CircleAvatar(
                        backgroundColor: Color(0xFF17181B),
                        child: Icon(
                          Icons.person,
                          color: Colors.white70,
                          size: 38,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Peng Cheng',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      '@pengcheng',
                      style: TextStyle(color: Colors.white60, fontSize: 12),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Membre depuis mars 2026',
                      style: TextStyle(color: Colors.white38, fontSize: 10),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              const Divider(color: Colors.white12, height: 1),
              const SizedBox(height: 18),
              const Row(
                children: [
                  Expanded(
                    child: _ProfileStat(value: '12', label: 'Questions'),
                  ),
                  _VerticalDivider(),
                  Expanded(
                    child: _ProfileStat(value: '34', label: 'Réponses'),
                  ),
                  _VerticalDivider(),
                  Expanded(
                    child: _ProfileStat(value: '5', label: 'Meilleures'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(color: Colors.white12, height: 1),
              const SizedBox(height: 20),
              const Text(
                'À propos',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 9),
              const Text(
                'Développeur web apprenant Flutter car passionné par les technologies mobiles '
                'Toujours curieux d’apprendre et de partager !',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Compétences',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              const Wrap(
                spacing: 6,
                runSpacing: 7,
                children: [
                  _SkillChip(label: 'Flutter'),
                  _SkillChip(label: 'Dart'),
                  _SkillChip(label: 'Firebase'),
                  _SkillChip(label: 'Clean Architecture'),
                  _SkillChip(label: 'Bloc'),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Questions récentes',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.chevron_right),
                    iconSize: 20,
                    color: Colors.white60,
                    tooltip: 'Voir les questions',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const _QuestionItem(
                title: 'Comment gérer les états dans Flutter avec Bloc ?',
              ),
              const _QuestionItem(
                title:
                    'Quelle est la différence entre MVVM et Clean Architecture ?',
              ),
              const _QuestionItem(
                title: 'Comment faire une requête HTTP avec Dio en Flutter ?',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  const _ProfileStat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 10),
        ),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(height: 30, width: 1, color: Colors.white12);
  }
}

class _SkillChip extends StatelessWidget {
  const _SkillChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF17181B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24, width: 0.8),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white70, fontSize: 10),
      ),
    );
  }
}

class _QuestionItem extends StatelessWidget {
  const _QuestionItem({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF111215),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                height: 1.35,
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, color: Colors.white54, size: 18),
        ],
      ),
    );
  }
}
