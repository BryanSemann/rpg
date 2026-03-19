import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rpg_app/src/features/settings/presentation/providers/app_settings_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(appSettingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Configuracoes')),
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Erro: $error')),
        data: (settings) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: SwitchListTile(
                  value: settings.autoTranslateEnabled,
                  title: const Text('Traducao automatica'),
                  subtitle: const Text(
                    'Traduz classes, racas, tracos, habilidades e detalhes vindos da API.',
                  ),
                  onChanged: (value) {
                    ref
                        .read(appSettingsProvider.notifier)
                        .setAutoTranslateEnabled(value);
                  },
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Quando ativada, o app tenta traduzir automaticamente o conteudo em ingles do catalogo. Se a traducao falhar, o texto original continua sendo exibido.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          );
        },
      ),
    );
  }
}
