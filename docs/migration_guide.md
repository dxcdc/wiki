---
title: migration_guide
description: 
published: true
date: 2026-07-15T21:49:20.148Z
tags: 
editor: markdown
dateCreated: 2026-07-15T00:40:43.742Z
---

# Guia de Migração e Acesso Seguro (CDC Wiki)

Este documento contém os procedimentos operacionais para acesso SSH seguro, diagnóstico do sistema e roteiro passo a passo para migração do Wiki.js entre servidores VPS.

---

## Acesso SSH seguro

O acesso ao servidor VPS da CDC deve seguir políticas rígidas de segurança, abolindo autenticação por senha em favor de chaves criptográficas.

### 1. Geração de Chave ED25519 Segura
Em seu computador local, gere um par de chaves usando o algoritmo ED25519 (mais seguro e rápido que RSA):
```bash
ssh-keygen -t ed25519 -a 100 -C "seu_email@exemplo.com" -f ~/.ssh/id_cdc_wiki
```
*Atenção: Sempre proteja sua chave com uma frase secreta (passphrase) robusta quando solicitado.*

### 2. Cópia da Chave Pública para a VPS
Envie sua chave pública para a VPS (substitua os placeholders pelas variáveis do seu ambiente):
```bash
ssh-copy-id -i ~/.ssh/id_cdc_wiki.pub -p <SSH_PORT> <SSH_USER>@<SSH_HOST>
```

### 3. Configuração de Atalho Local (`~/.ssh/config`)
Facilite o acesso criando um alias no arquivo de configuração do seu SSH local:
```text
Host cdc-wiki
    HostName <SSH_HOST>
    User <SSH_USER>
    Port <SSH_PORT>
    IdentityFile ~/.ssh/id_cdc_wiki
```
Agora, o acesso pode ser feito apenas rodando:
```bash
ssh cdc-wiki
```

### 4. Permissões de Segurança Locais
Assegure que os arquivos locais do seu SSH possuem as permissões corretas (erros de permissão impedem o SSH de funcionar):
```bash
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_cdc_wiki
chmod 644 ~/.ssh/id_cdc_wiki.pub
chmod 600 ~/.ssh/config
```

### 5. Configurações Recomendadas no Servidor VPS (`/etc/ssh/sshd_config`)
Para garantir a segurança, valide ou aplique as seguintes diretivas no arquivo `/etc/ssh/sshd_config` da VPS:
```text
# Desativa login como root diretamente
PermitRootLogin no

# Desativa autenticação convencional por senhas
PasswordAuthentication no

# Exige autenticação baseada em chaves públicas
PubkeyAuthentication yes
```
Após alterar, valide a sintaxe do arquivo de configuração e reinicie o serviço SSH:
```bash
sudo sshd -t
sudo systemctl restart ssh
```

---

## Diagnóstico em modo somente leitura

Antes de realizar qualquer intervenção ou migração, execute comandos de diagnóstico seguros (somente leitura) para entender a saúde da VPS:

### 1. Saúde Geral do Sistema
- **Sistema Operacional e Kernel:**
  ```bash
  uname -a
  cat /etc/os-release
  ```
- **Memória RAM:**
  ```bash
  free -h
  ```
- **CPU e Carga de Processamento:**
  ```bash
  uptime
  top -b -n 1 | head -n 20
  ```
- **Espaço Livre em Disco:**
  ```bash
  df -h
  ```
- **Uso de Inodes (Esgotamento de inodes impede criação de arquivos novos):**
  ```bash
  df -i
  ```

### 2. Rede e Portas
- **Portas Escutando no Host:**
  ```bash
  sudo ss -tulpn
  ```
- **Conectividade de Saída com o Mattermost:**
  ```bash
  curl -I https://mattermost.com
  ```

### 3. Diagnóstico Docker
- **Lista de Containers Ativos:**
  ```bash
  docker ps -a
  ```
- **Uso de Recursos por Containers:**
  ```bash
  docker stats --no-stream
  ```
- **Inspeção de Redes Virtuais:**
  ```bash
  docker network ls
  ```
- **Uso de Espaço pelo Docker (Imagens e contêineres órfãos):**
  ```bash
  docker system df
  ```

### 4. Diagnóstico de Aplicação e Banco
- **Logs Recentes do Wiki.js:**
  ```bash
  docker compose logs --tail=100 wiki
  ```
- **Estado de Saúde do Banco PostgreSQL:**
  ```bash
  docker compose exec db pg_isready -U wiki -d wikidb
  ```

---

## Preparação para migração

Siga este checklist antes de iniciar a movimentação de dados:
- [ ] **Code Freeze:** Suspender alterações de código ou infraestrutura 24h antes da janela.
- [ ] **Aviso Prévio:** Notificar os usuários sobre a indisponibilidade programada.
- [ ] **Inventário de Configuração:** Coletar cópia do `.env` atual e configurações de proxy do host.
- [ ] **Mapeamento de Tamanho:** Verificar o espaço em disco do servidor de destino (precisa ser no mínimo o dobro do tamanho ocupado pelo banco e assets).
- [ ] **Geração de Checksums:** Garantir que ferramentas de validação (sha256sum) estejam instaladas nos dois servidores.

---

## Exportação do banco de dados

Para exportar o banco de dados PostgreSQL sem expor segredos no histórico de processos da VPS:

1. Acesse o servidor de origem.
2. Utilize o arquivo `.env` para carregar as variáveis temporariamente na sessão SSH (sem passar senha como parâmetro do comando):
   ```bash
   # Carrega variáveis
   export $(grep -v '^#' .env | xargs)
   
   # Executa o dump de forma segura apontando para a rede interna do docker
   docker compose exec -e PGPASSWORD="$DB_PASS" db pg_dump -U wiki -h localhost -d wikidb -F c -b -v -f /var/lib/postgresql/data/wikidb_dump.backup
   ```
   *Nota: O dump será gerado dentro do volume persistente `./data/db` devido ao mapeamento do container.*
3. Mova o arquivo gerado para uma pasta temporária externa ao volume do banco:
   ```bash
   sudo mv ./data/db/wikidb_dump.backup ./wikidb_dump.backup
   sudo chown $USER:$USER ./wikidb_dump.backup
   ```

---

## Compactação e transferência

### 1. Compactação de Arquivos e Dumps
Compacte o dump do banco e eventuais arquivos de uploads em um único pacote comprimido:
```bash
tar -cvzf cdc_wiki_migration.tar.gz wikidb_dump.backup docker-compose.yml Dockerfile .env.example ajuda.txt
```

### 2. Geração do Checksum SHA-256
Gere o código hash para conferência após a transferência:
```bash
sha256sum cdc_wiki_migration.tar.gz > cdc_wiki_migration.tar.gz.sha256
```

### 3. Transferência de Dados via `rsync` (Mais seguro e resiliente que SCP)
Transfira os pacotes diretamente do servidor de origem para o de destino:
```bash
rsync -avz -e "ssh -p <SSH_PORT>" cdc_wiki_migration.tar.gz cdc_wiki_migration.tar.gz.sha256 <SSH_USER>@<SSH_HOST_DESTINO>:/home/<SSH_USER>/
```

### 4. Validação do Checksum no Servidor de Destino
No servidor de destino, valide a integridade do pacote transferido antes de descompactar:
```bash
sha256sum -c cdc_wiki_migration.tar.gz.sha256
```
*Se retornar "OK", o arquivo não sofreu corrupção na rede.*

---

## Comunicação da migração (Mattermost)

Use os seguintes comunicados no canal `#alertas-infra` para manter a equipe ciente:

### Início da Migração
```text
[MIGRAÇÃO DE SISTEMA] - CDC Wiki
Origem: VPS Antiga (<SSH_HOST>)
Destino: VPS Nova (<SSH_HOST_DESTINO>)
Status: Janela de manutenção iniciada. Serviços em modo de manutenção/offline.
```

### Conclusão e Sucesso
```text
[MIGRAÇÃO CONCLUÍDA] - CDC Wiki
Status: Sincronização e validações realizadas com sucesso no novo servidor. Serviço online.
```

---

## Validação pós-migração

Após subir o serviço na nova VPS, execute este roteiro técnico de homologação:
1. **Verificação de Rede:** Testar se o Wiki.js está respondendo na porta mapeada (ex: `curl -I http://localhost:3009`).
2. **Checagem de Banco de Dados:** Acessar o sistema e validar se páginas criadas recentemente constam na listagem (garante integridade do banco).
3. **Teste de Permissões de Upload:** Tentar realizar o upload de uma imagem em uma página de testes.
4. **Verificação de DNS:** Garantir que o apontamento do domínio `wiki.<DOMINIO_DO_PROJETO>` aponta para o IP da nova VPS.
5. **Certificado SSL/TLS:** Validar se o certificado HTTPS gerado pelo Proxy Reverso do novo host está ativo e seguro.
6. **Alerta de Teste:** Executar o script de teste de webhook do Mattermost para certificar que as notificações continuam ativas.

*Caso algum teste falhe de forma crítica, acione o Rollback imediato apontando o DNS de volta para a VPS de origem.*

---
Última revisão: 2026-07-13
Responsável pela revisão: Antigravity
Motivo da revisão: Inicialização do roteiro de migração e acessos SSH
