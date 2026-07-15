---
title: Fluxos, Etapas e Status
description: Documentação do sistema ONGSYS - CDC
published: true
date: 2026-07-15T17:20:00.000Z
tags: 'financeiro, ongsys, 08 fluxos etapas e status'
editor: markdown
---

# Fluxos, Etapas e Status

Toda solicitação criada no ONGSYS percorre um caminho predefinido (fluxo de trabalho). O estado atual da solicitação é identificado por seu **Status**.

## Estados Comuns de uma Demanda

### Não Enviado
O registro foi criado pelo solicitante, mas ainda não foi encaminhado para a fila de aprovação (está em rascunho).

### Em Aprovação
O registro aguarda análise de um ou mais aprovadores (coordenadores ou gerentes).

### Autorizado
A solicitação passou por todas as alçadas necessárias e está pronta para execução física (compra ou pagamento).

### Devolvido para Correção
O aprovador identificou alguma inconsistência (documento faltando, Centro de Custo errado) e devolveu o registro para que o solicitante o corrija.

### Pago
O pagamento foi efetuado pela tesouraria e o lançamento foi baixado no sistema.

> **PRINT PENDENTE — Capturar a área de histórico de status de um processo no ONGSYS, destacando as etapas e datas.**
> **Legenda sugerida:** O histórico de status indica exatamente a data, hora e o usuário que realizou cada alteração de etapa no sistema.

> **Pendente de validação:** Confirmar os nomes exatos de cada status configurado nas regras de fluxo do ERP.
