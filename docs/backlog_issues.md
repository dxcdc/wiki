# Backlog de Issues: Planejamento e Próximos Passos (CDC Wiki)

Este documento centraliza as especificações para a abertura de **Issues** no repositório remoto do GitHub. Ele serve como o backlog oficial de melhorias de infraestrutura, integrações de IA e polimento de conteúdo do projeto.

Ao decidir iniciar qualquer uma dessas tarefas, você pode copiar o conteúdo abaixo para abrir a Issue correspondente no GitHub.

---

## 📋 Lista de Issues Planejadas

### [Issue #1] Implantação do Dify + Gemini no Easypanel (RAG da Wiki)
* **Título:** `feature(infra): implantar Dify na VPS via Easypanel para base de conhecimento de IA`
* **Labels:** `infraestrutura`, `inteligência-artificial`, `backlog`
* **Responsável:** TI / Administrador do Sistema

#### 📄 Descrição da Task
Subir uma instância do **Dify** na VPS utilizando o Docker Compose oficial no Easypanel. O objetivo é criar a base vetorial (RAG) que indexará os arquivos Markdown da Wiki (`pt-br/`) e conectá-la ao modelo de linguagem Gemini.

#### 🛠️ Checklist de Execução
- [ ] Criar um novo serviço no Easypanel selecionando a opção de importação de **Docker Compose**.
- [ ] Utilizar a receita oficial do Dify configurando volumes persistentes para o PostgreSQL e Redis.
- [ ] Configurar um subdomínio reverso no Traefik (ex: `dify.cdc.org.br`) com certificado SSL ativo.
- [ ] Acessar o painel do Dify e cadastrar a conta de administrador corporativa.
- [ ] Criar a chave de API do Gemini no **Google AI Studio** e conectá-la no painel do Dify.
- [ ] Criar um conjunto de dados (Knowledge Base) no Dify fazendo upload da pasta Git de Markdowns (`pt-br/`).

---

### [Issue #2] Integração do Agente de IA com o Mattermost (Chatbot)
* **Título:** `feature(chat): integrar agente do Dify com Mattermost e configurar limites`
* **Labels:** `integração`, `chat`, `segurança`
* **Responsável:** TI / Desenvolvimento

#### 📄 Descrição da Task
Conectar o aplicativo de chat criado no Dify com o Mattermost da organização utilizando webhooks de entrada e saída. A integração deve conter regras ativas de proteção e limites de uso (rate limiting) para evitar abuso de cota de API.

#### 🛠️ Checklist de Execução
- [ ] Criar um aplicativo do tipo *Chat/Assistant* no painel do Dify.
- [ ] No Mattermost, criar um *Gatilho de Saída (Outgoing Webhook)* que escuta menções ao bot (ex: `@WikiBot`) no canal de suporte.
- [ ] Configurar o webhook do Mattermost para enviar o texto da mensagem à API do Dify.
- [ ] No Dify, cadastrar a URL do webhook de entrada do Mattermost (`https://chat.cdc.org.br/hooks/i86go91iwb8emp8cwt4do79eqw`) para devolver as respostas.
- [ ] **Configurar trava no Dify:** Definir um limite máximo de **10 perguntas por hora** ou **50 perguntas por dia** por colaborador para evitar consumo desnecessário de cotas.

---

### [Issue #3] Revisão, Polimento e Concordância Geral de Conteúdo (Nível Base)
* **Título:** `docs(polimento): revisão ortográfica, concordância de gênero e correção de imagens`
* **Labels:** `documentação`, `qualidade`, `conteúdo`
* **Responsável:** Designer Instrucional / Redator Técnico

#### 📄 Descrição da Task
Realizar uma revisão fina nas páginas do **Nível Base / Integração** para garantir a qualidade de leitura, corrigir concordâncias de termos e ajustar links de imagens para evitar falhas de carregamento.

#### 🛠️ Checklist de Execução
- [ ] **Sigla CDC:** Fazer varredura manual de revisão fina para certificar que todas as referências usem concordância masculina (ex: "no CDC", "do CDC", "pelo CDC").
- [ ] **Links de Imagens:** Garantir que todos os prints inseridos comecem com o prefixo `/assets/` (ex: `![](/assets/img/...)`) para não quebrarem na renderização estática do Wiki.js.
- [ ] **Modelo Híbrido:** Revisar os tutoriais práticos de cliques e telas e remover perguntas de reflexão escolar deles, movendo as perguntas retóricas de contexto apenas para as seções introdutórias dos capítulos.

---

### [Issue #4] Centralização de Alertas de Backup no Mattermost
* **Título:** `infra(segurança): integrar webhook de backup Mattermost no script bash da VPS`
* **Labels:** `infraestrutura`, `segurança`, `alertas`
* **Responsável:** Administrador de Infraestrutura

#### 📄 Descrição da Task
Configurar o script de backup automático da VPS (`backup.sh`) para realizar disparos para o canal do Mattermost via webhook de entrada, reportando se a rotina diária foi realizada com sucesso ou se houve falhas críticas.

#### 🛠️ Checklist de Execução
- [ ] Abrir o script `backup.sh` na VPS.
- [ ] Habilitar o parâmetro `MATTERMOST_ENABLED=true` e mapear a variável de ambiente `MATTERMOST_WEBHOOK_URL` apontando para o webhook público: `https://chat.cdc.org.br/hooks/i86go91iwb8emp8cwt4do79eqw`.
- [ ] Inserir os disparos de `curl` ao final da execução:
  - Disparar mensagem de sucesso 🟢 contendo a data, tamanho do arquivo compactado e hash SHA-256.
  - Disparar mensagem de falha 🔴 contendo o código do erro gerado caso o dump do PostgreSQL ou upload ao Drive falhem.
- [ ] Executar um teste manual de backup para validar o recebimento do alerta no chat.
