---
title: postmortem
description: 
published: true
date: 2026-07-15T01:00:25.404Z
tags: 
editor: markdown
dateCreated: 2026-07-15T00:40:52.063Z
---

# Diretrizes e Modelo de Postmortem (Blameless)

Este documento orienta a realização de análises pós-incidentes na CDC. As investigações de problemas técnicos devem ser conduzidas sob uma **cultura sem culpabilização (blameless)**: o foco deve estar em identificar falhas de processo, melhorar os controles e robustecer a infraestrutura, nunca em punir indivíduos.

---

## Modelo de Relatório Postmortem

Use o template abaixo para documentar incidentes relevantes. Copie este conteúdo para um arquivo nomeado `postmortem_YYYYMMDD_descricao.md` dentro de uma pasta de histórico ou anexe ao repositório de infraestrutura correspondente.

---

### [POSTMORTEM] - Título Resumido do Incidente

#### 1. Identificação
- **Incidente Nº:** INC-XXXX
- **Data do Ocorrido:** AAAA-MM-DD
- **Ambiente Afetado:** [Produção / Homologação / Staging]
- **Sistemas Afetados:** [Wiki.js / PostgreSQL / Proxy Reverso / Outros]
- **Responsáveis pela Análise:** <NOME OU EQUIPE>
- **Severidade:** [Crítica / Alta / Média / Baixa]
- **Duração do Incidente:** XX horas e XX minutos
- **Status Atual:** [Resolvido / Mitigado]
- **Canal de Coordenação (Mattermost):** `#alertas-infra` (ou canal temporário de guerra)

---

#### 2. Resumo Executivo
*Forneça uma descrição curta e direta sobre o que aconteceu, o impacto imediato percebido, a janela de tempo total afetada, como o erro foi contido e o estado atual de estabilidade do sistema.*

---

#### 3. Sintomas e Comportamentos Observados
*Descreva detalhadamente o que indicou que havia um problema:*
- Logs de erro específicos capturados nos contêineres.
- Mensagens de indisponibilidade de rede ou falha de timeout HTTP (ex: Erro 502 Bad Gateway no Proxy).
- Alertas recebidos de forma automática nos canais do Mattermost.
- Reporte e reclamações recebidas da equipe de usuários da ONG.

---

#### 4. Impacto Detalhado
- **Usuários Afetados:** Estimar quantidade de usuários afetados ou impossibilitados de acesso.
- **Indisponibilidade de Serviços:** Quais caminhos, rotas ou recursos ficaram indisponíveis.
- **Perda ou Risco de Dados:** Houve perda de commits, páginas criadas ou uploads? Algum dado foi corrompido?
- **Impacto Operacional:** Como o incidente paralisou ou atrasou a operação normal da ONG.

---

#### 5. Timeline (Linha do Tempo)
Documente em ordem cronológica todas as etapas desde o primeiro indício até a normalização completa do sistema:

| Horário | Evento / Ação Tomada | Responsável | Detalhes / Observações |
| :--- | :--- | :--- | :--- |
| HH:MM | Indício primário ou alerta automático. | [Sistema] | Primeiro alerta gerado (ex: Mattermost ou monitoramento). |
| HH:MM | Início da investigação técnica. | <SSH_USER> | Análise de logs do Docker iniciada. |
| HH:MM | Descoberta da causa provável. | <SSH_USER> | Identificado erro de falta de espaço/permissão. |
| HH:MM | Ação de mitigação emergencial aplicada. | <SSH_USER> | Executado script de limpeza ou restart. |
| HH:MM | Serviços restabelecidos com sucesso. | <SSH_USER> | Wiki.js online e respondendo a requisições. |
| HH:MM | Comunicação de encerramento enviada. | [Sistema] | Notificação de status "Ok" enviada ao Mattermost. |

---

#### 6. Detecção e Notificação
- **Forma de Detecção:** O sistema foi detectado de forma pró-ativa por alertas do Mattermost ou reativa por reclamação de usuários?
- **Tempo de Reação (Time to Detect):** Tempo decorrido entre o início do erro e a primeira ação de resposta.
- **Avaliação dos Alertas:** Os alertas existentes foram claros e acionáveis? Faltaram alertas específicos? O webhook do Mattermost funcionou corretamente dentro do timeout de 10s?

---

#### 7. Resposta e Investigação
- **Ações Eficientes:** Quais decisões técnicas tomadas aceleraram a resolução do incidente.
- **Ações Ineficientes / Gargalos:** Quais dificuldades (falta de ferramentas, documentação incompleta, problemas de permissão) atrasaram a resolução.
- **Comunicação entre Equipes:** Avaliar como a equipe utilizou o Mattermost para se manter atualizada e alinhar as ações emergenciais de resposta.

---

#### 8. Análise de Causa Raiz (Metodologia dos 5 Porquês)
*Aplique a técnica para ir além dos sintomas superficiais e atingir o fator gerador original do problema:*
1. **Por que o sistema ficou offline?**
   *Porque o banco PostgreSQL parou de responder.*
2. **Por que o banco PostgreSQL parou de responder?**
   *Porque o container do banco foi encerrado abruptamente pelo sistema operacional (OOM Killer).*
3. **Por que ele foi encerrado pelo OOM Killer?**
   *Porque a VPS ficou sem memória RAM livre disponível.*
4. **Por que a VPS ficou sem memória RAM livre?**
   *Porque o banco executou consultas não otimizadas que consumiram toda a RAM.*
5. **Por que a consulta não foi otimizada ou limitada?**
   *Porque não havia limites de memória (`deploy.resources.limits`) configurados para o container do banco no docker-compose.yml.*

---

#### 9. Fatores Contribuintes
*Listagem de causas secundárias ou deficiências que agravaram o cenário:*
- **Arquitetura:** Ausência de limites de recursos de memória no Docker.
- **Permissões:** Demora para conseguir acesso ao servidor devido a chaves SSH desatualizadas.
- **Documentação:** Falta de um guia de troubleshooting específico para problemas de banco de dados no repositório.
- **Espaço/Capacidade:** Ausência de alertas de disco cheio.

---

#### 10. O que funcionou e o que não funcionou
- **Funcionou:** O backup automático programado na noite anterior estava íntegro e disponível para restauração se necessário.
- **Não funcionou:** O envio de e-mails de alerta por SMTP falhou devido a portas bloqueadas na VPS, restando apenas os logs locais.

---

#### 11. Avaliação de Comunicação
- O canal de comunicação utilizado foi adequado?
- Houve exposição acidental de credenciais, chaves ou tokens de webhook no chat do Mattermost ou nos arquivos de log compartilhados?
- A notificação final de encerramento de crise foi enviada com os detalhes técnicos higienizados?

---

#### 12. Ações Corretivas e Preventivas
Documente as tarefas obrigatórias criadas para evitar que este incidente ocorra novamente:

| Ação Recomendada | Tipo | Prioridade | Responsável | Prazo | Status |
| :--- | :--- | :--- | :--- | :--- | :--- |
| Adicionar limits de memória RAM no docker-compose.yml. | Correção | Crítica | <NOME/TIME> | AAAA-MM-DD | [Pendente] |
| Configurar monitoramento ativo de disco no host. | Prevenção | Alta | <NOME/TIME> | AAAA-MM-DD | [Pendente] |
| Revisar permissões de escrita em volumes docker. | Correção | Média | <NOME/TIME> | AAAA-MM-DD | [Concluído] |

---

#### 13. Lições Aprendidas
*Resumo do aprendizado gerado pelo incidente para a equipe técnica e para a governança de infraestrutura da ONG.*

---

#### 14. Evidências Técnicas (Sanitizadas)
*Anexe trechos de logs, saídas de comandos ou métricas geradas durante o incidente. Lembre-se de higienizar qualquer token, senha ou dado sensível.*

---
Última revisão: 2026-07-13
Responsável pela revisão: Antigravity
Motivo da revisão: Inicialização do modelo padronizado de post-mortem blameless
