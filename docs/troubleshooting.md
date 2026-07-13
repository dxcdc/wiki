# Guia de Troubleshooting e Diagnóstico Rápido (CDC Wiki)

Este documento centraliza as ocorrências de problemas técnicos mais comuns no ambiente do Wiki.js e banco de dados PostgreSQL, divididos por categoria lógica.

---

## 1. Categoria: Containers e Docker

### Ocorrência 1.1: Container `wiki-app` reiniciando constantemente (Restart Loop)
- **Sintoma:** O comando `docker compose ps` mostra o status do container `wiki-app` como `Restarting`.
- **Possível Causa:** Falha de conexão inicial com o banco de dados ou variáveis de ambiente incorretas.
- **Diagnóstico:** Execute o comando de inspeção de logs:
  ```bash
  docker compose logs wiki
  ```
  Procure por erros como `Connection refused` ou `Invalid database credentials`.
- **Correção:** Verifique se as variáveis `DB_USER`, `DB_PASS` e `DB_NAME` no arquivo `.env` batem exatamente com as configurações declaradas para o container do banco PostgreSQL.
- **Validação:** Inicie o serviço e verifique se o status mudou para `Up`:
  ```bash
  docker compose ps
  ```
- **Prevenção:** Utilizar a cláusula `depends_on` com `condition: service_healthy` no `docker-compose.yml` para assegurar que a aplicação só inicie após o banco estar pronto para receber conexões.

---

### Ocorrência 1.2: Porta 3000 já ocupada no host (Collision)
- **Sintoma:** O Docker Compose falha ao subir o container com erro `bind: address already in use`.
- **Possível Causa:** Outro serviço na VPS está utilizando a porta 3000.
- **Diagnóstico:** Verifique qual processo está escutando na porta 3000 do host:
  ```bash
  sudo ss -tulpn | grep :3000
  ```
- **Correção:** Altere a porta mapeada externamente no `docker-compose.yml` (ex: de `"3000:3000"` para `"3001:3000"`) ou mate o processo conflitante se for órfão.
- **Validação:** Suba o contêiner e certifique-se de que iniciou com sucesso.

---

### Ocorrência 1.3: Falha de montagem de volume ou falta de espaço
- **Sintoma:** O contêiner de banco falha ao iniciar ou relata erros de gravação em disco.
- **Possível Causa:** O disco da VPS está cheio ou o diretório local `./data/db` está sem espaço.
- **Diagnóstico:** Verifique o espaço em disco da VPS:
  ```bash
  df -h
  ```
- **Correção:** Execute o comando prune do Docker para liberar espaço de imagens antigas não utilizadas:
  ```bash
  docker system prune -a --volumes
  ```
- **Validação:** Reinicie os contêineres e verifique se erros de gravação desapareceram.

---

## 2. Categoria: Permissões de Arquivos

### Ocorrência 2.1: Erro de permissão de escrita no volume do banco (Permission Denied)
- **Sintoma:** Logs do PostgreSQL mostram `chown: database directory /var/lib/postgresql/data: Permission denied` ou falha de escrita.
- **Possível Causa:** O proprietário do diretório host `./data/db` não corresponde ao ID do usuário interno do PostgreSQL (UID 999).
- **Diagnóstico:** Liste o proprietário atual da pasta no host:
  ```bash
  ls -ld ./data/db
  ```
- **Correção:** **NUNCA execute `chmod 777`**. Ajuste o proprietário (chown) de forma cirúrgica para o usuário correto ou adicione permissão de escrita para o grupo:
  ```bash
  sudo chown -R 999:999 ./data/db
  sudo chmod -R 700 ./data/db
  ```
- **Validação:** Inicie o banco e verifique se as tabelas e arquivos de locks foram gerados.

---

## 3. Categoria: Banco de Dados PostgreSQL

### Ocorrência 3.1: Conexão recusada ao PostgreSQL
- **Sintoma:** O Wiki.js apresenta tela de erro de banco ou loops de reinicialização.
- **Possível Causa:** O host configurado (`DB_HOST`) está incorreto ou a rede interna do docker não está comunicando.
- **Diagnóstico:** Verifique se as redes do Docker Compose estão declaradas e se os dois serviços compartilham a mesma rede (`wiki-net`).
- **Correção:** Garanta que `DB_HOST` está configurado como `db` (nome do serviço no docker-compose) e não `localhost` ou `127.0.0.1` (que apontaria para dentro do próprio container da aplicação).
- **Validação:** Teste a resolução DNS interna entre containers:
  ```bash
  docker compose exec wiki ping db -c 2
  ```

---

### Ocorrência 3.2: Collation ou Charset Incompatíveis
- **Sintoma:** Erros SQL ao rodar queries de busca com caracteres especiais no Wiki.js.
- **Possível Causa:** Banco criado com charset diferente de UTF-8.
- **Diagnóstico:** Verifique as configurações de idioma do PostgreSQL:
  ```bash
  docker compose exec db psql -U wiki -d wikidb -c "SHOW server_encoding;"
  ```
- **Correção:** O container oficial postgres por padrão inicializa em `UTF8`. Se estiver em outro formato, recrie o banco ou execute o script de ajuste:
  ```sql
  ALTER DATABASE wikidb OWNER TO wiki;
  ```
- **Validação:** Teste a exibição correta de acentuações na interface do wiki.

---

## 4. Categoria: Aplicação e Assets (Wiki.js)

### Ocorrência 4.1: Falha no upload de imagens/arquivos grandes
- **Sintoma:** Erros do tipo `Payload Too Large` (HTTP 413) ao tentar subir arquivos de mídia no editor.
- **Possível Causa:** Limitação de tamanho máximo de upload no Proxy Reverso do host (ex: Nginx).
- **Diagnóstico:** Verifique os logs de erro do Nginx no host (`/var/log/nginx/error.log`).
- **Correção:** Edite a configuração do bloco do servidor Nginx no host e aumente o limite de requisições:
  ```nginx
  client_max_body_size 50M;
  ```
  Recarregue a configuração do Nginx:
  ```bash
  sudo nginx -s reload
  ```
- **Validação:** Tente fazer o upload do arquivo novamente através do editor visual.

---

### Ocorrência 4.2: Quebra de layout ou estilos SCSS/CSS não renderizando
- **Sintoma:** Interface web do Wiki.js aparece desconfigurada ou sem folhas de estilo aplicadas.
- **Possível Causa:** Cache de assets do navegador corrompido ou falha na geração de arquivos estáticos no container.
- **Diagnóstico:** Abra as ferramentas de desenvolvedor do navegador (F12) e verifique se há erros 404 para arquivos `.css`.
- **Correção:** Limpe o cache de assets nas opções de administração do Wiki.js ou force um reinício limpo limpando caches locais do host.
- **Validação:** Atualize a página com `Ctrl + F5`.

---

## 5. Categoria: Configurações de E-mail (SMTP)

### Ocorrência 5.1: Falha no envio de e-mails de recuperação de senha
- **Sintoma:** Erros de timeout ou falha de conexão SMTP nos logs do Wiki.js ao solicitar recuperação de conta.
- **Possível Causa:** Porta SMTP bloqueada no firewall da VPS ou criptografia incorreta configurada.
- **Diagnóstico:** Teste a conectividade com o servidor SMTP a partir da VPS:
  ```bash
  nc -zv <SMTP_HOST> 587
  ```
- **Correção:** Verifique a porta do servidor SMTP (usar 587 para STARTTLS ou 465 para SSL/TLS explícito) no painel administrativo do Wiki.js e certifique-se de que a VPS permite tráfego de saída nessas portas.
- **Validação:** Dispare um e-mail de teste pelo painel de administração do Wiki.js.

---

## 6. Categoria: Integração e Notificações (Mattermost)

### Ocorrência 6.1: Alertas automáticos não aparecem no Mattermost
- **Sintoma:** Scripts operacionais são executados, mas nenhuma notificação chega ao canal.
- **Possível Causa:** URL de webhook inválida, desativada ou formato de payload JSON incompatível.
- **Diagnóstico:**
  - Valide se `MATTERMOST_ENABLED` está como `true` no `.env`.
  - Verifique os logs do script de backup ou da aplicação para capturar o código HTTP de erro da requisição POST.
- **Correção:** 
  - **HTTP 400 (Bad Request):** Indica que a estrutura do JSON enviada está fora do padrão exigido pelo Mattermost. Valide as aspas e formatação do payload.
  - **HTTP 404 (Not Found):** URL do Webhook está incorreta ou o token expirou. Obtenha um novo webhook de entrada no Mattermost.
  - **HTTP 403 (Forbidden):** Permissões insuficientes na integração.
- **Validação:** Execute o comando de teste manual (usando a variável para não expor a URL no shell):
  ```bash
  export $(grep -v '^#' .env | xargs)
  curl -X POST -H "Content-Type: application/json" -d '{"text":"Teste manual de depuração."}' "$MATTERMOST_WEBHOOK_URL"
  ```
- **Segurança:** Nunca publique a URL real nos logs de erro. Use mascaramento em caso de falhas.

---

## 7. Gerenciamento e Análise de Logs

Use estes comandos para monitorar e extrair erros de forma rápida no servidor host:

- **Acompanhar logs de erros em tempo real (Wiki.js):**
  ```bash
  docker compose logs -f wiki | grep -iE 'error|warn|fail|exception'
  ```
- **Localizar logs históricos do PostgreSQL:**
  Os logs do banco de dados ficam persistidos dentro do volume do PostgreSQL no host, em `./data/db/log/` ou diretamente na saída de logs do docker:
  ```bash
  docker compose logs -f db
  ```
- **Sanitização Básica de Logs:**
  Ao compartilhar logs de erros em chamados ou no Mattermost, garanta que senhas e webhooks foram removidos. Exemplo de filtro rápido:
  ```bash
  docker compose logs wiki | sed -E 's/pass(word)?=[^ &]+/password=******/'
  ```

---

## 8. Checklist de Emergência (Indisponibilidade Crítica)

Siga rigorosamente estes passos em ordem para diagnosticar e mitigar uma queda do serviço Wiki.js:

1. **Verificar espaço em disco do servidor VPS:**
   ```bash
   df -h
   ```
2. **Verificar memória RAM livre disponível:**
   ```bash
   free -h
   ```
3. **Verificar se os contêineres do projeto estão de pé:**
   ```bash
   docker compose ps
   ```
4. **Verificar os status dos logs de erro recentes:**
   ```bash
   docker compose logs --tail=100
   ```
5. **Verificar se as portas de escuta estão ativas no host:**
   ```bash
   sudo ss -tulpn | grep -E '3000|80|443'
   ```
6. **Verificar a integridade do banco de dados PostgreSQL:**
   ```bash
   docker compose exec db pg_isready -U wiki -d wikidb
   ```
7. **Testar conectividade local com a porta do Wiki.js:**
   ```bash
   curl -I http://localhost:3000
   ```
8. **Testar disparo de alertas para comunicação interna:**
   Testar envio de status para o canal de alertas no Mattermost.
9. **Registrar Ações:** Anotar todas as ações tomadas durante o processo de mitigação de erro para documentar no Postmortem.

---
Última revisão: 2026-07-13
Responsável pela revisão: Antigravity
Motivo da revisão: Inicialização do repositório de troubleshooting rápido do Wiki.js
