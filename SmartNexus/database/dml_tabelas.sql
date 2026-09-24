-- ============================================================
-- DML - SmartNexus
-- Dialeto: PostgreSQL 13+
-- Script de povoamento (dados de exemplo) coerente com o
-- script.ddl.sql, o DER e o dicionário de dados do projeto.
-- ============================================================
-- Observações:
--   * IDs são informados explicitamente para facilitar a leitura
--     e a criação de relacionamentos entre as tabelas de exemplo.
--   * Ao final, as sequences (SERIAL) são realinhadas com
--     setval(), para que próximos INSERTs feitos pela aplicação
--     não colidam com os IDs inseridos aqui.
--   * A ordem dos INSERTs respeita as dependências de FK.
--   * O bloco TRUNCATE abaixo limpa todas as tabelas antes de
--     inserir os dados de exemplo, evitando erro de chave
--     duplicada (usuario_pkey, contrato_pkey etc.) ao reexecutar
--     este script em um banco que já tenha sido populado antes.
-- ============================================================

BEGIN;

-- ------------------------------------------------------------
-- LIMPEZA PREVIA (permite reexecutar o script com segurança)
-- ------------------------------------------------------------
-- RESTART IDENTITY reinicia as sequences dos SERIAL; CASCADE
-- remove também os registros das tabelas dependentes (FKs).

TRUNCATE TABLE
    log_auditoria,
    ticket,
    metrica,
    aprovacao,
    ativo_criativo,
    campanha,
    pagamento,
    fatura,
    status_historico,
    contrato,
    plano_plataforma,
    plano_servico,
    plano,
    plataforma,
    servico,
    contato,
    colaborador,
    usuario
RESTART IDENTITY CASCADE;

-- ------------------------------------------------------------
-- DOMINIO: CLIENTE
-- ------------------------------------------------------------

INSERT INTO usuario (usuario_id, razao_social, cnpj, email, telefone, data_cadastro) VALUES
(1, 'TechNova Soluções Digitais Ltda', '12.345.678/0001-90', 'contato@technova.com.br', '(41) 3025-4477', '2025-01-10 09:15:00'),
(2, 'Padaria Sabor & Arte Ltda',        '23.456.789/0001-01', 'contato@saborarte.com.br', '(41) 3222-1188', '2025-02-14 10:40:00'),
(3, 'Studio Fit Academia Ltda',         '34.567.890/0001-12', 'contato@studiofit.com.br', '(41) 3345-9900', '2025-03-05 14:20:00'),
(4, 'Construtora Horizonte Ltda',       '45.678.901/0001-23', 'comercial@horizonteconstrutora.com.br', '(41) 3456-7788', '2025-04-20 08:50:00'),
(5, 'Clínica Vitalis Odontologia Ltda', '56.789.012/0001-34', 'contato@clinicavitalis.com.br', '(41) 3567-8899', '2025-05-02 11:05:00');

INSERT INTO colaborador (colaborador_id, nome, email, cargo) VALUES
(1, 'Marina Souza',        'marina.souza@smartnexus.com.br', 'Gestora de Tráfego'),
(2, 'Rafael Lima',         'rafael.lima@smartnexus.com.br',  'Account Manager'),
(3, 'Beatriz Alves',       'beatriz.alves@smartnexus.com.br','Designer'),
(4, 'João Pedro Martins',  'joao.martins@smartnexus.com.br', 'Analista de Marketing');

INSERT INTO contato (contato_id, usuario_id, nome, cargo, email, telefone, is_financeiro, is_aprovador) VALUES
(1, 1, 'Fernanda Ribeiro', 'Diretora de Marketing',    'fernanda@technova.com.br', '(41) 99123-4567', TRUE,  TRUE),
(2, 1, 'Carlos Eduardo',   'Analista Financeiro',      'carlos@technova.com.br',   '(41) 99123-8899', TRUE,  FALSE),
(3, 2, 'Juliana Pereira',  'Proprietária',             'juliana@saborarte.com.br', '(41) 99234-5566', TRUE,  TRUE),
(4, 3, 'Rodrigo Nunes',    'Gerente de Unidade',       'rodrigo@studiofit.com.br', '(41) 99345-6677', TRUE,  TRUE),
(5, 4, 'Camila Duarte',    'Coordenadora Comercial',   'camila@horizonteconstrutora.com.br', '(41) 99456-7788', FALSE, TRUE),
(6, 4, 'Bruno Castro',     'Analista Financeiro',      'bruno@horizonteconstrutora.com.br',  '(41) 99456-9900', TRUE,  FALSE),
(7, 5, 'Patrícia Gomes',   'Gerente Administrativa',   'patricia@clinicavitalis.com.br', '(41) 99567-8899', TRUE, TRUE);

-- ------------------------------------------------------------
-- DOMINIO: CATALOGO E PLANOS
-- ------------------------------------------------------------

INSERT INTO servico (servico_id, nome, descricao, categoria) VALUES
(1, 'Gestão de Tráfego Pago',            'Criação, veiculação e otimização de campanhas de anúncios pagos.', 'Tráfego Pago'),
(2, 'Gestão de Redes Sociais',           'Planejamento e publicação de conteúdo nas redes sociais do cliente.', 'Social Media'),
(3, 'Criação de Identidade Visual',      'Desenvolvimento de logotipo, paleta de cores e manual de marca.', 'Design'),
(4, 'Otimização para Buscadores (SEO)',  'Ações de otimização on-page e off-page para ranqueamento orgânico.', 'SEO'),
(5, 'Produção de Conteúdo em Vídeo',     'Roteirização, gravação e edição de vídeos publicitários.', 'Audiovisual');

INSERT INTO plataforma (plataforma_id, nome, tipo) VALUES
(1, 'Google Ads',   'Busca'),
(2, 'Meta Ads',     'Rede Social'),
(3, 'TikTok Ads',   'Rede Social'),
(4, 'LinkedIn Ads', 'Rede Social'),
(5, 'YouTube Ads',  'Vídeo');

INSERT INTO plano (plano_id, nome, descricao, qtd_anuncios_max, preco_base, periodicidade, ativo) VALUES
(1, 'Plano Básico',             'Ideal para pequenos negócios iniciando em mídia paga.', 5,  890.00,  'mensal',     TRUE),
(2, 'Plano Pro',                'Para empresas em crescimento com presença em múltiplas plataformas.', 15, 1890.00, 'mensal',     TRUE),
(3, 'Plano Enterprise',         'Gestão completa para grandes contas, com todos os serviços incluídos.', 40, 4500.00, 'mensal',     TRUE),
(4, 'Plano Trimestral Sazonal', 'Pacote voltado a campanhas de lançamento/sazonais de curta duração.', 10, 2200.00, 'trimestral', TRUE);

INSERT INTO plano_servico (plano_id, servico_id) VALUES
(1, 1), (1, 2),
(2, 1), (2, 2), (2, 3),
(3, 1), (3, 2), (3, 3), (3, 4), (3, 5),
(4, 1), (4, 2), (4, 5);

INSERT INTO plano_plataforma (plano_id, plataforma_id) VALUES
(1, 1), (1, 2),
(2, 1), (2, 2), (2, 3),
(3, 1), (3, 2), (3, 3), (3, 4), (3, 5),
(4, 1), (4, 2), (4, 5);

-- ------------------------------------------------------------
-- DOMINIO: CONTRATACAO
-- ------------------------------------------------------------

INSERT INTO contrato (contrato_id, usuario_id, plano_id, colaborador_id, data_inicio, data_fim, status, valor_negociado, qtd_anuncios_customizado, observacoes) VALUES
(1, 1, 2, 2, '2025-02-01', NULL,         'ativo',     1750.00, NULL, 'Negociação com desconto de fidelidade.'),
(2, 2, 1, 1, '2025-02-20', NULL,         'ativo',      890.00, NULL, NULL),
(3, 3, 3, 2, '2025-03-10', NULL,         'ativo',     4200.00, 45,   'Cliente solicitou aumento no limite de anúncios simultâneos.'),
(4, 4, 4, 4, '2025-04-25', '2025-07-25', 'renovado',  2200.00, NULL, 'Campanha sazonal de lançamento de empreendimento residencial.'),
(5, 5, 1, 1, '2025-05-05', '2025-08-05', 'cancelado',  850.00, NULL, 'Cliente cancelou por motivos financeiros.');

INSERT INTO status_historico (status_id, contrato_id, colaborador_id, status_anterior, status_novo, data_alteracao) VALUES
(1, 1, 2, 'proposta', 'ativo',     '2025-02-01 09:00:00'),
(2, 4, 4, 'ativo',    'renovado',  '2025-07-20 16:30:00'),
(3, 5, 1, 'ativo',    'cancelado', '2025-08-01 10:15:00');

-- ------------------------------------------------------------
-- DOMINIO: FINANCEIRO
-- ------------------------------------------------------------

INSERT INTO fatura (fatura_id, contrato_id, valor, data_vencimento, status, competencia) VALUES
(1, 1, 1750.00, '2025-02-10', 'paga',      '02/2025'),
(2, 1, 1750.00, '2025-03-10', 'paga',      '03/2025'),
(3, 1, 1750.00, '2025-04-10', 'pendente',  '04/2025'),
(4, 2,  890.00, '2025-02-25', 'paga',      '02/2025'),
(5, 2,  890.00, '2025-03-25', 'paga',      '03/2025'),
(6, 3, 4200.00, '2025-03-15', 'paga',      '03/2025'),
(7, 4, 2200.00, '2025-04-30', 'paga',      '04/2025'),
(8, 5,  850.00, '2025-05-10', 'paga',      '05/2025'),
(9, 5,  850.00, '2025-06-10', 'cancelada', '06/2025');

INSERT INTO pagamento (pagamento_id, fatura_id, tipo_pagamento, valor_pago, data_pagamento, status, comprovante_url) VALUES
(1, 1, 'PIX',                 1750.00, '2025-02-09', 'confirmado', '/comprovantes/technova/fatura_01.pdf'),
(2, 2, 'PIX',                 1750.00, '2025-03-09', 'confirmado', '/comprovantes/technova/fatura_02.pdf'),
(3, 4, 'Boleto',               890.00, '2025-02-24', 'confirmado', '/comprovantes/saborarte/fatura_04.pdf'),
(4, 5, 'Boleto',               890.00, '2025-03-24', 'confirmado', '/comprovantes/saborarte/fatura_05.pdf'),
(5, 6, 'Cartão de Crédito',   4200.00, '2025-03-14', 'confirmado', '/comprovantes/studiofit/fatura_06.pdf'),
(6, 7, 'Transferência',       2200.00, '2025-04-29', 'confirmado', '/comprovantes/horizonte/fatura_07.pdf'),
(7, 8, 'Boleto',                850.00, '2025-06-01', 'confirmado', '/comprovantes/vitalis/fatura_08.pdf');

-- ------------------------------------------------------------
-- DOMINIO: EXECUCAO DE CAMPANHAS
-- ------------------------------------------------------------

INSERT INTO campanha (campanha_id, contrato_id, plataforma_id, nome, data_inicio, data_fim, orcamento, status) VALUES
(1, 1, 1, 'TechNova - Google Search',              '2025-02-05', NULL,         800.00,  'ativa'),
(2, 1, 2, 'TechNova - Meta Conversão',              '2025-02-05', NULL,         600.00,  'ativa'),
(3, 2, 2, 'Sabor & Arte - Instagram Delivery',      '2025-02-22', NULL,         400.00,  'ativa'),
(4, 3, 1, 'Studio Fit - Google Leads',              '2025-03-12', NULL,        1500.00,  'ativa'),
(5, 3, 3, 'Studio Fit - TikTok Awareness',          '2025-03-12', NULL,         900.00,  'em_producao'),
(6, 4, 2, 'Horizonte - Lançamento Residencial',     '2025-04-28', '2025-07-25', 1800.00, 'encerrada'),
(7, 5, 1, 'Clínica Vitalis - Google Local',         '2025-05-08', '2025-08-05', 500.00,  'encerrada');

INSERT INTO ativo_criativo (ativo_id, campanha_id, tipo, url_arquivo, versao, status) VALUES
(1, 1, 'imagem',    '/criativos/technova/banner_google_01.png',      1, 'aprovado'),
(2, 2, 'video',     '/criativos/technova/reels_meta_01.mp4',         1, 'aprovado'),
(3, 3, 'carrossel', '/criativos/saborarte/carrossel_delivery_01.png',1, 'pendente'),
(4, 4, 'texto',     '/criativos/studiofit/copy_leads_01.txt',        2, 'aprovado'),
(5, 6, 'imagem',    '/criativos/horizonte/banner_lancamento_01.png', 1, 'recusado'),
(6, 6, 'imagem',    '/criativos/horizonte/banner_lancamento_02.png', 2, 'aprovado');

INSERT INTO aprovacao (aprovacao_id, ativo_id, contato_id, status, comentario, data_aprovacao) VALUES
(1, 1, 1, 'aprovado', 'Aprovado, ótimo contraste.',              '2025-02-06 11:20:00'),
(2, 2, 1, 'aprovado', NULL,                                       '2025-02-06 11:25:00'),
(3, 3, 3, 'pendente', NULL,                                       '2025-03-01 09:00:00'),
(4, 4, 4, 'aprovado', 'Pode seguir para veiculação.',             '2025-03-13 15:10:00'),
(5, 5, 5, 'recusado', 'Cores fora do padrão visual da marca.',    '2025-04-29 14:00:00'),
(6, 6, 5, 'aprovado', 'Agora sim, aprovado para publicação.',     '2025-05-02 10:30:00');

INSERT INTO metrica (metrica_id, campanha_id, data_referencia, impressoes, cliques, conversoes, custo, roi) VALUES
(1, 1, '2025-03-01', 45000, 1200, 85,  620.00, 3.20),
(2, 2, '2025-03-01', 38000,  950, 60,  480.00, 2.75),
(3, 3, '2025-03-05', 22000,  480, 30,  350.00, 1.80),
(4, 4, '2025-03-20', 30000,  900, 120, 1350.00, 4.10),
(5, 6, '2025-05-15', 60000, 1500, 40,  1600.00, 2.50);

-- ------------------------------------------------------------
-- DOMINIO: SUPORTE E AUDITORIA
-- ------------------------------------------------------------

INSERT INTO ticket (ticket_id, usuario_id, contrato_id, assunto, descricao, status, data_abertura, data_fechamento) VALUES
(1, 1, 1, 'Dúvida sobre relatório mensal',            'Cliente questiona a queda de cliques na campanha de março.', 'resolvido',    '2025-03-15 09:30:00', '2025-03-16 17:00:00'),
(2, 2, 2, 'Solicitação de pausa temporária',          'Cliente pede pausa nos anúncios durante reforma da loja.',   'fechado',      '2025-03-20 08:45:00', '2025-03-22 12:00:00'),
(3, 4, 4, 'Reclamação sobre atraso na entrega de criativo', 'Cliente relata atraso na aprovação do banner de lançamento.', 'resolvido', '2025-04-15 10:00:00', '2025-04-17 16:20:00'),
(4, 5, NULL, 'Cancelamento de contrato',              'Cliente solicita encerramento do contrato por motivos financeiros.', 'fechado', '2025-07-28 11:00:00', '2025-08-01 09:00:00'),
(5, 3, 3, 'Ajuste de segmentação de público',         'Cliente pede revisão do público-alvo da campanha de leads.', 'em_andamento', '2025-09-10 14:15:00', NULL);

INSERT INTO log_auditoria (log_id, contrato_id, colaborador_id, entidade_alterada, campo, valor_anterior, valor_novo, data_alteracao) VALUES
(1, 1, 2, 'contrato',        'valor_negociado',          '1890.00', '1750.00', '2025-02-01 09:05:00'),
(2, 3, 2, 'contrato',        'qtd_anuncios_customizado', 'NULL',    '45',      '2025-03-10 13:40:00'),
(3, 4, 4, 'contrato',        'status',                   'ativo',   'renovado','2025-07-20 16:31:00'),
(4, 5, 1, 'contrato',        'status',                   'ativo',   'cancelado','2025-08-01 10:16:00'),
(5, 4, 3, 'ativo_criativo',  'status',                   'recusado','aprovado','2025-05-02 10:31:00');

-- ------------------------------------------------------------
-- REALINHAMENTO DAS SEQUENCES (SERIAL)
-- ------------------------------------------------------------
-- Garante que os próximos INSERTs feitos pela aplicação (sem ID
-- explícito) continuem a partir do maior ID já utilizado acima.

SELECT setval(pg_get_serial_sequence('usuario', 'usuario_id'), (SELECT MAX(usuario_id) FROM usuario));
SELECT setval(pg_get_serial_sequence('colaborador', 'colaborador_id'), (SELECT MAX(colaborador_id) FROM colaborador));
SELECT setval(pg_get_serial_sequence('contato', 'contato_id'), (SELECT MAX(contato_id) FROM contato));
SELECT setval(pg_get_serial_sequence('servico', 'servico_id'), (SELECT MAX(servico_id) FROM servico));
SELECT setval(pg_get_serial_sequence('plataforma', 'plataforma_id'), (SELECT MAX(plataforma_id) FROM plataforma));
SELECT setval(pg_get_serial_sequence('plano', 'plano_id'), (SELECT MAX(plano_id) FROM plano));
SELECT setval(pg_get_serial_sequence('contrato', 'contrato_id'), (SELECT MAX(contrato_id) FROM contrato));
SELECT setval(pg_get_serial_sequence('status_historico', 'status_id'), (SELECT MAX(status_id) FROM status_historico));
SELECT setval(pg_get_serial_sequence('fatura', 'fatura_id'), (SELECT MAX(fatura_id) FROM fatura));
SELECT setval(pg_get_serial_sequence('pagamento', 'pagamento_id'), (SELECT MAX(pagamento_id) FROM pagamento));
SELECT setval(pg_get_serial_sequence('campanha', 'campanha_id'), (SELECT MAX(campanha_id) FROM campanha));
SELECT setval(pg_get_serial_sequence('ativo_criativo', 'ativo_id'), (SELECT MAX(ativo_id) FROM ativo_criativo));
SELECT setval(pg_get_serial_sequence('aprovacao', 'aprovacao_id'), (SELECT MAX(aprovacao_id) FROM aprovacao));
SELECT setval(pg_get_serial_sequence('metrica', 'metrica_id'), (SELECT MAX(metrica_id) FROM metrica));
SELECT setval(pg_get_serial_sequence('ticket', 'ticket_id'), (SELECT MAX(ticket_id) FROM ticket));
SELECT setval(pg_get_serial_sequence('log_auditoria', 'log_id'), (SELECT MAX(log_id) FROM log_auditoria));

COMMIT;
