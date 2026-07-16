---
title: prompt_ia
description: 
published: true
date: 2026-07-15T21:49:24.867Z
tags: 
editor: markdown
dateCreated: 2026-07-15T00:40:53.770Z
---

# Prompt de Contexto e Regras para Inteligência Artificial (CDC Wiki)

Este arquivo fornece o contexto técnico unificado e regras de comportamento para assistentes de inteligência artificial que atuam no repositório CDC Wiki. O objetivo é evitar repetição de explicações contextuais e garantir conformidade rígida com os padrões operacionais do CDC.

---

## System Context (Contexto Técnico do Projeto)

- **Projeto:** CDC Wiki
- **Objetivo:** Base de conhecimento interna da ONG, baseada no Wiki.js.
- **Tecnologias principais:** Node.js, PostgreSQL (16.4-alpine), Docker, Docker Compose, Nginx (Proxy externo), Bash (Scripts de backup).
- **Estrutura de Diretórios relevante:**
  - `/` : Arquivos de infraestrutura Docker (`Dockerfile`, `docker-compose.yml`, `entrypoint.sh`), `.env.example`, `.gitignore`, `ajuda.txt`.
  - `/docs/` : Documentação técnica padronizada.
  - `/data/postgres_data/` : Volume persistente local reservado para os arquivos físicos do banco PostgreSQL (ignorado pelo Git).
- **Ambientes:** 
  - Desenvolvimento (local): `http://localhost:3009`
  - Produção: `https://wiki.<DOMINIO_DO_PROJETO>`
- **Comunicação interna:** Integração com Mattermost para notificação de deploy, alertas de erros e status das rotinas diárias de backup.

---

## Restrições Obrigatórias

- **Sem `:latest`:** Nunca utilize a tag `:latest` em imagens oficiais no `docker-compose.yml`. Todas as imagens devem ser pinadas em versões estáveis (`postgres:16.4-alpine`, `requarks/wiki:2.5`).
- **Segurança Máxima:** Jamais expor senhas reais, tokens de API ou URLs de webhooks reais do Mattermost em códigos, scripts, README ou documentos.
- **Independência de Alertas:** Falhas no envio de notificações para o Mattermost não devem paralisar processos essenciais (como scripts de backup ou deploy). O fluxo deve prosseguir e registrar os erros no log.
- **Portas e Redes:** O PostgreSQL não publica portas no host para garantir isolamento e segurança lógica.
- **Preservação de Dados:** Nunca proponha comandos destrutivos de volumes (`docker compose down -v`) sem emitir avisos claros sobre perda de dados e fornecer opções de backup prévio.

---

## Regras para Respostas da IA

1. **Investigar antes de Codificar:** Sempre leia a estrutura dos arquivos existentes utilizando ferramentas de leitura antes de propor alterações.
2. **Código Completo e Executável:** Entregar trechos de códigos inteiros, prontos para copiar e colar. Não utilize reticências (`...`) para ocultar lógica ou sugerir que a equipe "continue igual".
3. **Uso Estrito de Placeholders:** Utilize apenas a lista de placeholders padrão (`<DB_PASSWORD>`, `<MATTERMOST_WEBHOOK_URL>`) em exemplos de configurações.
4. **Impacto Documental:** Sempre que sugerir modificações de infraestrutura, lembre o usuário de atualizar os respectivos arquivos em `docs/` e o `.env.example` se variáveis de ambiente novas forem criadas.

---

## Prompts Rápidos (Receitas Reutilizáveis)

Abaixo estão instruções estruturadas para guiar a IA na realização de tarefas operacionais recorrentes:

---

### Receita 1: Diagnóstico de Erro em Contêiner
- **Contexto:** Um container está falhando ao subir ou apresentando comportamento instável.
- **Objetivo:** Identificar o gargalo ou erro de sintaxe/configuração.
- **Restrições:** Propor comandos não destrutivos e com leitura de logs em tempo real.
- **Saída Esperada:** Lista de comandos Docker CLI ordenados por prioridade e possíveis causas comuns.
- **Documentos a Revisar:** `docs/troubleshooting.md`.

---

### Receita 2: Criar Rotina de Backup Personalizada
- **Contexto:** Necessidade de adicionar novos diretórios no escopo do backup criptografado do host.
- **Objetivo:** Modificar o script `backup.sh` de forma segura.
- **Restrições:** Usar `set -Eeuo pipefail`, tratamento com `trap` e garantir criptografia simétrica com GPG.
- **Saída Esperada:** Bloco de script Bash modificado e comando de teste.
- **Documentos a Revisar:** `docs/politica_backup.md`.

---

### Receita 3: Analisar Logs e Higienizar Saída
- **Contexto:** Logs do banco de dados ou da aplicação precisam ser anexados a um Postmortem.
- **Objetivo:** Extrair logs relevantes e sanitizar dados sigilosos.
- **Restrições:** Utilizar expressões regulares (regex) via `sed` ou comandos rápidos para ocultar senhas, logins ou tokens.
- **Saída Esperada:** Comando para filtrar os logs e modelo higienizado resultante.
- **Documentos a Revisar:** `docs/postmortem.md`.

---

### Receita 4: Testar Integração com Mattermost
- **Contexto:** Validar se a VPS consegue disparar notificações com sucesso após alterações de rede ou proxy.
- **Objetivo:** Executar disparo HTTP via `curl` seguro.
- **Restrições:** Não expor o token no shell do bash. Utilizar variáveis ambientais pré-carregadas.
- **Saída Esperada:** Comando completo utilizando o placeholder `<MATTERMOST_WEBHOOK_URL>`.
- **Documentos a Revisar:** `docs/ajuda_infra.md`.

---

### Receita 5: Preparação de Janela de Manutenção e Migração
- **Contexto:** Transferência de servidor VPS agendada.
- **Objetivo:** Guiar a equipe na execução sequencial e checklists.
- **Restrições:** Garantir a execução do dump do banco PostgreSQL usando compactação resiliente e checagem de hashes SHA-256.
- **Saída Esperada:** Cronograma de execução em markdown contendo os comandos executáveis no terminal de origem e destino.
- **Documentos a Revisar:** `docs/migration_guide.md` e `docs/estrategia_execucao.md`.

---
Última revisão: 2026-07-13
Responsável pela revisão: Antigravity
Motivo da revisão: Inicialização do arquivo de contexto para uso de Inteligência Artificial
