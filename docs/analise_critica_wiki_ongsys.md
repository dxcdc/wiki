# Análise Crítica e Guia de Redação Técnica: Wiki ONGSYS (CDC)

Este documento reúne a análise crítica e as diretrizes práticas de redação técnica e arquitetura de informação para a base de conhecimento do **ONGSYS** no **CDC**. 

Utilize este guia como referência para futuras revisões, mantendo o foco e a empolgação no desenvolvimento dos conteúdos!

---

## 🧭 Lição Aprendida: O Viés Humano e o Modelo Híbrido de Escrita

Escrever um manual como um **diálogo** ou conversa interativa é uma escolha de design instrucional legítima e muito humana. Ela nasce de um viés positivo: a empatia. A intenção é reduzir a distância e a frieza entre o leitor e a ferramenta complexa, simulando o acolhimento de um colega de trabalho ensinando o outro.

No entanto, no contexto de sistemas ERP corporativos, precisamos equilibrar essa abordagem com a realidade de dois perfis de leitores:

1. **O Aprendiz (Onboarding):** Aquele que está lendo a Wiki pela primeira vez. Para ele, o tom dialógico, as perguntas e o acolhimento reduzem a ansiedade cognitiva e aumentam a retenção.
2. **O Usuário Sob Pressão (Referência Rápida):** Aquele que já conhece o sistema, mas está no meio de uma tarefa crítica (ex: um pagamento que precisa ser aprovado antes do horário de fechamento bancário). Esse usuário está sob estresse, tem pouca energia mental disponível e precisa achar o passo exato em segundos. Perguntas interativas ou textos longos nesse momento geram atrito e impaciência.

### O Modelo Híbrido do CDC
Para aproveitar a sabedoria e a empatia da sua escrita sem comprometer a eficiência na hora do aperto, adote o **Modelo Híbrido**:
* **Introduções e Conceitos (Onde o Diálogo brilha):** Use o tom empático e perguntas retóricas para contextualizar e aproximar. Ex: *"Por que classificar corretamente o Centro de Custo é o primeiro passo para o sucesso do projeto? Porque..."*
* **Procedimentos e Passo a Passo (Onde a Ação domina):** Quando chegar nas instruções de cliques e campos, mude para um formato puramente procedimental, direto e altamente escaneável visualmente (listas numeradas, tabelas e alertas rápidos).

---

## 1. Diretriz Editorial: O Tom de Voz do CDC

O tom de voz ideal para a documentação é o **Corporativo Amigável**. Ele une a precisão e a seriedade necessárias em um ambiente de auditoria com a clareza e acessibilidade indispensáveis para o aprendizado rápido.

### Tabela de Conversão de Tom (De: Pessoal/Coloquial ➔ Para: Corporativo Amigável)

| Tom Coloquial / Escolar | Tom Corporativo Amigável | Objetivo da Mudança |
| :--- | :--- | :--- |
| *"...mande um oi em nossos canais apropriados de chat."* | *"...reporte a ocorrência no canal de suporte do Mattermost (#suporte-financeiro) ou abra um chamado."* | Fornece instruções claras e caminhos oficiais em vez de ações vagas. |
| *"...para refletir: você conseguiria identificar...?"* | *"...**Critério de validação:** Certifique-se de que os seguintes dados estão visíveis no cabeçalho..."* | Elimina o tom de questionário escolar e foca na validação prática do trabalho. |
| *"...onde o ONGSYS não chega..."* | *"...**Limitação de Escopo:** O controle físico de materiais e almoxarifado é realizado no sistema..."* | Substitui metáforas coloquiais por termos técnicos de documentação. |
| *"...se notar algo estranho..."* | *"...caso identifique divergências cadastrais ou valores incompatíveis..."* | Aumenta a precisão técnica na identificação de erros. |

---

## 2. Estrutura e Escopo Instrucional (Evitando Desvios)

Cada página da Wiki deve responder a uma necessidade imediata do colaborador. Evite transformar a documentação do sistema em cursos teóricos de conceitos gerais.

* **Foco no Sistema:** Em vez de ensinar conceitos avançados de "como limpar dados de planilhas", o manual de **Relatórios** deve focar exclusivamente em:
  1. Caminho de menus para acessar o gerador de relatórios.
  2. Como selecionar os filtros ativos (Período, Centro de Custo).
  3. Como extrair o arquivo (clicando no botão "Exportar para Excel").
  4. O que fazer com o relatório extraído no fluxo do CDC.
* **Modularização:** Caso um assunto conceitual seja muito rico e importante, crie um documento separado para ele (ex: um *Guia Geral de Excel* ou *Fundamentos Contábeis do Terceiro Setor*), evitando que o manual de uso do sistema fique longo ou cansativo.

---

## 3. Padrões de Estilo do Wiki.js

### Alertas Visuais (Markdown Containers)
A utilização de containers com classes (como `{.is-warning}`) é excelente para quebrar a monotonia do texto e destacar pontos críticos. Mantenha os seguintes padrões:

```markdown
> **Informação: [Título da Dica]**
> Conteúdo complementar ou atalhos úteis.
{.is-info}

> **Regra do CDC: [Norma Obrigatória]**
> Diretrizes internas, regulamentos e prestação de contas.
{.is-success}

> **Atenção: [Cuidado Crítico]**
> Ações que exigem atenção redobrada para evitar erros no lançamento.
{.is-warning}

> **Não Faça: [Risco de Inconsistência]**
> Bloqueios e ações proibidas que podem gerar retrabalho ou falhas de auditoria.
{.is-danger}
```

### Caminho das Imagens (Favicons e Prints)
No Wiki.js, arquivos de imagens ou anexos que são commitados no Git são servidos em um diretório virtual público chamado **`/assets/`**. 
* **Regra de Link de Imagem:** Sempre insira o prefixo `/assets/` antes do caminho da pasta do repositório no seu link markdown.
  * *Incorreto:* `![](/img/ongsys/base/tela_de_login.png)`
  * *Correto:* `![](/assets/img/ongsys/base/tela_de_login.png)`

---

## 4. Plano de Polimento para a Fase Final

Quando a escrita estiver concluída e os primeiros rascunhos de todos os níveis estiverem prontos, realize uma rodada de revisão focada em:
1. **Padronização de Acessibilidade:** Testar se o tamanho de fonte configurado atende à leitura.
2. **Revisão Ortográfica Geral:** Substituir quaisquer referências femininas residuais a siglas masculinas (ex: "na CDC" para "no CDC").
3. **Limpeza de Links:** Verificar se todas as referências cruzadas direcionam para páginas existentes sem gerar caminhos duplicados.

---

## 🎨 5. As 4 Abordagens Visuais (Design da Wiki)

Para guiar a construção visual de cada seção da Wiki de forma padronizada e com propósito didático claro, utilize esta matriz conceitual para escolher e formatar suas imagens, diagramas ou infográficos:

### 1. Infográfico
* **Objetivo:** Explicar ou ensinar uma tarefa/procedimento de forma visual e sequencializada em poucos passos simples.
* **Pergunta Central:** *Como eu faço essa tarefa?*
* **Perguntas que o infográfico deve responder:**
  * Quais são as etapas de execução da tarefa?
  * Quais campos e informações preciso preencher?
  * O que devo conferir antes de salvar/enviar?
  * Quais erros operacionais devem ser evitados?

### 2. Roadmap ou Mapa de Processo
* **Objetivo:** Apresentar a jornada macro e o fluxo operacional completo de uma atividade de ponta a ponta, incluindo decisões e interações entre setores.
* **Pergunta Central:** *Como esse processo acontece de ponta a ponta?*
* **Perguntas que o roadmap deve responder:**
  * Qual é o ponto de partida e o resultado final do processo?
  * Quem participa ou é responsável por cada etapa?
  * O que acontece depois de cada ação ou aprovação?
  * Em quais pontos do fluxo podem ocorrer desvios, erros ou devoluções?

### 3. Infonomics (Infonomia)
* **Objetivo:** Demonstrar o valor estratégico e prático da correta governança e exatidão dos dados inseridos no sistema, mostrando-os como ativos da organização.
* **Pergunta Central:** *Como essas informações geram valor para a organização?*
* **Perguntas que a infonomia deve responder:**
  * Quais dados inseridos no ERP são críticos?
  * Como essas informações facilitam auditorias e prestação de contas?
  * De que forma esses dados apoiam o planejamento financeiro e as decisões da diretoria?
  * Quais riscos reais de retrabalho ou perda de verba o CDC enfrenta se esses dados estiverem incorretos?

### 4. Mapa de Conhecimento
* **Objetivo:** Visualizar as conexões e a circulação de conhecimento entre pessoas, departamentos, sistemas, bancos de dados e manuais.
* **Pergunta Central:** *Como pessoas, sistemas, processos e documentos estão conectados?*
* **Perguntas que o mapa de conhecimento deve responder:**
  * Qual a origem primária dessa informação e quem é o seu destinatário final?
  * Em qual repositório ou sistema os dados e arquivos residem?
  * Em qual seção da Wiki esse processo ou procedimento está detalhado?
  * Quais áreas do CDC dependem direta ou indiretamente dessa informação?

---

### ⚡ Matriz de Referência Instrucional

| Abordagem | Objetivo Principal | Pergunta Central a Responder |
| :--- | :--- | :--- |
| **Infográfico** | Explicar visualmente uma tarefa prática. | *Como eu faço isso?* |
| **Roadmap** | Mostrar etapas e a jornada de um processo. | *Como esse processo acontece de ponta a ponta?* |
| **Infonomics** | Demonstrar como a qualidade dos dados gera valor. | *Como essas informações geram valor para a organização?* |
| **Mapa de Conhecimento** | Conectar pessoas, sistemas e manuais. | *Onde está o conhecimento e como tudo se conecta?* |

