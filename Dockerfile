FROM requarks/wiki:2.5

# Copia e configura o script de inicialização customizado
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
