# Politica de Fontes Aceitas (MVP)

Date: 2026-03-14
Scope: fontes de dados para D&D 5e no MVP.

## Fontes Candidatas

## 1) DnD5eAPI
- Tipo: API publica baseada em SRD
- Uso esperado no MVP: classes, races, spells, equipment e referencias basicas
- Risco principal: variacao de cobertura/estrutura entre versoes

## 2) Open5e
- Tipo: API/portal open-source com SRD + OGL
- Uso esperado no MVP: complemento de cobertura para catalogo
- Risco principal: campos e granularidade podem variar por endpoint

## Regra de Aceite de Fonte

Uma fonte entra no MVP somente se cumprir TODOS os itens:

1. Licenca clara e compativel com uso no app.
2. Conteudo dentro de SRD/OGL para o escopo do MVP.
3. Disponibilidade minima aceitavel (API estavel para desenvolvimento).
4. Campos suficientes para mapear o dominio MVP.
5. Capacidade de versionamento/normalizacao local.

## Regra de Rejeicao

A fonte deve ser rejeitada se:

1. Exigir copia de conteudo protegido sem licenca apropriada.
2. Tiver termos de uso incompativeis com distribuicao do app.
3. Nao permitir auditoria da origem dos dados.

## Estrategia Primaria + Fallback

- Primaria: DnD5eAPI (5e SRD API) - https://www.dnd5eapi.co/api/
- Fallback: Open5e API - https://api.open5e.com/

Justificativa da primaria:

1. Cobertura SRD adequada para entidades do MVP.
2. Estrutura de endpoints simples para classes, races, spells e equipment.
3. Boa relacao entre completude inicial e custo (gratuita).

## Contrato de Normalizacao (obrigatorio)

Todos os dados externos devem ser convertidos para contratos internos do app:

- CharacterCatalogClass
- CharacterCatalogRace
- CharacterCatalogSpell
- CharacterCatalogEquipment

Com isso, troca de fonte nao afeta UI e dominio.

## Fora do Escopo do MVP

- Ingestao de PHB completo protegido.
- Scraping de PDF proprietario para uso no app principal.

Se houver necessidade futura, abrir projeto separado de ingestao/licenciamento.
