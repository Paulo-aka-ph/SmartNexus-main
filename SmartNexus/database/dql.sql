-- ============================================================
-- DQL - SmartNexus
-- Dialeto: PostgreSQL 13+
-- Consultas de verificação de povoamento e de respostas a
-- perguntas de negócio, com base no DER e no dicionário de
-- dados do projeto.
-- ============================================================
 
 
-- ============================================================
-- 1. VERIFICACAO DE POVOAMENTO
-- ============================================================
-- Confirma que o script.dml.sql populou todas as tabelas
-- corretamente, contando os registros de cada uma.
 
SELECT 'usuario'          AS tabela, COUNT(*) AS total_registros FROM usuario
UNION ALL
SELECT 'colaborador',       COUNT(*) FROM colaborador
UNION ALL
SELECT 'contato',           COUNT(*) FROM contato
UNION ALL
SELECT 'servico',           COUNT(*) FROM servico
UNION ALL
SELECT 'plataforma',        COUNT(*) FROM plataforma
UNION ALL
SELECT 'plano',             COUNT(*) FROM plano
UNION ALL
SELECT 'plano_servico',     COUNT(*) FROM plano_servico
UNION ALL
SELECT 'plano_plataforma',  COUNT(*) FROM plano_plataforma
UNION ALL
SELECT 'contrato',          COUNT(*) FROM contrato
UNION ALL
SELECT 'status_historico',  COUNT(*) FROM status_historico
UNION ALL
SELECT 'fatura',            COUNT(*) FROM fatura
UNION ALL
SELECT 'pagamento',         COUNT(*) FROM pagamento
UNION ALL
SELECT 'campanha',          COUNT(*) FROM campanha
UNION ALL
SELECT 'ativo_criativo',    COUNT(*) FROM ativo_criativo
UNION ALL
SELECT 'aprovacao',         COUNT(*) FROM aprovacao
UNION ALL
SELECT 'metrica',           COUNT(*) FROM metrica
UNION ALL
SELECT 'ticket',            COUNT(*) FROM ticket
UNION ALL
SELECT 'log_auditoria',     COUNT(*) FROM log_auditoria
ORDER BY tabela;
 
 
-- Verifica se existe algum registro "órfão" nas FKs mais
-- sensíveis (não deveria retornar linhas, dado o DDL com FK).
SELECT c.contrato_id
FROM contrato c
LEFT JOIN usuario u ON u.usuario_id = c.usuario_id
WHERE u.usuario_id IS NULL;
 
 
-- ============================================================
-- 2. CLIENTES E CONTRATOS
-- ============================================================
 
-- 2.1 Quais clientes têm contrato ativo, com plano e colaborador
--     responsável?
SELECT
    u.razao_social,
    p.nome        AS plano,
    col.nome      AS colaborador_responsavel,
    c.data_inicio,
    c.valor_negociado,
    c.status
FROM contrato c
JOIN usuario u      ON u.usuario_id = c.usuario_id
JOIN plano p        ON p.plano_id = c.plano_id
LEFT JOIN colaborador col ON col.colaborador_id = c.colaborador_id
WHERE c.status = 'ativo'
ORDER BY u.razao_social;
 
-- 2.2 Quantos contratos existem por status?
SELECT status, COUNT(*) AS quantidade
FROM contrato
GROUP BY status
ORDER BY quantidade DESC;
 
-- 2.3 Qual o valor total negociado, somando apenas contratos
--     ativos ou renovados (receita recorrente vigente)?
SELECT SUM(valor_negociado) AS receita_recorrente_vigente
FROM contrato
WHERE status IN ('ativo', 'renovado');
 
-- 2.4 Quais contratos usam um limite de anúncios diferente do
--     padrão do plano (negociação customizada)?
SELECT
    c.contrato_id,
    u.razao_social,
    p.nome            AS plano,
    p.qtd_anuncios_max AS limite_padrao_plano,
    c.qtd_anuncios_customizado AS limite_customizado
FROM contrato c
JOIN usuario u ON u.usuario_id = c.usuario_id
JOIN plano p   ON p.plano_id = c.plano_id
WHERE c.qtd_anuncios_customizado IS NOT NULL;
 
-- 2.5 Histórico de mudanças de status de um contrato específico
--     (exemplo: contrato_id = 4).
SELECT
    sh.status_anterior,
    sh.status_novo,
    sh.data_alteracao,
    col.nome AS alterado_por
FROM status_historico sh
LEFT JOIN colaborador col ON col.colaborador_id = sh.colaborador_id
WHERE sh.contrato_id = 4
ORDER BY sh.data_alteracao;
 
-- 2.6 Qual colaborador é responsável por mais contratos ativos?
SELECT
    col.nome,
    COUNT(c.contrato_id) AS contratos_ativos
FROM colaborador col
JOIN contrato c ON c.colaborador_id = col.colaborador_id
WHERE c.status = 'ativo'
GROUP BY col.nome
ORDER BY contratos_ativos DESC;
 
 
-- ============================================================
-- 3. CATALOGO E PLANOS
-- ============================================================
 
-- 3.1 Qual plano é o mais contratado?
SELECT
    p.nome,
    COUNT(c.contrato_id) AS qtd_contratacoes
FROM plano p
LEFT JOIN contrato c ON c.plano_id = p.plano_id
GROUP BY p.nome
ORDER BY qtd_contratacoes DESC;
 
-- 3.2 Quais serviços e plataformas estão incluídos em cada plano?
SELECT
    p.nome AS plano,
    STRING_AGG(DISTINCT s.nome, ', ')  AS servicos_inclusos,
    STRING_AGG(DISTINCT pl.nome, ', ') AS plataformas_inclusas
FROM plano p
LEFT JOIN plano_servico ps    ON ps.plano_id = p.plano_id
LEFT JOIN servico s           ON s.servico_id = ps.servico_id
LEFT JOIN plano_plataforma pp ON pp.plano_id = p.plano_id
LEFT JOIN plataforma pl       ON pl.plataforma_id = pp.plataforma_id
GROUP BY p.nome
ORDER BY p.nome;
 
 
-- ============================================================
-- 4. FINANCEIRO
-- ============================================================
 
-- 4.1 Quais faturas estão pendentes ou atrasadas, e de qual
--     cliente?
SELECT
    u.razao_social,
    f.fatura_id,
    f.competencia,
    f.valor,
    f.data_vencimento,
    f.status
FROM fatura f
JOIN contrato c ON c.contrato_id = f.contrato_id
JOIN usuario u  ON u.usuario_id = c.usuario_id
WHERE f.status IN ('pendente', 'atrasada')
ORDER BY f.data_vencimento;
 
-- 4.2 Qual o total efetivamente recebido (pagamentos
--     confirmados), por mês de pagamento?
SELECT
    TO_CHAR(data_pagamento, 'MM/YYYY') AS mes_recebimento,
    SUM(valor_pago) AS total_recebido
FROM pagamento
WHERE status = 'confirmado'
GROUP BY TO_CHAR(data_pagamento, 'MM/YYYY')
ORDER BY mes_recebimento;
 
-- 4.3 Existe alguma fatura sem pagamento confirmado
--     correspondente (possível inadimplência)?
SELECT
    f.fatura_id,
    u.razao_social,
    f.valor,
    f.data_vencimento,
    f.status
FROM fatura f
JOIN contrato c ON c.contrato_id = f.contrato_id
JOIN usuario u  ON u.usuario_id = c.usuario_id
LEFT JOIN pagamento pg ON pg.fatura_id = f.fatura_id AND pg.status = 'confirmado'
WHERE pg.pagamento_id IS NULL
  AND f.status <> 'cancelada';
 
-- 4.4 Qual a forma de pagamento mais utilizada pelos clientes?
SELECT
    tipo_pagamento,
    COUNT(*) AS quantidade,
    SUM(valor_pago) AS total_movimentado
FROM pagamento
WHERE status = 'confirmado'
GROUP BY tipo_pagamento
ORDER BY quantidade DESC;
 
 
-- ============================================================
-- 5. CAMPANHAS E DESEMPENHO
-- ============================================================
 
-- 5.1 Quais campanhas estão ativas atualmente, em qual
--     plataforma e para qual cliente?
SELECT
    u.razao_social,
    camp.nome AS campanha,
    pl.nome   AS plataforma,
    camp.orcamento,
    camp.status
FROM campanha camp
JOIN contrato c   ON c.contrato_id = camp.contrato_id
JOIN usuario u    ON u.usuario_id = c.usuario_id
JOIN plataforma pl ON pl.plataforma_id = camp.plataforma_id
WHERE camp.status = 'ativa'
ORDER BY u.razao_social;
 
-- 5.2 Qual o orçamento total alocado por plataforma?
SELECT
    pl.nome AS plataforma,
    COUNT(camp.campanha_id) AS qtd_campanhas,
    SUM(camp.orcamento)     AS orcamento_total
FROM plataforma pl
JOIN campanha camp ON camp.plataforma_id = pl.plataforma_id
GROUP BY pl.nome
ORDER BY orcamento_total DESC;
 
-- 5.3 Ranking de campanhas por ROI (retorno sobre investimento).
SELECT
    camp.nome AS campanha,
    u.razao_social,
    m.custo,
    m.conversoes,
    m.roi
FROM metrica m
JOIN campanha camp ON camp.campanha_id = m.campanha_id
JOIN contrato c     ON c.contrato_id = camp.contrato_id
JOIN usuario u      ON u.usuario_id = c.usuario_id
ORDER BY m.roi DESC;
 
-- 5.4 Custo por conversão (CPA) de cada campanha com métricas
--     registradas.
SELECT
    camp.nome AS campanha,
    m.custo,
    m.conversoes,
    ROUND(m.custo / NULLIF(m.conversoes, 0), 2) AS custo_por_conversao
FROM metrica m
JOIN campanha camp ON camp.campanha_id = m.campanha_id
ORDER BY custo_por_conversao;
 
-- 5.5 Situação dos criativos por status (fluxo de aprovação).
SELECT
    status,
    COUNT(*) AS quantidade
FROM ativo_criativo
GROUP BY status
ORDER BY quantidade DESC;
 
-- 5.6 Criativos ainda pendentes de aprovação, com o cliente e
--     campanha correspondentes.
SELECT
    u.razao_social,
    camp.nome AS campanha,
    ac.tipo,
    ac.url_arquivo,
    ac.versao
FROM ativo_criativo ac
JOIN campanha camp ON camp.campanha_id = ac.campanha_id
JOIN contrato c     ON c.contrato_id = camp.contrato_id
JOIN usuario u      ON u.usuario_id = c.usuario_id
WHERE ac.status = 'pendente';
 
 
-- ============================================================
-- 6. SUPORTE E AUDITORIA
-- ============================================================
 
-- 6.1 Quantos tickets estão abertos ou em andamento, por cliente?
SELECT
    u.razao_social,
    t.assunto,
    t.status,
    t.data_abertura
FROM ticket t
JOIN usuario u ON u.usuario_id = t.usuario_id
WHERE t.status IN ('aberto', 'em_andamento')
ORDER BY t.data_abertura;
 
-- 6.2 Tempo médio de resolução dos tickets já fechados/resolvidos
--     (em dias).
SELECT
    ROUND(AVG(EXTRACT(EPOCH FROM (data_fechamento - data_abertura)) / 86400), 1)
        AS media_dias_resolucao
FROM ticket
WHERE data_fechamento IS NOT NULL;
 
-- 6.3 Últimas alterações registradas no log de auditoria, com o
--     contrato e o colaborador responsável.
SELECT
    la.data_alteracao,
    u.razao_social,
    la.entidade_alterada,
    la.campo,
    la.valor_anterior,
    la.valor_novo,
    col.nome AS alterado_por
FROM log_auditoria la
JOIN contrato c ON c.contrato_id = la.contrato_id
JOIN usuario u  ON u.usuario_id = c.usuario_id
LEFT JOIN colaborador col ON col.colaborador_id = la.colaborador_id
ORDER BY la.data_alteracao DESC;
