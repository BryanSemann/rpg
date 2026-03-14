# RPG App

Base inicial Flutter estruturada para evolucao incremental com foco em:

- arquitetura clara por feature
- baixo acoplamento
- cobertura de testes desde o inicio
- padrao de qualidade via lints e CI

## Estrutura

```text
lib/
	main.dart
	src/
		app/
			app.dart
		core/
			theme/
				app_theme.dart
		features/
			home/
				presentation/
					pages/
						home_page.dart
		shared/
			widgets/
				section_card.dart
test/
	widget_test.dart
```

## Como rodar

```bash
flutter pub get
flutter run
```

## Qualidade

```bash
flutter analyze
flutter test
```
