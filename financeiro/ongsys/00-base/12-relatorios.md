---
title: Relatórios
description: Documentação do sistema ONGSYS - CDC
published: true
date: 2026-07-16T07:01:44.745Z
tags: financeiro, ongsys, 12 relatorios
editor: markdown
dateCreated: 2026-07-15T21:30:34.561Z
---

# Relatórios

O módulo de **Relatórios** permite consultar e exportar informações geradas pelos lançamentos do sistema.

## Acesso a Relatórios
* A visualização de relatórios depende diretamente do seu perfil de acesso.
* Usuários operacionais visualizam relatórios de suas próprias solicitações ou Centros de Custo autorizados.
* Gestores e supervisores visualizam relatórios consolidados de suas áreas e projetos.
* Os relatórios podem ser exportados para planilhas eletrônicas (Excel) para facilitar auditorias e análises.

![relatório_fluxo_de_caixa_detalhado.png](/img/ongsys/base/compras/relatório_fluxo_de_caixa_detalhado.png)

Observação e organização dos dados

A boa análise começa com uma pergunta simples: o que precisamos descobrir ou apresentar com estes dados?
> 
Uma tabela pode conter muitas informações importantes, mas nem todas precisam aparecer ao mesmo tempo. Observar, organizar e limpar os dados significa retirar excessos, padronizar informações e selecionar apenas os campos que ajudam a alcançar o objetivo do relatório.

Esse processo pode ser entendido como enxugar os dados: preservamos o registro completo no sistema, mas criamos uma visão mais simples para facilitar a leitura e a compreensão. Dessa forma, uma mesma base pode gerar diferentes relatórios, dependendo da necessidade de quem irá consultá-la.

> Importante — Simplificar uma tabela não significa apagar informações do sistema. Significa criar uma visualização com apenas os dados necessários para determinada análise ou apresentação.

Processo na prática

Na tabela original, encontramos informações financeiras, bancárias, contábeis e administrativas. Entretanto, imagine que o nosso objetivo seja responder apenas às seguintes perguntas:

Qual foi o lançamento?
Quem recebeu o pagamento?
Qual foi a finalidade da despesa?
A qual projeto ela pertence?
Qual foi o valor?
Quando o pagamento ocorreu?

Com esse objetivo definido, podemos reduzir a tabela para uma visão mais simples:

| Fornecedor | Descrição | Projeto | Valor |
|---|---|---|---:|
| Transportes Exemplo Ltda. | Locação de van | Projeto Educação para Todos | R$ 1.500,00 |

> Processo na prática — A tabela original possui 18 colunas, mas nem todas são necessárias para esta apresentação. Como o objetivo é identificar o fornecedor, a finalidade da despesa, o projeto relacionado e o valor, selecionamos apenas esses campos. Essa escolha torna o relatório mais fácil de ler sem alterar os dados originais armazenados no sistema.
{.is-info}

> Como interpretar o relatório — As informações não devem ser observadas de forma isolada. Ao relacionar campos como competência, vencimento, fornecedor, categoria, projeto e valor, é possível compreender melhor por que o lançamento foi criado e a qual atividade ele está relacionado.
{.is-info}


> Atenção aos registros — O relatório apresenta as informações que foram cadastradas no sistema. Por isso, campos incompletos ou incorretos também podem aparecer no resultado e indicar a necessidade de conferir o lançamento original.
{.is-warning}

> Para refletir — Caso o objetivo fosse conferir vencimentos, movimentações bancárias ou classificações contábeis, quais colunas deveriam permanecer no relatório?
{.is-warning}

> Para refletir — Ao encontrar um lançamento no relatório, você conseguiria identificar quem receberá o pagamento, a que projeto a despesa pertence, qual atividade a originou e se houve movimentação de caixa?
{.is-warning}

