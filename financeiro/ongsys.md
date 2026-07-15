---
title: ONGSYS
description: ERP integrado de gestão financeira, contabilidade e prestação de contas do CDC
published: true
date: 2026-07-14T23:53:00.000Z
tags:
  - financeiro
  - ongsys
editor: markdown
---

# 📊 ONGSYS (ERP Financeiro)

O **ONGSYS** é o sistema integrado de gestão (ERP) oficial do **Centro de Desenvolvimento e Cidadania (CDC)**. Ele é uma plataforma focada no terceiro setor, utilizada para controle contábil, financeiro, conciliação bancária, faturamento e prestação de contas de convênios governamentais e privados.

---

## 🔗 Link de Acesso Direto
* 🌐 **URL de Produção:** [https://www.ongsys.com.br/](https://www.ongsys.com.br/)

---

## 👥 Governança e Permissões

* **Responsável Funcional:** Coordenador Financeiro do CDC.
* **Responsável Técnico:** Suporte Técnico ONGSYS / Setor de TI do CDC.
* **Perfis de Acesso:**
  - **Administrador:** Acesso total à tesouraria, contabilidade e parametrização.
  - **Operador Financeiro:** Cadastro de fornecedores, lançamento de contas a pagar e faturamento.
  - **Auditoria / Leitura:** Acesso restrito a relatórios e extratos para prestação de contas de projetos específicos.
* **Solicitação de Contas:** Envie o formulário [Cadastro de Sistemas](/ti/cadastro-sistemas) com a aprovação da coordenação financeira.

---

## 📖 Manuais e Procedimentos Operacionais ("Como Fazer")

### 1. Lançamento de Contas a Pagar (Notas Fiscais)
Toda despesa do CDC deve ser lançada no ONGSYS antes de seu pagamento:
1. No menu lateral, acesse **Financeiro > Contas a Pagar > Novo Lançamento**.
2. Preencha o CNPJ do fornecedor, valor da nota fiscal, data de emissão e data de vencimento.
3. **Classificação:** Vincule a despesa ao **Centro de Custo** (ex: Projeto XYZ) e à **Conta Contábil** correta (ex: Material de Expediente).
4. **Anexo:** Faça o upload do arquivo PDF da Nota Fiscal.

### 2. Conciliação Bancária Diária
Para manter o saldo da ONG idêntico ao extrato real dos bancos:
1. Acesse **Financeiro > Conciliação Bancária > Importar Extrato**.
2. Faça o upload do arquivo `.OFX` baixado do internet banking (Banco do Brasil, Caixa, etc.).
3. O ONGSYS cruzará as datas e valores automáticos. Para os itens não identificados, faça a associação manual com a respectiva conta a pagar lançada.

### 3. Emissão de Relatório de Prestação de Contas
Para Auditoria ou Prestação de Contas de Convênios:
1. Acesse **Relatórios > Financeiro > Demonstrativo por Centro de Custo**.
2. Filtre pelo período desejado e selecione o **Centro de Custo** do projeto financiador.
3. Exporte em formato PDF ou Excel para envio.

---
*Última atualização: Julho de 2026.*
