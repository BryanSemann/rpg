# ADR 0001 - MVP Content Policy (D&D 5e)

- Status: accepted
- Date: 2026-03-14
- Owners: Product + Engineering

## Context

O produto e um gerenciador/editor de ficha de RPG para D&D 5e.
Existe risco legal e tecnico ao misturar fontes com licencas diferentes.
Sem politica explicita, o time pode incluir conteudo protegido fora do escopo do MVP.

## Decision

Para o MVP, o projeto aceita apenas conteudo SRD/OGL e fontes com licenca compativel para uso em app.

Regras obrigatorias:

1. Nao incluir conteudo integral protegido do Player's Handbook (PHB) no MVP.
2. Nao fazer scraping/copia de PDFs proprietarios para uso no app MVP.
3. Toda fonte externa deve passar por validacao de licenca antes de entrar em producao.
4. O app deve manter camada de normalizacao de dados para trocar fonte sem quebrar dominio.
5. Caso exista demanda futura por conteudo nao-SRD, abrir projeto separado de ingestao/licenciamento.

## Consequences

Positivas:

- Reduz risco juridico no MVP.
- Mantem escopo claro e entregavel.
- Evita retrabalho arquitetural com contrato de dados estavel.

Trade-offs:

- Cobertura inicial de regras/conteudo menor que PHB completo.
- Algumas classes/subclasses/feats podem ficar para fases posteriores.

## Non-Goals (MVP)

- Importacao integral de PHB protegido.
- Sincronizacao em nuvem.
- Conteudo homebrew sem processo de validacao.

## Compliance Gate

Uma fonte so pode ser usada no MVP se:

1. Licenca for documentada e compativel.
2. Cobertura para entidades MVP for suficiente.
3. Estrutura de API/arquivo for estavel para versionamento.
4. Tiver plano de fallback definido.

## Implementation Note (2026-03-14)

Fonte primaria aprovada para o MVP: DnD5eAPI (5e SRD API) em https://www.dnd5eapi.co/api/

Fonte de fallback aprovada: Open5e API em https://api.open5e.com/
