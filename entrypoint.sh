#!/bin/sh

# Sanitiza a variável SMTP_HOST se ela contiver protocolo (http/https) ou barra final
if [ -n "$SMTP_HOST" ]; then
  # Remove "http://" ou "https://"
  SMTP_HOST=$(echo "$SMTP_HOST" | sed -e 's|^https\?://||')
  # Remove a barra final "/" se existir
  SMTP_HOST=$(echo "$SMTP_HOST" | sed -e 's|/$||')
  export SMTP_HOST
fi

# Executa o servidor principal do Wiki.js
exec node /wiki/server
