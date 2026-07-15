---
title: politica_backup
description: 
published: true
date: 2026-07-15T01:00:23.835Z
tags: 
editor: markdown
dateCreated: 2026-07-15T00:40:48.613Z
---

# Política de Backup e Restauração (CDC Wiki)

Este documento define as regras, frequências, responsabilidades e procedimentos para backup e recuperação de desastres do ecossistema CDC Wiki.

---

## Estratégia 3-2-1

Seguimos a metodologia clássica de redundância de dados:
- **3 Cópias dos Dados:** Manter pelo menos 1 cópia de produção ativa e 2 backups independentes.
- **2 Mídias Diferentes:** Armazenar os backups em sistemas físicos ou lógicos distintos (ex: armazenamento local na VPS e armazenamento em nuvem externa/objeto).
- **1 Cópia Offsite (Geograficamente Separada):** Pelo menos 1 cópia dos backups deve ser enviada para fora da rede física da VPS de produção para proteção contra incidentes catastróficos no provedor.

---

## Escopo do Backup

### O que deve ser incluído (Backup Obrigatório):
- **Banco de Dados (PostgreSQL):** Tabelas de páginas, logs de revisões, usuários, configurações de autenticação e blobs de mídia.
- **Configurações:** Arquivos de variáveis de ambiente (`.env`) e configurações do Nginx associadas.
- **Scripts Operacionais:** Scripts de automação de backup, arquivos de cron e configurações de inicialização.

### O que NÃO deve ser incluído (Evitar Desperdício de Armazenamento):
- Caches temporários de requisições ou páginas.
- Arquivos de sessão expirados dos usuários.
- Arquivos de logs descartáveis de depuração do Docker.
- Imagens Docker locais e volumes órfãos (podem ser reconstruídos a partir do código do repositório).

---

## Frequência e Métricas (RPO e RTO)

- **Frequência dos Backups:** Diário (executado automaticamente às 03:00 UTC).
- **Retenção:** 30 dias para os pacotes diários; 6 meses para backups mensais consolidados.
- `<TODO: VALIDAR RPO E RTO COM O RESPONSAVEL PELO NEGOCIO>` (definir se a tolerância de perda de dados e tempo de restauração atual atende as demandas críticas).

---

## Script Automatizado de Backup (`backup.sh`)

Abaixo está o script oficial em Bash utilizado para rotinas de backup. Salve-o no host como `backup.sh`. Ele utiliza tratamento de sinal `trap` para limpar arquivos residuais em caso de erros e envia notificações ao Mattermost.

```bash
#!/usr/bin/env bash

# Configura regras estritas do shell para falhar rapidamente em caso de erros
set -Eeuo pipefail

# Obtém o diretório do script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

# Define variáveis locais temporárias
TMP_DIR="/tmp/wiki_backup_$$"
DATE_SUFFIX="$(date +%Y%m%d_%H%M%S)"
BACKUP_FILENAME="backup_wiki_${DATE_SUFFIX}.tar.gz"

# Função executada em caso de erros ou sinal de saída (Limpeza garantida)
cleanup() {
    local exit_code=$?
    echo "[INFO] Executando rotina de limpeza temporaria..."
    rm -rf "${TMP_DIR}"
    echo "[INFO] Limpeza concluida. Codigo de saida: ${exit_code}"
    exit "${exit_code}"
}
trap cleanup EXIT SIGINT SIGTERM

# Envio de alertas ao Mattermost
notify_mattermost() {
    local message="$1"
    if [ "${MATTERMOST_ENABLED:-false}" = "true" ] && [ -n "${MATTERMOST_WEBHOOK_URL:-}" ]; then
        echo "[INFO] Enviando notificacao ao Mattermost..."
        curl --fail --silent --show-error --max-time "${MATTERMOST_TIMEOUT_SECONDS:-10}" \
            -X POST -H "Content-Type: application/json" \
            -d "{\"text\": \"${message}\"}" \
            "${MATTERMOST_WEBHOOK_URL}" || echo "[WARNING] Falha ao enviar alerta ao Mattermost. O backup continuou."
    fi
}

echo "[INFO] Iniciando rotina de backup do CDC Wiki..."

# 1. Carregar configurações
if [ -f "${SCRIPT_DIR}/.env" ]; then
    # Exporta variáveis sem incluir comentários
    export $(grep -v '^#' "${SCRIPT_DIR}/.env" | xargs)
else
    echo "[ERROR] Arquivo .env nao localizado no diretorio do script."
    exit 1
fi

# Valida variáveis cruciais
if [ -z "${DB_PASS:-}" ] || [ -z "${BACKUP_DESTINATION:-}" ]; then
    echo "[ERROR] Variaveis obrigatorias DB_PASS ou BACKUP_DESTINATION nao definidas."
    exit 1
fi

# 2. Criar diretório temporário
mkdir -p "${TMP_DIR}"
mkdir -p "${BACKUP_DESTINATION}"

# Dispara alerta de início de backup
notify_mattermost "[INFO] Rotina de backup do CDC Wiki iniciada para o ambiente ${APP_ENV:-production}."

# 3. Exportar banco PostgreSQL de forma segura (sem expor senha no CLI)
echo "[INFO] Executando dump do banco de dados..."
docker compose exec -e PGPASSWORD="${DB_PASS}" db pg_dump -U "${DB_USER:-wiki}" -h localhost -d "${DB_NAME:-wikidb}" -F c -b -f /var/lib/postgresql/data/wikidb_temp.backup

# Move o backup de dentro do volume para nossa pasta temporária
mv "${SCRIPT_DIR}/data/postgres_data/wikidb_temp.backup" "${TMP_DIR}/wikidb.backup"

# 4. Compactar dump e configurações
echo "[INFO] Compactando arquivos..."
tar -czf "${TMP_DIR}/${BACKUP_FILENAME}" -C "${TMP_DIR}" wikidb.backup -C "${SCRIPT_DIR}" .env.example docker-compose.yml Dockerfile

# 5. Criptografar arquivo compactado (GPG Simétrico)
# Nota: Requer arquivo de passphrase configurado no host
if [ -f "${GPG_PASSPHRASE_FILE:-}" ]; then
    echo "[INFO] Criptografando pacote de backup..."
    gpg --batch --yes --passphrase-file "${GPG_PASSPHRASE_FILE}" \
        -c -o "${BACKUP_DESTINATION}/${BACKUP_FILENAME}.gpg" "${TMP_DIR}/${BACKUP_FILENAME}"
    
    # Gera checksum SHA-256 do arquivo criptografado final
    sha256sum "${BACKUP_DESTINATION}/${BACKUP_FILENAME}.gpg" > "${BACKUP_DESTINATION}/${BACKUP_FILENAME}.gpg.sha256"
    
    # 6. Aplicar política de retenção (remover arquivos mais antigos que X dias)
    echo "[INFO] Aplicando retencao de backups..."
    find "${BACKUP_DESTINATION}" -name "backup_wiki_*.gpg*" -mtime +"${BACKUP_RETENTION_DAYS:-30}" -delete
    
    # Notifica sucesso
    FILE_SIZE=$(du -sh "${BACKUP_DESTINATION}/${BACKUP_FILENAME}.gpg" | cut -f1)
    notify_mattermost "[OK] Backup do CDC Wiki concluido com sucesso!\n- Arquivo: \`${BACKUP_FILENAME}.gpg\`\n- Tamanho: \`${FILE_SIZE}\`\n- Destino: \`${BACKUP_DESTINATION}\`"
else
    echo "[ERROR] Arquivo de passphrase do GPG nao encontrado. Criptografia falhou."
    notify_mattermost "[CRITICAL] Backup do CDC Wiki falhou: erro na etapa de criptografia GPG."
    exit 1
fi

echo "[INFO] Processo de backup finalizado com sucesso."
```

---

## Arquivo de Configuração do Backup

O script de backup lê diretamente o arquivo `.env` do diretório do projeto. Seguem as variáveis necessárias para a execução:
```env
BACKUP_PROJECT_NAME=cdc-wiki
BACKUP_ENVIRONMENT=production
BACKUP_DESTINATION=/home/vier/backups/wiki
BACKUP_RETENTION_DAYS=30
GPG_PASSPHRASE_FILE=/home/vier/.gpg_passphrase
```

---

## Segredos e Criptografia

- **Passphrase do GPG:** A chave simétrica para criptografar os backups deve ser salva em `/home/vier/.gpg_passphrase` no host (fora do diretório versionado pelo Git).
- **Proteção do Arquivo de Passphrase:** O arquivo deve pertencer exclusivamente ao usuário executor do script e ter permissões restritas:
  ```bash
  chmod 600 /home/vier/.gpg_passphrase
  ```

---

## Alertas no Mattermost (Tipos e Formato)

Os alertas ajudam a identificar falhas de disco cheio, permissões ou senha inválida. Formato padrão enviado:

- **Alerta de Falha Crítica:**
  ```text
  [CRITICAL] Falha na execução de backup do CDC Wiki!
  Ambiente: Produção
  Etapa: Dump do Banco de Dados PostgreSQL
  Status: Falha na criação do arquivo. Verifique o espaço em disco ou credenciais.
  ```
- **Alerta de Sucesso:**
  ```text
  [OK] Backup concluído com sucesso.
  Arquivo: backup_wiki_20260713_030000.tar.gz.gpg
  Tamanho: 12MB
  ```

---

## Roteiro de Restauração (Restore Guide)

Caso seja necessária a recuperação rápida do Wiki.js a partir de um backup criptografado, siga estes passos:

### Passo 1: Preparar ambiente limpo
Suba a infraestrutura Docker limpa do Wiki.js (conforme `docker-compose.yml` da raiz).

### Passo 2: Localizar e descriptografar o backup
1. Identifique o backup desejado e execute a descriptografia informando a passphrase:
   ```bash
   gpg --batch --passphrase-file /home/vier/.gpg_passphrase \
       -d -o backup_recuperado.tar.gz backup_wiki_20260713_030000.tar.gz.gpg
   ```
2. Descompacte o pacote recém-descriptografado:
   ```bash
   tar -xvzf backup_recuperado.tar.gz
   ```

### Passo 3: Restaurar o banco de dados PostgreSQL
1. Envie o dump do banco (`wikidb.backup`) para dentro do volume local do PostgreSQL:
   ```bash
   mv wikidb.backup ./data/postgres_data/wikidb_dump.backup
   ```
2. Carregue as variáveis de ambiente:
   ```bash
   export $(grep -v '^#' .env | xargs)
   ```
3. Execute a restauração do dump dentro do contêiner `db`:
   ```bash
   docker compose exec -e PGPASSWORD="$DB_PASS" db pg_restore -U "${DB_USER:-wiki}" -d "${DB_NAME:-wikidb}" --clean --verbose /var/lib/postgresql/data/wikidb_dump.backup
   ```
4. Remova o arquivo de dump temporário para liberar espaço:
   ```bash
   rm -f ./data/postgres_data/wikidb_dump.backup
   ```

### Passo 4: Reiniciar os serviços
Reinicie o Wiki.js para limpar conexões e forçar o reload do banco:
```bash
docker compose restart wiki
```

---

## Validação Pós-Restore

Após finalizar a restauração, valide os seguintes itens na interface web:
- [ ] O login de administradores e usuários funciona corretamente.
- [ ] A listagem de páginas recentes condiz com o estado real do backup.
- [ ] O upload de novas mídias e imagens funciona no editor visual (validação de permissões de escrita).
- [ ] Os logs do contêiner `wiki-app` não apresentam exceções de banco de dados ou queries corrompidas.

---

## Teste Periódico de Backup e Restauração

Recomenda-se realizar o teste de restore trimestralmente em ambiente isolado (sandbox), registrando o log conforme o padrão abaixo:

| Data do Teste | Arquivo de Backup Testado | Tempo de Restauração (RTO observado) | Integridade Confirmada | Responsável técnico |
| :--- | :--- | :--- | :--- | :--- |
| AAAA-MM-DD | `backup_wiki_YYYYMMDD.tar.gz.gpg` | XX minutos | Sim / Não | <SSH_USER> |

---
Última revisão: 2026-07-13
Responsável pela revisão: Antigravity
Motivo da revisão: Inicialização da política de backup criptografada e rotinas de restauração
