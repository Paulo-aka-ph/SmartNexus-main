-- ============================================================
-- DDL - SmartNexus
-- Dialeto: PostgreSQL 13+
-- Gerado a partir do DER e do dicionario de dados do projeto
-- ============================================================
-- Convencoes adotadas:
--   * PK numerica auto-incremental (SERIAL)
--   * A maioria das entidades usa exclusao logica (coluna status);
--     por isso ON DELETE CASCADE foi usado apenas nas tabelas que
--     sao 'detalhe' de outra (ex: fatura/pagamento, campanha/ativo_criativo).
--     Ajuste as clausulas ON DELETE conforme a politica real do negocio.
-- ============================================================
 
BEGIN;
 
-- ------------------------------------------------------------
-- DOMINIO: CLIENTE
-- ------------------------------------------------------------
 
CREATE TABLE usuario (
    usuario_id SERIAL PRIMARY KEY,
    razao_social VARCHAR(150) NOT NULL,
    cnpj VARCHAR(20) NOT NULL UNIQUE,
    email VARCHAR(150) NOT NULL UNIQUE,
    telefone VARCHAR(20) NOT NULL,
    data_cadastro TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
COMMENT ON TABLE usuario IS 'Cliente/empresa que contrata os serviços de marketing.';
COMMENT ON COLUMN usuario.usuario_id IS 'Identificador único do usuário/cliente.';
COMMENT ON COLUMN usuario.razao_social IS 'Nome/razão social da empresa cliente.';
COMMENT ON COLUMN usuario.cnpj IS 'CNPJ da empresa; evita cadastro duplicado.';
COMMENT ON COLUMN usuario.email IS 'E-mail principal de contato comercial/financeiro.';
COMMENT ON COLUMN usuario.telefone IS 'Telefone de contato da empresa.';
COMMENT ON COLUMN usuario.data_cadastro IS 'Data/hora do cadastro.';
 
CREATE TABLE colaborador (
    colaborador_id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    cargo VARCHAR(50) NOT NULL
);
COMMENT ON TABLE colaborador IS 'Funcionário da empresa que presta o serviço (gestor de conta, analista etc.).';
COMMENT ON COLUMN colaborador.colaborador_id IS 'Identificador único do colaborador.';
COMMENT ON COLUMN colaborador.nome IS 'Nome do colaborador.';
COMMENT ON COLUMN colaborador.email IS 'E-mail funcional.';
COMMENT ON COLUMN colaborador.cargo IS 'Função do colaborador.';
 
CREATE TABLE contato (
    contato_id SERIAL PRIMARY KEY,
    usuario_id INTEGER NOT NULL REFERENCES usuario(usuario_id) ON DELETE CASCADE,
    nome VARCHAR(150) NOT NULL,
    cargo VARCHAR(100),
    email VARCHAR(150) NOT NULL,
    telefone VARCHAR(20),
    is_financeiro BOOLEAN NOT NULL DEFAULT FALSE,
    is_aprovador BOOLEAN NOT NULL DEFAULT FALSE
);
COMMENT ON TABLE contato IS 'Pessoa de contato de um usuário/cliente (pode haver várias por empresa).';
COMMENT ON COLUMN contato.contato_id IS 'Identificador único do contato.';
COMMENT ON COLUMN contato.usuario_id IS 'Empresa cliente a que o contato pertence.';
COMMENT ON COLUMN contato.nome IS 'Nome completo do contato.';
COMMENT ON COLUMN contato.cargo IS 'Cargo/função do contato na empresa.';
COMMENT ON COLUMN contato.email IS 'E-mail direto do contato.';
COMMENT ON COLUMN contato.telefone IS 'Telefone direto do contato.';
COMMENT ON COLUMN contato.is_financeiro IS 'Indica se recebe faturas/cobranças.';
COMMENT ON COLUMN contato.is_aprovador IS 'Indica se pode aprovar/recusar criativos.';
 
-- ------------------------------------------------------------
-- DOMINIO: CATALOGO E PLANOS
-- ------------------------------------------------------------
 
CREATE TABLE servico (
    servico_id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    descricao TEXT,
    categoria VARCHAR(50) NOT NULL
);
COMMENT ON TABLE servico IS 'Serviço de marketing oferecido pela empresa (catálogo).';
COMMENT ON COLUMN servico.servico_id IS 'Identificador único do serviço.';
COMMENT ON COLUMN servico.nome IS 'Nome do serviço.';
COMMENT ON COLUMN servico.descricao IS 'Detalhamento do que o serviço entrega.';
COMMENT ON COLUMN servico.categoria IS 'Agrupamento do serviço (ex: tráfego pago, SEO).';
 
CREATE TABLE plataforma (
    plataforma_id SERIAL PRIMARY KEY,
    nome VARCHAR(50) NOT NULL UNIQUE,
    tipo VARCHAR(30) NOT NULL
);
COMMENT ON TABLE plataforma IS 'Plataforma de veiculação de anúncios (catálogo).';
COMMENT ON COLUMN plataforma.plataforma_id IS 'Identificador único da plataforma.';
COMMENT ON COLUMN plataforma.nome IS 'Nome da plataforma (Google Ads, Meta Ads etc.).';
COMMENT ON COLUMN plataforma.tipo IS 'Classificação da plataforma (busca, social, display, vídeo).';
 
CREATE TABLE plano (
    plano_id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    descricao TEXT,
    qtd_anuncios_max INTEGER NOT NULL CHECK (qtd_anuncios_max > 0),
    preco_base NUMERIC(10,2) NOT NULL CHECK (preco_base >= 0),
    periodicidade VARCHAR(20) NOT NULL CHECK (periodicidade IN ('mensal','trimestral','semestral','anual')),
    ativo BOOLEAN NOT NULL DEFAULT TRUE
);
COMMENT ON TABLE plano IS 'Pacote comercial padrão vendido pela empresa.';
COMMENT ON COLUMN plano.plano_id IS 'Identificador único do plano.';
COMMENT ON COLUMN plano.nome IS 'Nome comercial do plano.';
COMMENT ON COLUMN plano.descricao IS 'Descrição do que o plano inclui.';
COMMENT ON COLUMN plano.qtd_anuncios_max IS 'Limite padrão de anúncios do plano.';
COMMENT ON COLUMN plano.preco_base IS 'Preço padrão antes de negociação.';
COMMENT ON COLUMN plano.periodicidade IS 'Ciclo de cobrança padrão.';
COMMENT ON COLUMN plano.ativo IS 'Indica se o plano ainda pode ser vendido.';
 
CREATE TABLE plano_plataforma (
    plano_id INTEGER NOT NULL REFERENCES plano(plano_id) ON DELETE CASCADE,
    plataforma_id INTEGER NOT NULL REFERENCES plataforma(plataforma_id) ON DELETE CASCADE,
    PRIMARY KEY (plano_id, plataforma_id)
);
COMMENT ON TABLE plano_plataforma IS 'Associativa N:N entre plano e plataforma.';
COMMENT ON COLUMN plano_plataforma.plano_id IS 'Plano incluído.';
COMMENT ON COLUMN plano_plataforma.plataforma_id IS 'Plataforma incluída no plano.';
 
CREATE TABLE plano_servico (
    plano_id INTEGER NOT NULL REFERENCES plano(plano_id) ON DELETE CASCADE,
    servico_id INTEGER NOT NULL REFERENCES servico(servico_id) ON DELETE CASCADE,
    PRIMARY KEY (plano_id, servico_id)
);
COMMENT ON TABLE plano_servico IS 'Associativa N:N entre plano e serviço.';
COMMENT ON COLUMN plano_servico.plano_id IS 'Plano incluído.';
COMMENT ON COLUMN plano_servico.servico_id IS 'Serviço incluído no plano.';
 
-- ------------------------------------------------------------
-- DOMINIO: CONTRATACAO
-- ------------------------------------------------------------
 
CREATE TABLE contrato (
    contrato_id SERIAL PRIMARY KEY,
    usuario_id INTEGER NOT NULL REFERENCES usuario(usuario_id) ON DELETE RESTRICT,
    plano_id INTEGER NOT NULL REFERENCES plano(plano_id) ON DELETE RESTRICT,
    colaborador_id INTEGER REFERENCES colaborador(colaborador_id) ON DELETE SET NULL,
    data_inicio DATE NOT NULL,
    data_fim DATE,
    status VARCHAR(30) NOT NULL DEFAULT 'proposta' CHECK (status IN ('proposta','ativo','pausado','cancelado','renovado')),
    valor_negociado NUMERIC(10,2) NOT NULL CHECK (valor_negociado >= 0),
    qtd_anuncios_customizado INTEGER CHECK (qtd_anuncios_customizado IS NULL OR qtd_anuncios_customizado > 0),
    observacoes TEXT,
    CHECK (data_fim IS NULL OR data_fim >= data_inicio)
);
COMMENT ON TABLE contrato IS 'Contratação de um plano por um cliente; núcleo do sistema.';
COMMENT ON COLUMN contrato.contrato_id IS 'Identificador único do contrato.';
COMMENT ON COLUMN contrato.usuario_id IS 'Cliente que firmou o contrato.';
COMMENT ON COLUMN contrato.plano_id IS 'Plano-base do contrato.';
COMMENT ON COLUMN contrato.colaborador_id IS 'Gestor de conta responsável.';
COMMENT ON COLUMN contrato.data_inicio IS 'Início da vigência contratual.';
COMMENT ON COLUMN contrato.data_fim IS 'Fim da vigência (nulo = prazo indeterminado).';
COMMENT ON COLUMN contrato.status IS 'Situação atual do contrato.';
COMMENT ON COLUMN contrato.valor_negociado IS 'Valor efetivamente fechado.';
COMMENT ON COLUMN contrato.qtd_anuncios_customizado IS 'Sobrescreve o limite padrão do plano, se negociado.';
COMMENT ON COLUMN contrato.observacoes IS 'Anotações livres sobre o contrato.';
 
CREATE TABLE status_historico (
    status_id SERIAL PRIMARY KEY,
    contrato_id INTEGER NOT NULL REFERENCES contrato(contrato_id) ON DELETE CASCADE,
    colaborador_id INTEGER REFERENCES colaborador(colaborador_id) ON DELETE SET NULL,
    status_anterior VARCHAR(30) NOT NULL,
    status_novo VARCHAR(30) NOT NULL,
    data_alteracao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
COMMENT ON TABLE status_historico IS 'Histórico de mudanças de status de um contrato.';
COMMENT ON COLUMN status_historico.status_id IS 'Identificador único do registro.';
COMMENT ON COLUMN status_historico.contrato_id IS 'Contrato alterado.';
COMMENT ON COLUMN status_historico.colaborador_id IS 'Colaborador que realizou a alteração.';
COMMENT ON COLUMN status_historico.status_anterior IS 'Status antes da alteração.';
COMMENT ON COLUMN status_historico.status_novo IS 'Status após a alteração.';
COMMENT ON COLUMN status_historico.data_alteracao IS 'Momento da mudança.';
 
-- ------------------------------------------------------------
-- DOMINIO: FINANCEIRO
-- ------------------------------------------------------------
 
CREATE TABLE fatura (
    fatura_id SERIAL PRIMARY KEY,
    contrato_id INTEGER NOT NULL REFERENCES contrato(contrato_id) ON DELETE CASCADE,
    valor NUMERIC(10,2) NOT NULL CHECK (valor >= 0),
    data_vencimento DATE NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'pendente' CHECK (status IN ('pendente','paga','atrasada','cancelada')),
    competencia VARCHAR(10) NOT NULL
);
COMMENT ON TABLE fatura IS 'Cobrança devida referente a um contrato em um período.';
COMMENT ON COLUMN fatura.fatura_id IS 'Identificador único da fatura.';
COMMENT ON COLUMN fatura.contrato_id IS 'Contrato cobrado.';
COMMENT ON COLUMN fatura.valor IS 'Valor devido no período.';
COMMENT ON COLUMN fatura.data_vencimento IS 'Data limite de pagamento.';
COMMENT ON COLUMN fatura.status IS 'Situação da fatura.';
COMMENT ON COLUMN fatura.competencia IS 'Mês/ano de referência (ex: 2026-09).';
 
CREATE TABLE pagamento (
    pagamento_id SERIAL PRIMARY KEY,
    fatura_id INTEGER NOT NULL REFERENCES fatura(fatura_id) ON DELETE CASCADE,
    tipo_pagamento VARCHAR(30) NOT NULL,
    valor_pago NUMERIC(10,2) NOT NULL CHECK (valor_pago >= 0),
    data_pagamento DATE,
    status VARCHAR(20) NOT NULL DEFAULT 'pendente' CHECK (status IN ('confirmado','pendente','estornado')),
    comprovante_url VARCHAR(255)
);
COMMENT ON TABLE pagamento IS 'Transação de pagamento referente a uma fatura (pode haver mais de uma por fatura).';
COMMENT ON COLUMN pagamento.pagamento_id IS 'Identificador único do pagamento.';
COMMENT ON COLUMN pagamento.fatura_id IS 'Fatura relacionada.';
COMMENT ON COLUMN pagamento.tipo_pagamento IS 'Meio utilizado (boleto, cartão, PIX etc.).';
COMMENT ON COLUMN pagamento.valor_pago IS 'Valor efetivamente recebido.';
COMMENT ON COLUMN pagamento.data_pagamento IS 'Data em que o pagamento foi confirmado.';
COMMENT ON COLUMN pagamento.status IS 'Situação do pagamento.';
COMMENT ON COLUMN pagamento.comprovante_url IS 'Endereço do comprovante anexado.';
 
-- ------------------------------------------------------------
-- DOMINIO: EXECUCAO DE CAMPANHAS
-- ------------------------------------------------------------
 
CREATE TABLE campanha (
    campanha_id SERIAL PRIMARY KEY,
    contrato_id INTEGER NOT NULL REFERENCES contrato(contrato_id) ON DELETE CASCADE,
    plataforma_id INTEGER NOT NULL REFERENCES plataforma(plataforma_id) ON DELETE RESTRICT,
    nome VARCHAR(100) NOT NULL,
    data_inicio DATE NOT NULL,
    data_fim DATE,
    orcamento NUMERIC(10,2) NOT NULL CHECK (orcamento >= 0),
    status VARCHAR(20) NOT NULL DEFAULT 'em_producao' CHECK (status IN ('em_producao','em_aprovacao','ativa','pausada','encerrada')),
    CHECK (data_fim IS NULL OR data_fim >= data_inicio)
);
COMMENT ON TABLE campanha IS 'Execução real de publicidade em uma plataforma, dentro de um contrato.';
COMMENT ON COLUMN campanha.campanha_id IS 'Identificador único da campanha.';
COMMENT ON COLUMN campanha.contrato_id IS 'Contrato que autoriza a campanha.';
COMMENT ON COLUMN campanha.plataforma_id IS 'Plataforma de veiculação.';
COMMENT ON COLUMN campanha.nome IS 'Nome interno da campanha.';
COMMENT ON COLUMN campanha.data_inicio IS 'Início da veiculação.';
COMMENT ON COLUMN campanha.data_fim IS 'Fim previsto/real da veiculação.';
COMMENT ON COLUMN campanha.orcamento IS 'Orçamento alocado à campanha.';
COMMENT ON COLUMN campanha.status IS 'Situação da campanha.';
 
CREATE TABLE ativo_criativo (
    ativo_id SERIAL PRIMARY KEY,
    campanha_id INTEGER NOT NULL REFERENCES campanha(campanha_id) ON DELETE CASCADE,
    tipo VARCHAR(30) NOT NULL,
    url_arquivo VARCHAR(255) NOT NULL,
    versao INTEGER NOT NULL DEFAULT 1 CHECK (versao > 0),
    status VARCHAR(20) NOT NULL DEFAULT 'pendente' CHECK (status IN ('pendente','aprovado','recusado'))
);
COMMENT ON TABLE ativo_criativo IS 'Peça criativa (imagem, vídeo, copy) usada em uma campanha.';
COMMENT ON COLUMN ativo_criativo.ativo_id IS 'Identificador único da peça criativa.';
COMMENT ON COLUMN ativo_criativo.campanha_id IS 'Campanha a que a peça pertence.';
COMMENT ON COLUMN ativo_criativo.tipo IS 'Tipo de material: imagem, vídeo, texto/copy.';
COMMENT ON COLUMN ativo_criativo.url_arquivo IS 'Endereço do arquivo armazenado.';
COMMENT ON COLUMN ativo_criativo.versao IS 'Versão da peça.';
COMMENT ON COLUMN ativo_criativo.status IS 'Situação da peça.';
 
CREATE TABLE aprovacao (
    aprovacao_id SERIAL PRIMARY KEY,
    ativo_id INTEGER NOT NULL REFERENCES ativo_criativo(ativo_id) ON DELETE CASCADE,
    contato_id INTEGER NOT NULL REFERENCES contato(contato_id) ON DELETE RESTRICT,
    status VARCHAR(20) NOT NULL DEFAULT 'pendente' CHECK (status IN ('aprovado','recusado','pendente')),
    comentario TEXT,
    data_aprovacao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
COMMENT ON TABLE aprovacao IS 'Decisão do cliente sobre uma peça criativa.';
COMMENT ON COLUMN aprovacao.aprovacao_id IS 'Identificador único do registro de aprovação.';
COMMENT ON COLUMN aprovacao.ativo_id IS 'Peça avaliada.';
COMMENT ON COLUMN aprovacao.contato_id IS 'Contato que decidiu.';
COMMENT ON COLUMN aprovacao.status IS 'Resultado da avaliação.';
COMMENT ON COLUMN aprovacao.comentario IS 'Justificativa opcional.';
COMMENT ON COLUMN aprovacao.data_aprovacao IS 'Momento da decisão.';
 
CREATE TABLE metrica (
    metrica_id SERIAL PRIMARY KEY,
    campanha_id INTEGER NOT NULL REFERENCES campanha(campanha_id) ON DELETE CASCADE,
    data_referencia DATE NOT NULL,
    impressoes INTEGER NOT NULL DEFAULT 0 CHECK (impressoes >= 0),
    cliques INTEGER NOT NULL DEFAULT 0 CHECK (cliques >= 0),
    conversoes INTEGER NOT NULL DEFAULT 0 CHECK (conversoes >= 0),
    custo NUMERIC(10,2) NOT NULL DEFAULT 0 CHECK (custo >= 0),
    roi NUMERIC(10,2),
    UNIQUE (campanha_id, data_referencia)
);
COMMENT ON TABLE metrica IS 'Indicadores de desempenho de uma campanha em um período.';
COMMENT ON COLUMN metrica.metrica_id IS 'Identificador único do registro de métrica.';
COMMENT ON COLUMN metrica.campanha_id IS 'Campanha de origem.';
COMMENT ON COLUMN metrica.data_referencia IS 'Data/período de referência.';
COMMENT ON COLUMN metrica.impressoes IS 'Total de exibições no período.';
COMMENT ON COLUMN metrica.cliques IS 'Total de cliques no período.';
COMMENT ON COLUMN metrica.conversoes IS 'Total de conversões no período.';
COMMENT ON COLUMN metrica.custo IS 'Valor investido no período.';
COMMENT ON COLUMN metrica.roi IS 'Retorno sobre investimento calculado.';
 
-- ------------------------------------------------------------
-- DOMINIO: SUPORTE E AUDITORIA
-- ------------------------------------------------------------
 
CREATE TABLE ticket (
    ticket_id SERIAL PRIMARY KEY,
    usuario_id INTEGER NOT NULL REFERENCES usuario(usuario_id) ON DELETE CASCADE,
    contrato_id INTEGER REFERENCES contrato(contrato_id) ON DELETE SET NULL,
    assunto VARCHAR(150) NOT NULL,
    descricao TEXT NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'aberto' CHECK (status IN ('aberto','em_andamento','resolvido','fechado')),
    data_abertura TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    data_fechamento TIMESTAMP
);
COMMENT ON TABLE ticket IS 'Solicitação/atendimento aberto por um cliente.';
COMMENT ON COLUMN ticket.ticket_id IS 'Identificador único do chamado.';
COMMENT ON COLUMN ticket.usuario_id IS 'Cliente que abriu o chamado.';
COMMENT ON COLUMN ticket.contrato_id IS 'Contrato relacionado, quando aplicável.';
COMMENT ON COLUMN ticket.assunto IS 'Título curto da solicitação.';
COMMENT ON COLUMN ticket.descricao IS 'Detalhamento do pedido/reclamação.';
COMMENT ON COLUMN ticket.status IS 'Situação do chamado.';
COMMENT ON COLUMN ticket.data_abertura IS 'Momento da abertura.';
COMMENT ON COLUMN ticket.data_fechamento IS 'Momento do encerramento.';
 
CREATE TABLE log_auditoria (
    log_id SERIAL PRIMARY KEY,
    contrato_id INTEGER NOT NULL REFERENCES contrato(contrato_id) ON DELETE CASCADE,
    colaborador_id INTEGER REFERENCES colaborador(colaborador_id) ON DELETE SET NULL,
    entidade_alterada VARCHAR(50) NOT NULL,
    campo VARCHAR(50) NOT NULL,
    valor_anterior VARCHAR(255),
    valor_novo VARCHAR(255),
    data_alteracao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
COMMENT ON TABLE log_auditoria IS 'Registro de alterações feitas em um contrato, para rastreabilidade.';
COMMENT ON COLUMN log_auditoria.log_id IS 'Identificador único do registro de auditoria.';
COMMENT ON COLUMN log_auditoria.contrato_id IS 'Contrato afetado.';
COMMENT ON COLUMN log_auditoria.colaborador_id IS 'Responsável pela alteração.';
COMMENT ON COLUMN log_auditoria.entidade_alterada IS 'Tabela/entidade que sofreu a alteração.';
COMMENT ON COLUMN log_auditoria.campo IS 'Campo específico alterado.';
COMMENT ON COLUMN log_auditoria.valor_anterior IS 'Valor do campo antes da alteração.';
COMMENT ON COLUMN log_auditoria.valor_novo IS 'Valor do campo após a alteração.';
COMMENT ON COLUMN log_auditoria.data_alteracao IS 'Momento da alteração.';
 
-- ------------------------------------------------------------
-- INDICES em chaves estrangeiras
-- ------------------------------------------------------------
 
CREATE INDEX idx_contato_usuario_id ON contato (usuario_id);
CREATE INDEX idx_contrato_usuario_id ON contrato (usuario_id);
CREATE INDEX idx_contrato_plano_id ON contrato (plano_id);
CREATE INDEX idx_contrato_colaborador_id ON contrato (colaborador_id);
CREATE INDEX idx_status_historico_contrato_id ON status_historico (contrato_id);
CREATE INDEX idx_status_historico_colaborador_id ON status_historico (colaborador_id);
CREATE INDEX idx_fatura_contrato_id ON fatura (contrato_id);
CREATE INDEX idx_pagamento_fatura_id ON pagamento (fatura_id);
CREATE INDEX idx_campanha_contrato_id ON campanha (contrato_id);
CREATE INDEX idx_campanha_plataforma_id ON campanha (plataforma_id);
CREATE INDEX idx_ativo_criativo_campanha_id ON ativo_criativo (campanha_id);
CREATE INDEX idx_aprovacao_ativo_id ON aprovacao (ativo_id);
CREATE INDEX idx_aprovacao_contato_id ON aprovacao (contato_id);
CREATE INDEX idx_metrica_campanha_id ON metrica (campanha_id);
CREATE INDEX idx_ticket_usuario_id ON ticket (usuario_id);
CREATE INDEX idx_ticket_contrato_id ON ticket (contrato_id);
CREATE INDEX idx_log_auditoria_contrato_id ON log_auditoria (contrato_id);
CREATE INDEX idx_log_auditoria_colaborador_id ON log_auditoria (colaborador_id);


CREATE TABLE demanda (
    demanda_id      INTEGER PRIMARY KEY AUTOINCREMENT,
    nome_projeto    VARCHAR(100) NOT NULL,
    empresa         VARCHAR(150) NOT NULL,
    segmento        VARCHAR(50),
    responsavel     VARCHAR(100) NOT NULL,
    cnpj            VARCHAR(18),
    email           VARCHAR(150) NOT NULL,
    telefone        VARCHAR(20)  NOT NULL,
    plano           VARCHAR(20)  NOT NULL CHECK (plano IN ('prata','gold','diamond','indefinido')),
    tipo            VARCHAR(20)  NOT NULL CHECK (tipo IN ('site','marketing','ambos')),
    orcamento       VARCHAR(20),
    prazo           VARCHAR(20),
    descricao       TEXT         NOT NULL,
    endereco_site   VARCHAR(100),
    objetivo        VARCHAR(20),
    material        VARCHAR(20),
    publico         VARCHAR(150),
    regiao          VARCHAR(100),
    perfil_instagram VARCHAR(60),
    verba           VARCHAR(20),
    logo            VARCHAR(10),
    cores           VARCHAR(100),
    referencias     TEXT,
    basicas         TEXT,   -- lista em JSON, ex.: ["home","sobre"]
    adicionais      TEXT,   -- lista em JSON
    plataformas     TEXT,   -- lista em JSON
    estilo          TEXT,   -- lista em JSON
    status          VARCHAR(20)  NOT NULL DEFAULT 'nova'
                    CHECK (status IN ('nova','em_analise','proposta_enviada','aprovada','recusada')),
    data_criacao    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMIT;
