#!/bin/sh

# Sanitiza a variável SMTP_HOST se ela contiver protocolo (http/https) ou barra final
if [ -n "$SMTP_HOST" ]; then
  # Remove "http://" ou "https://"
  SMTP_HOST=$(echo "$SMTP_HOST" | sed -e 's|^https\?://||')
  # Remove a barra final "/" se existir
  SMTP_HOST=$(echo "$SMTP_HOST" | sed -e 's|/$||')
  export SMTP_HOST
fi

# Repassa a execução para o entrypoint oficial do Wiki.js para que ele gere o config.yml corretamente
exec docker-entrypoint.sh node server
