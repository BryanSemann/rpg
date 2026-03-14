import 'package:flutter/material.dart';
import 'package:rpg_app/src/shared/widgets/section_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RPG App'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SectionCard(
              title: 'Projeto inicial pronto',
              subtitle: 'Base estruturada para evoluir com seguranca e testes.',
            ),
          ],
        ),
      ),
    );
  }
}