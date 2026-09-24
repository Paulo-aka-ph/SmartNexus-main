

INSERT INTO usuario
(nome, email, senha, telefone, foto_perfil, data_cadastro)
VALUES
('Paulo Henrique', 'paulo@email.com', 'senha123', '(11) 99999-1111',
 'paulo.jpg', '2026-08-20'),

('Maria Silva', 'maria@email.com', 'senha456', '(11) 98888-2222',
 'maria.jpg', '2026-08-20'),

('João Santos', 'joao@email.com', 'senha789', '(11) 97777-3333',
 NULL, '2026-08-20');



INSERT INTO portfolio
(id_usuario, titulo, descricao, categoria, imagem, data_publicacao)
VALUES
(1,
 'Sistema Web Educacional',
 'Desenvolvimento de uma plataforma web para gerenciamento educacional.',
 'Desenvolvimento Web',
 'sistema-educacional.jpg',
 '2026-08-20'),

(1,
 'Website Institucional',
 'Criação de website institucional moderno e responsivo.',
 'Web Design',
 'website.jpg',
 '2026-08-20'),

(2,
 'Aplicativo Mobile',
 'Aplicativo mobile desenvolvido para gerenciamento de tarefas.',
 'Aplicativos',
 'app-mobile.jpg',
 '2026-08-20');



INSERT INTO feedback
(id_usuario, avaliacao, comentario, data_feedback)
VALUES
(1, 5,
 'Excelente atendimento e ótimo resultado.',
 '2026-08-20'),

(2, 4,
 'O projeto ficou muito bom e atendeu às expectativas.',
 '2026-08-20'),

(3, 5,
 'Profissional muito competente.',
 '2026-08-20');




INSERT INTO configuracao
(id_usuario, nome, foto, senha, idioma, tema, notificacoes)
VALUES
(1,
 'Paulo Henrique',
 'paulo.jpg',
 'senha123',
 'Português',
 'Claro',
 TRUE),

(2,
 'Maria Silva',
 'maria.jpg',
 'senha456',
 'Português',
 'Escuro',
 TRUE),

(3,
 'João Santos',
 NULL,
 'senha789',
 'Português',
 'Claro',
 FALSE);




INSERT INTO suporte
(pergunta, resposta, mensagem, data_abertura)
VALUES
(
 'Como faço para criar uma conta?',
 'Acesse a página de cadastro e preencha seus dados.',
 'Preciso de ajuda para realizar meu cadastro.',
 '2026-08-20'
),

(
 'Como altero minha senha?',
 'Acesse Configurações e selecione a opção de alteração de senha.',
 'Gostaria de alterar minha senha.',
 '2026-08-20'
);




INSERT INTO politica_privacidade
(conteudo, data_atualizacao)
VALUES
(
 'Esta política descreve como os dados dos usuários são coletados,
 armazenados e utilizados pela plataforma SmartNexus.',
 '2026-08-20'
);




INSERT INTO sobre_site
(historia, missao, objetivos, informacoes_empresa)
VALUES
(
 'A SmartNexus foi criada com o objetivo de oferecer soluções
 digitais para profissionais e empresas.',
 
 'Nossa missão é oferecer soluções digitais simples,
 eficientes e acessíveis.',
 
 'Facilitar a divulgação de trabalhos e a comunicação
 entre profissionais e clientes.',
 
 'SmartNexus é uma plataforma voltada para apresentação
 de profissionais, trabalhos e serviços.'
);



INSERT INTO contato
(nome, email, assunto, mensagem, data_envio)
VALUES
(
 'Carlos Oliveira',
 'carlos@email.com',
 'Dúvida sobre o serviço',
 'Gostaria de obter mais informações sobre os serviços.',
 '2026-08-20'
),

(
 'Ana Souza',
 'ana@email.com',
 'Orçamento',
 'Gostaria de solicitar um orçamento.',
 '2026-08-20'
);