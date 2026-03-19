# Contexto da Conversa e Snapshot do Projeto

Date: 2026-03-19
Branch: main
Workspace: c:\dev\rpg

## Objetivo deste arquivo

Registrar em um unico lugar o contexto consolidado desta conversa, as decisoes tomadas, a evolucao das implementacoes e o estado atual do projeto no momento do commit.

## Resumo executivo

O projeto evoluiu de um shell Flutter vazio para um app de fichas de RPG D&D 5e com:

- base Flutter organizada por features
- persistencia local com SQLite
- estado com Riverpod
- integracao com catalogo SRD via DnD5eAPI
- fallback via Open5e
- tela inicial com lista de personagens e criacao de ficha
- tela de detalhe com atributos, HP, CA, pericias, resistencias e slots de magia
- enriquecimento automatico da ficha com dados de classe e raca vindos da API
- abertura de descricoes de tracos raciais e habilidades de classe
- traducao automatica opcional para conteudo vindo da API
- tela de configuracoes com liga/desliga para traducao automatica

## Linha do tempo consolidada da conversa

### 1. Reset e estruturacao inicial

- Pedido inicial para zerar o projeto Flutter e transforma-lo em uma base "empty".
- Em seguida, a base foi reestruturada com foco em arquitetura clara, baixo acoplamento e evolucao incremental.

### 2. Planejamento do MVP

- Foi definido o plano de desenvolvimento do MVP de um app de ficha para D&D 5e.
- Houve pesquisa e definicao de fontes de dados aceitas.
- Foram documentadas decisoes de produto e compliance para limitar o conteudo do MVP a SRD/OGL e fontes compativeis.

### 3. Integracao de catalogo

- Foi introduzida integracao com duas fontes:
  - primaria: DnD5eAPI
  - fallback: Open5e
- Foram modeladas entidades para catalogo e camada de repositorio para normalizacao dos dados.

### 4. Persistencia e dominio da ficha

- Foi criada a persistencia local da ficha via SQLite.
- A entidade principal de personagem passou a conter:
  - nome, classe, raca e ids externos
  - atributos
  - HP atual, maximo e temporario
  - CA
  - pericias e resistencias
  - slots de magia usados
  - notas
- Foram adicionados calculos derivados como bonus de proficiencia, modificadores, resistencias e pericias.

### 5. Correcoes de bugs a partir de log

- Bug corrigido: `LateInitializationError` em `_tempHpController`.
- Bug corrigido: overflow de layout em `_AbilityCell`.
- As validacoes anteriores passaram apos a correcao.

### 6. Enriquecimento da tela de detalhe

Foi expandida a ficha do personagem com informacoes vindas da API:

- deslocamento racial automatico
- tracos raciais
- habilidades de classe por nivel
- informacoes de spellcasting e slots de magia
- bonus raciais nos atributos

Tambem foram adicionadas as persistencias de:

- `tempHp`
- `armorClass`
- `spellSlotsUsed`

### 7. Melhorias de UX na ficha

Foi implementado um conjunto de refinamentos na tela de detalhe:

- bonus de proficiencia exibido junto do nivel no topo
- botoes de resistencias e pericias movidos para FABs
- acao de subir de nivel com dialogo de confirmacao
- chips clicaveis para abrir a descricao de tracos e habilidades

### 8. Traducao automatica

O app passou a suportar traducao automatica do conteudo vindo da API:

- descricoes de tracos e habilidades
- nomes de classes e racas do catalogo
- detalhes resumidos de classe e raca
- `RaceInfo`, `ClassInfo` e `ClassLevelInfo`

Foi criado um toggle de configuracao para ativar ou desativar a traducao automatica, com persistencia local via `SharedPreferences`.

## Decisoes tecnicas principais

### Arquitetura

- Separacao por feature em `catalog`, `character`, `home` e `settings`.
- Uso de `domain`, `data` e `presentation` onde aplicavel.

### Estado

- `flutter_riverpod` para providers, listas de personagens, dados de catalogo e configuracoes.

### Persistencia local

- `sqflite` para armazenamento das fichas.
- schema atual com suporte a campos basicos e avancados da ficha.

### Fontes externas

- `SrdCatalogDatasource` como fonte principal.
- `Open5eCatalogDatasource` como fallback para classes e racas.

### Traducao

- `AutoTranslateService` encapsula a traducao automatica.
- Cache em memoria para reduzir retrabalho em textos repetidos.
- Quando a traducao falha, o app exibe o texto original.

## Estado atual da aplicacao

### Home

- lista personagens persistidos
- permite criar personagem
- abre tela de configuracoes por icone de engrenagem

### Configuracoes

- toggle de traducao automatica
- persistencia do estado do toggle

### Ficha do personagem

- edicao de nome e nivel
- classe e raca enriquecidas pelo catalogo
- HP, HP temporario, HP maximo, dado de vida, CA e deslocamento
- atributos com modificadores e bonus raciais
- resistencias e pericias em FABs
- slots de magia para classes conjuradoras
- tracos raciais e habilidades de classe clicaveis
- acao de subir de nivel

## Arquivos e modulos relevantes no snapshot atual

### Novos modulos principais

- `lib/src/core/database/app_database.dart`
- `lib/src/features/catalog/data/datasources/srd_catalog_datasource.dart`
- `lib/src/features/catalog/data/datasources/open5e_catalog_datasource.dart`
- `lib/src/features/catalog/data/repositories/network_catalog_repository.dart`
- `lib/src/features/catalog/data/services/auto_translate_service.dart`
- `lib/src/features/catalog/domain/entities/catalog_entry.dart`
- `lib/src/features/catalog/domain/entities/catalog_detail.dart`
- `lib/src/features/catalog/domain/entities/race_info.dart`
- `lib/src/features/catalog/domain/entities/class_info.dart`
- `lib/src/features/catalog/domain/entities/class_level_info.dart`
- `lib/src/features/catalog/domain/repositories/catalog_repository.dart`
- `lib/src/features/catalog/presentation/providers/catalog_providers.dart`
- `lib/src/features/character/domain/entities/character_sheet.dart`
- `lib/src/features/character/domain/repositories/character_repository.dart`
- `lib/src/features/character/data/repositories/drift_character_repository.dart`
- `lib/src/features/character/data/repositories/cached_character_repository.dart`
- `lib/src/features/character/presentation/providers/character_providers.dart`
- `lib/src/features/character/presentation/pages/character_detail_page.dart`
- `lib/src/features/settings/presentation/providers/app_settings_provider.dart`
- `lib/src/features/settings/presentation/pages/settings_page.dart`

### Arquivos atualizados importantes

- `lib/main.dart`
- `lib/src/app/app.dart`
- `lib/src/features/home/presentation/pages/home_page.dart`
- `pubspec.yaml`
- `test/widget_test.dart`

### Documentacao adicionada no ciclo

- `docs/adr/0001-mvp-content-policy.md`
- `docs/data/fontes-aceitas.md`
- `docs/data/matriz-fontes-fase1.md`
- `docs/mvp/fase-0-checklist.md`

## Estado do git no momento deste registro

Arquivos modificados:

- `lib/main.dart`
- `lib/src/app/app.dart`
- `lib/src/features/home/presentation/pages/home_page.dart`
- `macos/Flutter/GeneratedPluginRegistrant.swift`
- `pubspec.lock`
- `pubspec.yaml`
- `test/widget_test.dart`

Arquivos novos e diretorios novos:

- `docs/`
- `lib/src/core/database/`
- `lib/src/features/catalog/`
- `lib/src/features/character/`
- `lib/src/features/settings/`
- `log.txt`

## Validacoes conhecidas no contexto desta sessao

- As ultimas validacoes reportadas indicaram ausencia de erros nos arquivos alterados relevantes.
- O teste de widget atual passou no estado validado anteriormente nesta sessao.

## Observacoes

- O texto salvo para classe e raca no banco continua usando o valor original quando necessario para preservar consistencia com os ids externos.
- A exibicao na UI prioriza os nomes enriquecidos e traduzidos quando os ids da API estao disponiveis.
- A traducao automatica depende de rede e pode retornar o texto original caso a traducao falhe.

## Intencao do commit deste snapshot

Congelar o estado atual do projeto com:

- MVP de ficha funcional
- integracao de catalogo
- traducao automatica opcional
- tela de configuracoes
- refinamentos recentes da ficha detalhada
