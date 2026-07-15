---
title: ajuda_infra
description: 
published: true
date: 2026-07-15T01:00:16.266Z
tags: 
editor: markdown
dateCreated: 2026-07-15T00:40:35.637Z
---

# Guia Técnico de Infraestrutura (CDC Wiki)

Este documento detalha o desenho técnico, arquitetura de rede, segurança e configurações lógicas do projeto CDC Wiki.

---

## Arquitetura atual

A arquitetura do CDC Wiki é executada sob contêineres Docker isolados, estruturada da seguinte forma:

- **Aplicação (Wiki.js):** Plataforma web escrita em Node.js rodando sob a imagem customizada `gttransformadigital/wiki:1.0` (derivada da oficial `requarks/wiki:2.5`).
- **Proxy Reverso (Host Externo):** Um servidor Nginx (ou Nginx Proxy Manager) rodando no host gerencia o tráfego externo HTTPS na porta 443, realiza o descarregamento SSL/TLS (Offloading) e encaminha o tráfego HTTP local para a porta 3009 (ou configurada via WIKI_PORT) da VPS.
- **Banco de Dados:** PostgreSQL (versão `16.4-alpine`) para armazenamento persistente de tabelas SQL de conteúdo.
- **Isolamento e Comunicação:** Contêineres compartilham uma rede de ponte Docker interna privada (`wiki-net`).
- **Persistência física:** Os dados do PostgreSQL são salvos localmente em `./data/postgres_data` no sistema de arquivos do host.

---

## Containers

O contêiner da aplicação é compilado localmente a partir de um `Dockerfile` que herda de `requarks/wiki:2.5` e copia o script `entrypoint.sh`. Esse script executa a higienização de URLs SMTP (removendo `https://` ou barras finais) antes de delegar a execução ao inicializador nativo da aplicação. Devido ao usuário de execução não-root padrão (`node`), o build alterna temporariamente para `root` para configurar as permissões de execução.

Abaixo está o arquivo `docker-compose.yml` de referência completo do projeto:

```yaml
services:
  wiki:
    image: gttransformadigital/wiki:1.0
    build:
      context: .
      dockerfile: Dockerfile
    container_name: wiki-app
    restart: always
    environment:
      DB_TYPE: postgres
      DB_HOST: ${DB_HOST:-db}
      DB_PORT: ${DB_PORT:-5432}
      DB_USER: ${DB_USER:-wiki}
      DB_PASS: ${DB_PASS}
      DB_NAME: ${DB_NAME:-wikidb}
    ports:
      - "${WIKI_PORT:-3009}:3000"
    depends_on:
      db:
        condition: service_healthy
    networks:
      - wiki-net

  db:
    image: postgres:16.4-alpine
    container_name: wiki-db
    restart: always
    environment:
      POSTGRES_USER: ${DB_USER:-wiki}
      POSTGRES_PASSWORD: ${DB_PASS}
      POSTGRES_DB: ${DB_NAME:-wikidb}
    volumes:
      - ./data/postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U $${POSTGRES_USER:-wiki} -d $${POSTGRES_DB:-wikidb}"]
      interval: 10s
      timeout: 5s
      retries: 5
    networks:
      wiki-net:
        aliases:
          - cdc-ezpoint_wiki-db

networks:
  wiki-net:
    driver: bridge
```

---

## Isolamento de rede

Para mitigar superfícies de ataque, implementamos o isolamento físico/virtual das portas:
- **Banco de Dados Isolado:** O PostgreSQL (`db`) **NÃO** expõe portas públicas no host (não possui a diretiva `ports` no docker-compose). Ele comunica-se exclusivamente com a aplicação Wiki.js através da rede bridge interna `wiki-net`.
- **Acesso Limitado:** O container `wiki` expõe por padrão a porta `3009` (ou a definida em `WIKI_PORT`) localmente no host. O Proxy Reverso do host intercepta o domínio externo e redireciona localmente para essa porta.

---

## `.env.example`

O arquivo `.env.example` define a estrutura necessária das variáveis de ambiente. Siga as diretrizes de segurança:
- Nunca comite o arquivo `.env` preenchido com dados reais.
- Mantenha o `.env` protegido com permissão mínima de leitura no host (`chmod 600 .env`).
- Execute a cópia inicial do template usando:
  ```bash
  cp .env.example .env
  ```

---

## Modelo genérico do `.env.example`

O template oficial do projeto está estruturado em `.env.example` na raiz:

```env
# Ambiente da aplicação
APP_ENV=development
APP_PORT=3000
APP_URL=http://localhost:3000

# Banco de dados
DB_TYPE=postgres
DB_HOST=db
DB_PORT=5432
DB_NAME=wikidb
DB_USER=wiki
DB_PASS=<DEFINIR_EM_AMBIENTE_SEGURO>

# E-mail (Opcional no Wiki.js)
SMTP_HOST=<SERVIDOR_SMTP>
SMTP_PORT=587
SMTP_USER=<USUARIO_SMTP>
SMTP_PASSWORD=<DEFINIR_EM_AMBIENTE_SEGURO>
SMTP_ENCRYPTION=starttls
SMTP_FROM_ADDRESS=<EMAIL_REMETENTE>
SMTP_FROM_NAME=<NOME_DO_PROJETO>

# Mattermost
MATTERMOST_ENABLED=false
MATTERMOST_WEBHOOK_URL=<URL_DO_WEBHOOK_MATTERMOST>
MATTERMOST_CHANNEL=<CANAL_DE_ALERTAS>
MATTERMOST_USERNAME=WikiBot
MATTERMOST_ICON_URL=<URL_PUBLICA_DO_ICONE>
MATTERMOST_TIMEOUT_SECONDS=10
```

---

## Integração com Mattermost

A integração para envio de alertas opera com as seguintes especificações técnicas:
- **Proteção do Webhook:** A variável `MATTERMOST_WEBHOOK_URL` contém o hash privado de integração e deve ser tratada como segredo de segurança máxima. Nunca a adicione em arquivos Git, capturas de tela ou logs de execução.
- **Timeout e Retentativas:** Configurado com tempo limite de resposta de 10 segundos (`MATTERMOST_TIMEOUT_SECONDS=10`) para evitar que scripts operacionais ou de backup fiquem travados (hanging) caso o Mattermost apresente indisponibilidade.
- **Tolerância a Falhas:** Caso a notificação do Mattermost falhe ou o serviço esteja offline, a execução principal (ex: rotina de backup) **deve prosseguir** e gerar o backup local normalmente, apenas registrando o erro do webhook nos arquivos de log.

---

## Teste do Mattermost

Para verificar a conectividade do webhook do Mattermost a partir do host sem expor a URL no histórico do shell Bash:

1. Carregue as variáveis a partir do `.env`:
   ```bash
   export $(grep -v '^#' .env | xargs)
   ```
2. Dispare o comando de teste usando a variável:
   ```bash
   curl --fail --silent --show-error --max-time "${MATTERMOST_TIMEOUT_SECONDS:-10}" \
     -X POST -H "Content-Type: application/json" \
     -d '{"text":"[INFO] Teste de integracao do CDC Wiki com o Mattermost realizado com sucesso."}' \
     "$MATTERMOST_WEBHOOK_URL"
   ```

---

## DNS e serviços externos

Abaixo estão os apontamentos de DNS necessários para a operação do CDC Wiki na VPS:

| Tipo | Nome | Destino ou valor | TTL | Finalidade |
| :--- | :--- | :--- | :--- | :--- |
| `A` | `wiki.<DOMINIO_DO_PROJETO>` | `<IP_DA_VPS_PRODUÇÃO>` | 3600 | Aponta o domínio público do Wiki.js para a VPS. |
| `CNAME` | `www.wiki.<DOMINIO_DO_PROJETO>` | `wiki.<DOMINIO_DO_PROJETO>` | 3600 | Redirecionamento alternativo padrão de tráfego. |

---

## Portas

Abaixo está o mapeamento lógico e físico das portas do serviço:

| Serviço | Porta interna | Porta externa | Protocolo | Exposição |
| :--- | :--- | :--- | :--- | :--- |
| `wiki-app` | 3000 | 3009 (ou WIKI_PORT) | TCP | Exposta localmente no host VPS. |
| `wiki-db` | 5432 | - | TCP | Exclusiva da rede bridge interna `wiki-net`. |
| Nginx (Host) | - | 80 / 443 | TCP | Acessível publicamente na Internet. |

---

## Inicialização e encerramento

Abaixo estão os comandos administrativos essenciais para gerenciamento dos containers:

- **Iniciar serviços em segundo plano (e compilar imagem local):**
  ```bash
  docker compose up -d --build
  ```
- **Parar os serviços (sem destruir volumes ou dados):**
  ```bash
  docker compose stop
  ```
- **Parar e remover os contêineres e redes associadas:**
  ```bash
  docker compose down
  ```
- **Visualizar status dos serviços e status de saúde (healthcheck):**
  ```bash
  docker compose ps
  ```
- **Acompanhar logs de execução em tempo real:**
  ```bash
  docker compose logs -f
  ```
- **Visualizar logs específicos do banco PostgreSQL:**
  ```bash
  docker compose logs -f db
  ```
- **Forçar reconstrução da imagem local sem cache:**
  ```bash
  docker compose build --no-cache wiki
  ```

---
Última revisão: 2026-07-13
Responsável pela revisão: Antigravity
Motivo da revisão: Inicialização do guia técnico de infraestrutura do Wiki.js
