# Diretrizes de Governança da Documentação (CDC Wiki)

Este documento estabelece as regras permanentes de criação, organização, manutenção e evolução da documentação técnica do projeto Wiki.js da CDC.

---

## Objetivo da documentação

A documentação existe para garantir a continuidade operacional, a segurança e a governança técnica. Seus objetivos principais são:
- Reduzir a dependência de conhecimento informal ou individual (silenciamento de conhecimento);
- Facilitar a entrada e onboarding de novos desenvolvedores e engenheiros de infraestrutura;
- Registrar decisões arquiteturais importantes (ADRs) de forma clara;
- Permitir a reconstrução e recuperação completa de ambientes a partir do zero;
- Agilizar o diagnóstico e mitigação de incidentes operacionais;
- Apoiar migrações de servidores de forma estruturada e sem atrito;
- Fornecer insumos claros para auditorias de segurança e conformidade;
- Reduzir a ocorrência de erros operacionais por meio de checklists reprodutíveis;
- Manter código, infraestrutura e processos devidamente alinhados;
- Registrar integrações e fluxos de alertas enviados aos canais do Mattermost.

---

## Princípios

Os seguintes princípios norteiam a produção documental neste repositório:
- **Documentação como Código:** A documentação técnica é parte integrante do código-fonte do projeto.
- **Atualização Contínua:** Documentação desatualizada é pior do que nenhuma documentação. Qualquer alteração técnica deve refletir na documentação.
- **Segurança por Padrão:** Nenhuma credencial, senha, token ou chave privada deve ser exposta na documentação.
- **Placeholders Claros:** Utilizar sempre os placeholders definidos quando dados fictícios forem necessários.
- **Clareza acima de Complexidade:** Linguagem acessível, direta e objetiva, focando em comandos executáveis.
- **Cultura Blameless:** Foco em entender "o que falhou" e não "quem falhou" em relatórios pós-incidente.
- **Responsabilidade Compartilhada:** Todo membro da equipe que altera o código ou infraestrutura é responsável por manter a documentação correspondente atualizada.

---

## Estrutura oficial

A documentação deste repositório está centralizada no diretório `docs/` com a seguinte finalidade para cada arquivo:

| Arquivo | Finalidade |
| :--- | :--- |
| [diretrizes_documentacao.md](file:///home/vier/Documentos/Code/CDC/wiki/docs/diretrizes_documentacao.md) | Regras para criação, manutenção, qualidade e evolução da documentação. |
| [estrategia_execucao.md](file:///home/vier/Documentos/Code/CDC/wiki/docs/estrategia_execucao.md) | Estratégia de desenvolvimento, Gitflow, ambientes (dev, staging, prod) e rollback. |
| [migration_guide.md](file:///home/vier/Documentos/Code/CDC/wiki/docs/migration_guide.md) | Passos para migração de ambiente, acesso SSH seguro e diagnósticos. |
| [ajuda_infra.md](file:///home/vier/Documentos/Code/CDC/wiki/docs/ajuda_infra.md) | Arquitetura física/virtual, containers, isolamento de rede, DNS e Mattermost. |
| [postmortem.md](file:///home/vier/Documentos/Code/CDC/wiki/docs/postmortem.md) | Modelo e diretrizes de análise de incidentes de forma blameless. |
| [troubleshooting.md](file:///home/vier/Documentos/Code/CDC/wiki/docs/troubleshooting.md) | Guia de diagnóstico rápido para erros comuns de banco, rede, e-mail e layout. |
| [politica_backup.md](file:///home/vier/Documentos/Code/CDC/wiki/docs/politica_backup.md) | Política de backup (3-2-1), criptografia, script automatizado e restore. |
| [prompt_ia.md](file:///home/vier/Documentos/Code/CDC/wiki/docs/prompt_ia.md) | Contexto e prompts pré-configurados para acelerar interações com LLMs/IAs. |

---

## Regras de atualização

A documentação deve ser obrigatoriamente revisada e atualizada no mesmo ciclo de desenvolvimento da alteração se houver:
- Adição ou remoção de tecnologias ou dependências;
- Mudança de versão de imagens oficiais ou runtime;
- Alteração de portas físicas ou lógicas;
- Alteração de domínios ou subdomínios expostos;
- Modificação na infraestrutura de redes ou isolamentos virtuais;
- Criação ou remoção de contêineres Docker;
- Inclusão ou alteração de variáveis de ambiente no `.env.example`;
- Mudança arquitetural na política de backups ou rotinas de criptografia;
- Alteração na estrutura de CI/CD ou estratégia de branches;
- Ocorrência de incidentes operacionais de média a alta relevância;
- Descoberta de novo procedimento de troubleshooting;
- Alterações em canais de alertas ou webhooks do Mattermost.

---

## Responsabilidades

- **Engenheiros de Software:** Atualizar `estrategia_execucao.md`, `troubleshooting.md` (nível aplicação) e `prompt_ia.md`.
- **Engenheiros de DevOps/Infraestrutura:** Atualizar `ajuda_infra.md`, `migration_guide.md`, `politica_backup.md` e `troubleshooting.md` (nível infraestrutura).
- **Incident Commander / Analista de Operações:** Criar e revisar relatórios usando o modelo `postmortem.md`.
- **Líder Técnico:** Validar conformidade documental em Pull Requests e manter as `diretrizes_documentacao.md` atualizadas.

---

## Fluxo recomendado no Git

Mudanças de documentação devem ser integradas ao ciclo de vida normal do código:
1. Realizar as alterações de documentação na mesma branch da alteração de código correspondente.
2. Incluir a documentação atualizada no mesmo Pull Request.
3. Revisar a documentação durante o Code Review técnico.
4. Validar se links e diagramas renderizam corretamente antes do merge.
5. Utilizar mensagens de commits com prefixo `docs:`. Exemplos:
   - `docs: atualizar procedimento de backup`
   - `docs: documentar novas portas do servico web`
   - `docs: adicionar solucao para erro de permissao no troubleshooting`
   - `docs: configurar alertas do Mattermost no script de backup`

---

## Controle de versões da documentação

O histórico do Git serve como o log oficial das alterações de documentação. Para modificações estruturais relevantes, deve ser adicionada uma seção de controle no final do arquivo alterado seguindo o padrão:
```text
Última revisão: <AAAA-MM-DD>
Responsável pela revisão: <NOME OU EQUIPE>
Motivo da revisão: <DESCRIÇÃO>
```

---

## Revisão periódica

Abaixo está o cronograma de revisões proativas recomendadas para manter os documentos saudáveis:

| Documento | Frequência recomendada |
| :--- | :--- |
| `diretrizes_documentacao.md` | Trimestral |
| `estrategia_execucao.md` | A cada release relevante |
| `migration_guide.md` | Semestral (ou antes de janelas de migração) |
| `ajuda_infra.md` | Sempre que a topologia física/virtual for modificada |
| `postmortem.md` | Em até 5 dias úteis após um incidente crítico |
| `troubleshooting.md` | Sempre que um novo erro recorrente for mitigado |
| `politica_backup.md` | Trimestral (casada com testes de restore em sandbox) |
| `prompt_ia.md` | Semestral |

---

## Critérios de qualidade

Toda documentação gerada ou alterada deve satisfazer os seguintes critérios:
- **Precisão Técnica:** Comandos prontos para cópia e execução direta (sem reticências ou placeholders mal especificados).
- **Sanitização de Dados:** Totalmente livre de dados confidenciais ou segredos de produção.
- **Links Relativos Funcionais:** Todas as referências a outros arquivos devem usar links relativos Markdown válidos.
- **Sintaxe Válida:** Blocos de código, tabelas e diagramas Mermaid devem renderizar sem erros.

---

## Informações proibidas

Fica terminantemente proibido registrar nos arquivos versionados:
- Senhas de acesso a bancos de dados, servidores ou e-mails;
- Tokens de APIs ou bots;
- Chaves de criptografia públicas/privadas ou passphrases;
- Webhooks reais de integração com o Mattermost ou outras ferramentas;
- Dumps ou arquivos de dados reais de produção contendo dados pessoais de usuários;
- Arquivos `.env` contendo dados reais.

---

## Placeholders oficiais

Ao criar exemplos ou templates, utilize estritamente a seguinte lista de placeholders:
- `<APP_SECRET>`: Chave secreta de criptografia da aplicação.
- `<DB_PASSWORD>`: Senha de banco de dados.
- `<API_TOKEN>`: Chaves de API de serviços externos.
- `<MATTERMOST_WEBHOOK_URL>`: URL do webhook de alertas do Mattermost.
- `<MATTERMOST_CHANNEL>`: Nome do canal de monitoramento do Mattermost.
- `<SMTP_PASSWORD>`: Senha de autenticação do servidor de e-mails.
- `<SSH_HOST>`: Endereço IP ou hostname do servidor VPS.
- `<SSH_USER>`: Usuário de acesso SSH.
- `<SSH_PORT>`: Porta de acesso SSH.
- `<DOMINIO_DO_PROJETO>`: URL principal do sistema.
- `<ENDERECO_DO_SERVIDOR>`: Host de conexões internas ou externas.
- `<NOME_DO_BANCO>`: Nome do schema SQL.
- `<USUARIO_DO_BANCO>`: Usuário de conexões SQL.

---

## Checklist para pull requests

O seguinte checklist deve ser preenchido nos Pull Requests para validação técnica:
```markdown
## Checklist de documentação

- [ ] Esta alteração modifica arquitetura?
- [ ] Esta alteração modifica infraestrutura?
- [ ] Esta alteração cria ou remove variáveis de ambiente?
- [ ] Esta alteração modifica portas ou redes?
- [ ] Esta alteração modifica o banco de dados?
- [ ] Esta alteração modifica o processo de implantação?
- [ ] Esta alteração modifica o processo de backup?
- [ ] Esta alteração cria um novo procedimento de suporte?
- [ ] Esta alteração modifica alertas ou integrações do Mattermost?
- [ ] Os documentos afetados foram atualizados?
- [ ] O `.env.example` foi atualizado quando necessário?
- [ ] Os exemplos não contêm credenciais reais?
- [ ] Os comandos foram validados?
- [ ] Os links internos continuam funcionando?
- [ ] Os testes de webhook usam somente variáveis de ambiente?
```

---

## Registro de decisões

Decisões de arquitetura que alterem de forma definitiva o ecossistema (ex: migração de banco, mudança de runtime) devem ser estruturadas em formato ADR (Architecture Decision Records) no subdiretório `docs/adr/`. 
*Nota: Não criar a pasta adr/ até que uma decisão estrutural relevante precise ser documentada.*

---

## Processo de descontinuação

Caso um serviço ou rotina seja descontinuado:
1. Marcar explicitamente as seções afetadas na documentação com uma nota de `[DESCONTINUADO]`.
2. Indicar a data de encerramento e o novo fluxo recomendado.
3. Não apagar imediatamente as instruções legadas para garantir suporte em depurações de releases antigas.
4. Limpar e remover as variáveis e alertas legados no Mattermost.

---

## Validação da documentação

Antes de submeter um merge de documentação, certifique-se de validar:
- Que todos os arquivos de configuração (ex: `.env.example`) estão em sincronia com o que está documentado.
- Que não há caminhos absolutos baseados na máquina do desenvolvedor.
- Que comandos SSH ou de backup não contêm riscos ocultos ou comandos destrutivos sem a devida sinalização de perigo.

---

## Evolução futura

Este framework documental reflete a arquitetura atual da CDC baseada no Wiki.js. Ele deve crescer e se adaptar dinamicamente conforme os requisitos de conformidade, novas ferramentas de automação ou mudanças estruturais do projeto.

---
Última revisão: 2026-07-13
Responsável pela revisão: Antigravity
Motivo da revisão: Inicialização do repositório de documentação técnica do Wiki.js
