---
title: plano_personalizacao
description: 
published: true
date: 2026-07-15T21:49:21.310Z
tags: 
editor: markdown
dateCreated: 2026-07-15T00:40:46.775Z
---

# Plano de Personalização e Integração (CDC Wiki)

Este documento atua como um guia estratégico e roteiro de implementação para futuras personalizações estéticas, integrações com serviços externos e automações adicionais no Wiki.js do CDC.

---

## Índice do Plano

1. [Identidade Visual e Branding](#1-identidade-visual-e-branding)
2. [Sincronização Bidirecional com Git (Git Storage)](#2-sincronizacao-bidirecional-com-git-git-storage)
3. [Integração de Armazenamento de Mídias (S3 / MinIO)](#3-integracao-de-armazenamento-de-midias-s3-minio)
4. [Autenticação Centralizada e SSO (OAuth2 / Google / GitHub)](#4-autenticacao-centralizada-e-sso-oauth2-google-github)
5. [Alertas Avançados e Webhooks (Mattermost)](#5-alertas-avancados-e-webhooks-mattermost)
6. [Mecanismos de Busca Avançada (Meilisearch / Elasticsearch)](#6-mecanismos-de-busca-avancada-meilisearch-elasticsearch)
7. [Métricas de Uso e Análise de Tráfego](#7-metricas-de-uso-e-analise-de-trafego)
8. [Agente de IA Conversacional (Mattermost + Dify + Gemini)](#8-agente-de-ia-conversacional-mattermost-dify-gemini)

---

## 1. Identidade Visual e Branding

### Objetivo:
Alinhar a aparência do Wiki.js com a marca oficial do CDC para criar um ambiente corporativo coeso e amigável.

### Ações Técnicas:
- **Logotipo e Favicon:** Substituir as imagens padrões nas opções do painel administrativo (`Administração -> Geral -> Aparência`).
- **Paleta de Cores Customizada:** Injetar regras de CSS personalizadas na seção de customização de cabeçalho do Wiki.js para forçar as cores da marca (Laranja CDC e Cinza Escuro):
  ```css
  /* Exemplo de Injeção de CSS para cores CDC */
  :root {
    --theme-primary: #FF720D;
    --theme-primary-hover: #E05F00;
    --theme-dark-bg: #1E1E1E;
  }
  ```
- **Customização do Tema:** Habilitar ou forçar o tema escuro padrão para toda a equipe, mantendo a consistência visual com os outros sistemas do CDC.

---

## 2. Sincronização Bidirecional com Git (Git Storage)

### Objetivo:
Aproveitar o recurso nativo do Wiki.js para que todas as páginas criadas ou alteradas sejam salvas automaticamente como arquivos `.md` (Markdown) em um repositório privado do GitHub.

### Como funciona:
1. O usuário edita a página na interface Web.
2. O Wiki.js atualiza o banco de dados e cria/atualiza o arquivo `.md` correspondente.
3. De tempos em tempos (ou de forma síncrona), o Wiki.js realiza o `git push` de forma automática para o GitHub.
4. Caso um arquivo `.md` seja editado e sofrer `git push` direto no GitHub, o Wiki.js fará o `git pull` e sincronizará a alteração no site automaticamente.

### Requisitos:
- Criação de uma chave de deploy (Deploy Key) ou token de acesso pessoal (PAT) no repositório GitHub do CDC.
- Ativação do módulo **Git** em `Administração -> Armazenamento -> Módulos de Armazenamento`.

---

## 3. Integração de Armazenamento de Mídias (S3 / MinIO)

### Objetivo:
Evitar que imagens, vídeos e arquivos PDF enviados pelos usuários sobrecarreguem o banco de dados PostgreSQL, movendo a persistência física desses arquivos para um armazenamento de objetos externo.

### Ações Técnicas:
- **Provedor:** Utilizar um serviço de Storage compatível com AWS S3 (como DigitalOcean Spaces, Backblaze B2 ou MinIO hospedado na própria infraestrutura do CDC).
- **Módulo:** Configurar o driver **S3** no painel administrativo (`Administração -> Armazenamento -> Módulos de Armazenamento`), informando as chaves de API, o nome do bucket e a região.

---

## 4. Autenticação Centralizada e SSO (OAuth2 / Google / GitHub)

### Objetivo:
Permitir que a equipe do CDC faça login no Wiki utilizando contas corporativas já existentes (como Google Workspace, GitHub ou servidor Keycloak interno), sem a necessidade de criar e gerenciar senhas locais.

### Módulos de Autenticação Disponíveis no Wiki.js:
- **Google OAuth2:** Login social simples usando e-mails `@cdc.org.br`.
- **GitHub:** Excelente para a equipe de desenvolvimento.
- **Keycloak / OpenID Connect (OIDC):** Ideal se a CDC implementar uma governança centralizada de identidades para todos os seus serviços (Moodle, Postal, ERPNext, Wiki).

---

## 5. Alertas Avançados e Webhooks (Mattermost)

### Objetivo:
Disparar mensagens em tempo real para os canais do Mattermost (`#alertas-wiki` ou `#wiki-atualizacoes`) toda vez que uma página for criada, atualizada ou excluída, facilitando a auditoria colaborativa das documentações.

### Roteiro de Implementação:
1. Criar um canal específico no Mattermost (ex: `#wiki-conteudo`).
2. Gerar uma URL de webhook de entrada no Mattermost para esse canal.
3. No painel de administração do Wiki.js, configurar o módulo de **Webhooks** apontando para a URL criada e marcando os gatilhos (triggers) de eventos de página desejados.

---

## 6. Mecanismos de Busca Avançada (Meilisearch / Elasticsearch)

### Objetivo:
Garantir buscas de alta velocidade, tolerância a erros de digitação (fuzzy search) e sugestões instantâneas para os usuários.

### Tecnologias:
- **PostgreSQL Full-Text (Padrão):** Bom para o início do projeto, sem custos adicionais de infraestrutura.
- **Meilisearch:** Extremamente rápido, leve e fácil de hospedar via Docker. Recomendado para o projeto no médio prazo.
- **Elasticsearch:** Extremamente robusto, ideal se a base de conhecimento crescer muito (milhares de artigos).

---

## 7. Métricas de Uso e Análise de Tráfego

### Objetivo:
Monitorar o uso do Wiki.js para saber quais artigos são mais lidos, quais termos são mais buscados sem retorno (gargalos de documentação) e o comportamento dos usuários.

### Integrações:
- Configurar injeção de script de análise na seção de cabeçalho (`HTML Head`) no painel administrativo do Wiki.js.
- **Plataformas Sugeridas:**
  - **Matomo / Plausible:** Soluções open-source focadas em privacidade que podem ser hospedadas diretamente em Docker na infraestrutura do CDC.
  - **Google Analytics:** Padrão de mercado para rastreamento de uso básico.

---

## 8. Agente de IA Conversacional (Mattermost + Dify + Gemini)

### Objetivo:
Permitir que os colaboradores consultem instantaneamente as diretrizes, procedimentos e manuais operacionais do CDC enviando perguntas em linguagem natural diretamente no chat corporativo (Mattermost), eliminando buscas manuais demoradas.

### Arquitetura de Integração:
1. **Dify (Container VPS):** Plataforma de orquestração de IA hospedada na VPS por Docker. Ele lê a pasta de Markdowns (`pt-br/`) da Wiki sincronizada pelo Git, realiza o fatiamento e a vetorização (busca semântica RAG) e gerencia as conversas.
2. **Google AI Studio (Gemini 1.5 Flash):** Motor de inteligência que analisa os documentos fornecidos pelo Dify e formula as respostas aos colaboradores.
3. **Mattermost Integration:** Gatilho de mensagens de saída (Outgoing Webhook) no chat direcionando para a API do Dify, e retorno das respostas via Webhook de entrada.

### Mecanismos de Controle de Uso e Segurança (Prevenção de Abuso):
Para evitar consumo excessivo de cotas da API, loops de chamados e cobranças surpresas no cartão, o sistema implementará as seguintes travas físicas:

* **Limitação de Requisições por Usuário (Dify Rate Limiting):**
  Configurar na interface do Dify uma cota diária por IP ou usuário do Mattermost. Exemplo: no máximo **10 perguntas por hora** ou **50 perguntas por dia** por colaborador.
* **Bloqueio de Gastos (Plano Gratuito Google):**
  Durante a fase de testes, o uso de chaves gratuitas do Google AI Studio impede fisicamente faturamentos indesejados. O limite é apenas de taxa de requisições por minuto (15 RPM). Caso excedido, a API temporariamente retorna um código HTTP 429 sem tarifação.
* **Teto Financeiro Rígido (Google Cloud):**
  Se for ativado o plano pago (Pay-as-you-go) para alta performance, será configurada uma cota orçamentária rígida no painel Google Cloud Console (ex: teto máximo de **R$ 10,00 mensais**), com o desligamento automático imediato do tráfego da API ao atingir 100% do valor.

