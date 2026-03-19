# Matriz de Fontes - Fase 1

Date: 2026-03-14
Status: aprovado

## Objetivo

Selecionar fonte primaria e fallback para o catalogo D&D 5e do MVP.

## Criterios

- Licenca e compliance com escopo SRD/OGL.
- Cobertura para entidades MVP.
- Estabilidade e simplicidade de integracao.
- Custo (gratuito para MVP).
- Aderencia ao contrato de normalizacao interno.

## Entidades MVP consideradas

- Classes
- Races
- Spells
- Equipment

## Comparativo resumido

| Criterio | DnD5eAPI | Open5e |
|---|---|---|
| Licenca/escopo SRD | OK | OK |
| Cobertura inicial MVP | Alta | Media/Alta |
| Simplicidade de endpoint | Alta | Media |
| Custo para MVP | Gratuito | Gratuito |
| Uso como fallback | Sim | Sim |

## Decisao

- Primaria: DnD5eAPI (https://www.dnd5eapi.co/api/)
- Fallback: Open5e API (https://api.open5e.com/)

## Metricas minimas da Fase 1

A integracao sera aceita se cumprir:

1. 100% de leitura de classes e races para o escopo MVP.
2. 95% de leitura de spells/equipment necessarios para telas MVP.
3. Tempo de resposta medio abaixo de 1.5s em rede estavel para consultas de catalogo.
4. Fallback funcional para Open5e quando endpoint primario falhar.
5. Mapeamento para contratos internos sem expor DTO externo na camada de UI.

## Risco conhecido

Pode haver diferenca de schema/campos entre fontes.
Mitigacao: normalizacao obrigatoria na camada data + testes de parser por endpoint.
