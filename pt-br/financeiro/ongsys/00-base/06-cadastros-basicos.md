---
title: Cadastros Básicos
description: Documentação do sistema ONGSYS - CDC
published: true
date: 2026-07-15T17:20:00.000Z
tags: 'financeiro, ongsys, 06 cadastros basicos'
editor: markdown
---

# Cadastros Básicos

Toda transação no ONGSYS (compra, pagamento, contrato) exige a existência prévia de um cadastro de cliente, fornecedor ou item.

## Regras de Integridade
* **Evite Duplicidade:** Antes de solicitar a criação de um novo cadastro, pesquise exaustivamente se o fornecedor ou produto já existe.
* **Dados Obrigatórios:** Cadastros de fornecedores devem conter CNPJ/CPF válidos, razão social/nome completo e dados bancários corretos.

> **Não faça: Cadastros Duplos**
> Não crie um segundo cadastro para um fornecedor apenas porque ele mudou de endereço ou conta bancária. A duplicidade gera erros em relatórios contábeis e impede a prestação de contas correta.

> **Regra do CDC: Atualização de Dados**
> Caso identifique um cadastro incorreto (ex: CPF digitado errado), inative o registro atual e solicite a criação de um novo com a documentação em anexo.

> **Pendente de validação:** Validar quem é o setor responsável por auditar e aprovar a inserção de novos fornecedores no banco de dados.
