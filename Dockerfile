FROM requarks/wiki:2.5

# Altera temporariamente para root para permitir cópia e permissões
USER root

# Copia o script para o diretório da aplicação e define proprietário/permissão
COPY --chown=node:node entrypoint.sh /wiki/entrypoint.sh
RUN chmod +x /wiki/entrypoint.sh

# Retorna para o usuário não-root padrão do contêiner (node)
USER node

ENTRYPOINT ["/wiki/entrypoint.sh"]
