--------------------------------------------------------------------------------
-- REMOTEREADY - GLOBAL SOLUTION - BANCO DE DADOS
-- Disciplina: MASTERING RELATIONAL AND NON-RELATIONAL DATABASE
-- Aluno: Alexsandro Macedo - RM 557068
-- Tema: O Futuro do Trabalho (Educação + Marketplace Remoto)
--------------------------------------------------------------------------------

SET SERVEROUTPUT ON SIZE 1000000;
SET VERIFY OFF;

PROMPT ========================================;
PROMPT  REMOTEREADY - Iniciando script BD
PROMPT ========================================;

--------------------------------------------------------------------------------
-- LIMPEZA DO AMBIENTE
--------------------------------------------------------------------------------
PROMPT Removendo estruturas existentes...

-- Remover Package primeiro
BEGIN EXECUTE IMMEDIATE 'DROP PACKAGE PKG_REMOTEREADY'; EXCEPTION WHEN OTHERS THEN NULL; END;
/

-- Remover tabelas
BEGIN EXECUTE IMMEDIATE 'DROP TABLE TB_GS_USER_POST CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE TB_GS_CERTIFICADO CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE TB_GS_BLOG_POST CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE TB_GS_EMPRESA CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE TB_GS_USUARIO CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE TB_GS_AUDITORIA CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE TB_GS_CHAT_HISTORY CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE TB_GS_EXPORT_LOG CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/

-- Remover sequences
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE SEQ_TB_GS_USUARIO'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE SEQ_TB_GS_EMPRESA'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE SEQ_TB_GS_POST'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE SEQ_TB_GS_CERTIFICADO'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE SEQ_TB_GS_AUDITORIA'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE SEQ_TB_GS_EXPORT'; EXCEPTION WHEN OTHERS THEN NULL; END;
/

PROMPT Limpeza concluída!

--------------------------------------------------------------------------------
-- CRIAÇÃO DAS TABELAS (3FN - Terceira Forma Normal)
--------------------------------------------------------------------------------
PROMPT Criando estrutura de tabelas...

-- 1. USUÁRIO (entidade principal)
CREATE TABLE TB_GS_USUARIO (
    ID_USUARIO     NUMBER(8)       NOT NULL,
    NM_USUARIO     VARCHAR2(100)   NOT NULL,
    DS_EMAIL       VARCHAR2(150)   NOT NULL,
    DS_PASSWORD    VARCHAR2(100)   NOT NULL,
    TP_PERFIL      VARCHAR2(50)    DEFAULT 'JUNIOR',
    TP_ROLE        VARCHAR2(20)    DEFAULT 'USER' NOT NULL,
    NR_EXPERIENCIA NUMBER(2)       DEFAULT 0,
    VL_AVALIACAO   NUMBER(3,2),
    DT_CRIACAO     DATE            DEFAULT SYSDATE,
    FL_ATIVO       CHAR(1)         DEFAULT 'Y' CHECK (FL_ATIVO IN ('Y','N')),
    
    CONSTRAINT PK_GS_USUARIO PRIMARY KEY (ID_USUARIO),
    CONSTRAINT UK_GS_USUARIO_EMAIL UNIQUE (DS_EMAIL),
    CONSTRAINT CK_GS_USUARIO_ROLE CHECK (TP_ROLE IN ('USER','ADMIN')),
    CONSTRAINT CK_GS_USUARIO_PERFIL CHECK (TP_PERFIL IN ('JUNIOR','PLENO','SENIOR')),
    CONSTRAINT CK_GS_USUARIO_EXP CHECK (NR_EXPERIENCIA >= 0),
    CONSTRAINT CK_GS_USUARIO_AVAL CHECK (VL_AVALIACAO BETWEEN 1.0 AND 5.0)
);

CREATE SEQUENCE SEQ_TB_GS_USUARIO START WITH 1 INCREMENT BY 1 CACHE 20;

-- Índices para performance (com proteção contra duplicatas)
BEGIN
    EXECUTE IMMEDIATE 'CREATE INDEX IDX_GS_USUARIO_EMAIL ON TB_GS_USUARIO(DS_EMAIL)';
    DBMS_OUTPUT.PUT_LINE('✓ Índice IDX_GS_USUARIO_EMAIL criado');
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -1408 THEN
            DBMS_OUTPUT.PUT_LINE('• Índice IDX_GS_USUARIO_EMAIL já existe');
        ELSE
            RAISE;
        END IF;
END;
/

-- 2. EMPRESA (parceiras para vagas remotas)
CREATE TABLE TB_GS_EMPRESA (
    ID_EMPRESA     NUMBER(8)      NOT NULL,
    NM_EMPRESA     VARCHAR2(150)  NOT NULL,
    DS_AREA        VARCHAR2(100),
    FL_HIRING_NOW  CHAR(1)        DEFAULT 'N' CHECK (FL_HIRING_NOW IN ('Y','N')),
    DS_WEBSITE     VARCHAR2(200),
    DT_CRIACAO     DATE           DEFAULT SYSDATE,
    
    CONSTRAINT PK_GS_EMPRESA PRIMARY KEY (ID_EMPRESA)
);

CREATE SEQUENCE SEQ_TB_GS_EMPRESA START WITH 1 INCREMENT BY 1 CACHE 20;

-- 3. BLOG_POST (conteúdo educacional - só ADMIN cria)
CREATE TABLE TB_GS_BLOG_POST (
    ID_POST            NUMBER(8)       NOT NULL,
    DS_TITULO          VARCHAR2(200)   NOT NULL,
    DS_DESCRICAO       VARCHAR2(2000)  NOT NULL,
    DS_IMAGE_URL       VARCHAR2(400),
    DS_TAG             VARCHAR2(50),
    ID_USUARIO_CRIADOR NUMBER(8)       NOT NULL,
    QT_VISUALIZACOES   NUMBER(8)       DEFAULT 0,
    DT_CRIACAO         DATE            DEFAULT SYSDATE,
    
    CONSTRAINT PK_GS_POST PRIMARY KEY (ID_POST),
    CONSTRAINT FK_POST_USUARIO FOREIGN KEY (ID_USUARIO_CRIADOR)
        REFERENCES TB_GS_USUARIO(ID_USUARIO) ON DELETE CASCADE
);

CREATE SEQUENCE SEQ_TB_GS_POST START WITH 1 INCREMENT BY 1 CACHE 20;

-- Índices para performance
BEGIN
    EXECUTE IMMEDIATE 'CREATE INDEX IDX_GS_POST_TAG ON TB_GS_BLOG_POST(DS_TAG)';
    DBMS_OUTPUT.PUT_LINE('✓ Índice IDX_GS_POST_TAG criado');
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -1408 THEN
            DBMS_OUTPUT.PUT_LINE('• Índice IDX_GS_POST_TAG já existe');
        ELSE
            RAISE;
        END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'CREATE INDEX IDX_GS_POST_CRIADOR ON TB_GS_BLOG_POST(ID_USUARIO_CRIADOR)';
    DBMS_OUTPUT.PUT_LINE('✓ Índice IDX_GS_POST_CRIADOR criado');
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -1408 THEN
            DBMS_OUTPUT.PUT_LINE('• Índice IDX_GS_POST_CRIADOR já existe');
        ELSE
            RAISE;
        END IF;
END;
/

-- 4. CERTIFICADO (gamificação por engajamento)
CREATE TABLE TB_GS_CERTIFICADO (
    ID_CERTIFICADO NUMBER(8)      NOT NULL,
    ID_USUARIO     NUMBER(8)      NOT NULL,
    DS_TITULO      VARCHAR2(150)  NOT NULL,
    DS_DESCRICAO   VARCHAR2(500),
    DT_EMISSAO     DATE           DEFAULT SYSDATE,
    
    CONSTRAINT PK_GS_CERTIFICADO PRIMARY KEY (ID_CERTIFICADO),
    CONSTRAINT FK_CERT_USUARIO FOREIGN KEY (ID_USUARIO)
        REFERENCES TB_GS_USUARIO(ID_USUARIO) ON DELETE CASCADE
);

CREATE SEQUENCE SEQ_TB_GS_CERTIFICADO START WITH 1 INCREMENT BY 1 CACHE 20;

-- Índices para performance
BEGIN
    EXECUTE IMMEDIATE 'CREATE INDEX IDX_GS_CERT_USUARIO ON TB_GS_CERTIFICADO(ID_USUARIO)';
    DBMS_OUTPUT.PUT_LINE('✓ Índice IDX_GS_CERT_USUARIO criado');
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -1408 THEN
            DBMS_OUTPUT.PUT_LINE('• Índice IDX_GS_CERT_USUARIO já existe');
        ELSE
            RAISE;
        END IF;
END;
/

-- 5. USER_POST (registro de leitura de posts pelos usuários)
CREATE TABLE TB_GS_USER_POST (
    ID_USER_POST   NUMBER(6)      GENERATED BY DEFAULT AS IDENTITY,
    ID_USUARIO     NUMBER(6)      NOT NULL,
    ID_POST        NUMBER(6)      NOT NULL,
    DS_STATUS      VARCHAR2(20)   NOT NULL,
    DT_LEITURA     DATE           DEFAULT SYSDATE NOT NULL,
    
    CONSTRAINT PK_TB_GS_USER_POST PRIMARY KEY (ID_USER_POST),
    CONSTRAINT UQ_TB_GS_USER_POST UNIQUE (ID_USUARIO, ID_POST),
    CONSTRAINT FK_USER_POST_USUARIO FOREIGN KEY (ID_USUARIO)
        REFERENCES TB_GS_USUARIO(ID_USUARIO) ON DELETE CASCADE,
    CONSTRAINT FK_USER_POST_POST FOREIGN KEY (ID_POST)
        REFERENCES TB_GS_BLOG_POST(ID_POST) ON DELETE CASCADE,
    CONSTRAINT CK_USER_POST_STATUS CHECK (DS_STATUS IN ('LIDO', 'EM_PROGRESSO', 'NAO_LIDO'))
);

-- Índices para performance
BEGIN
    EXECUTE IMMEDIATE 'CREATE INDEX IDX_GS_USER_POST_USUARIO ON TB_GS_USER_POST(ID_USUARIO)';
    DBMS_OUTPUT.PUT_LINE('✓ Índice IDX_GS_USER_POST_USUARIO criado');
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -1408 THEN
            DBMS_OUTPUT.PUT_LINE('• Índice IDX_GS_USER_POST_USUARIO já existe');
        ELSE
            RAISE;
        END IF;
END;
/

-- 6. AUDITORIA (trigger automático para rastreamento)
CREATE TABLE TB_GS_AUDITORIA (
    ID_AUDITORIA   NUMBER(10)     NOT NULL,
    NM_TABELA      VARCHAR2(50)   NOT NULL,
    TP_OPERACAO    VARCHAR2(10)   NOT NULL,
    ID_REGISTRO    NUMBER(10),
    NM_USUARIO_DB  VARCHAR2(50),
    DS_DADOS_OLD   VARCHAR2(4000),
    DS_DADOS_NEW   VARCHAR2(4000),
    DT_OPERACAO    DATE           DEFAULT SYSDATE,
    
    CONSTRAINT PK_GS_AUDITORIA PRIMARY KEY (ID_AUDITORIA)
);

CREATE SEQUENCE SEQ_TB_GS_AUDITORIA START WITH 1 INCREMENT BY 1 CACHE 50;

-- Índices para performance
BEGIN
    EXECUTE IMMEDIATE 'CREATE INDEX IDX_GS_AUD_TABELA ON TB_GS_AUDITORIA(NM_TABELA)';
    DBMS_OUTPUT.PUT_LINE('✓ Índice IDX_GS_AUD_TABELA criado');
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -1408 THEN
            DBMS_OUTPUT.PUT_LINE('• Índice IDX_GS_AUD_TABELA já existe');
        ELSE
            RAISE;
        END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'CREATE INDEX IDX_GS_AUD_DATA ON TB_GS_AUDITORIA(DT_OPERACAO)';
    DBMS_OUTPUT.PUT_LINE('✓ Índice IDX_GS_AUD_DATA criado');
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -1408 THEN
            DBMS_OUTPUT.PUT_LINE('• Índice IDX_GS_AUD_DATA já existe');
        ELSE
            RAISE;
        END IF;
END;
/

-- ========================================================================
-- TABELA 9: HISTÓRICO DE CONVERSAS DO CHAT
-- ========================================================================
BEGIN
    EXECUTE IMMEDIATE '
CREATE TABLE TB_GS_CHAT_HISTORY (
    ID_CHAT       NUMBER GENERATED BY DEFAULT AS IDENTITY
                  CONSTRAINT PK_TB_GS_CHAT_HISTORY PRIMARY KEY,

    ID_USUARIO    NUMBER(6)    NOT NULL
                  CONSTRAINT FK_TB_GS_CHAT_HISTORY_USUARIO
                  REFERENCES TB_GS_USUARIO(ID_USUARIO),

    DS_PROMPT     CLOB         NOT NULL,
    DS_RESPONSE   CLOB,

    DT_CRIACAO    DATE         DEFAULT SYSDATE NOT NULL
)';
    DBMS_OUTPUT.PUT_LINE('✓ Tabela TB_GS_CHAT_HISTORY criada');
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -955 THEN
            DBMS_OUTPUT.PUT_LINE('• Tabela TB_GS_CHAT_HISTORY já existe');
        ELSE
            RAISE;
        END IF;
END;
/

-- Índice para performance do histórico
BEGIN
    EXECUTE IMMEDIATE 'CREATE INDEX IDX_GS_CHAT_USUARIO ON TB_GS_CHAT_HISTORY(ID_USUARIO)';
    DBMS_OUTPUT.PUT_LINE('✓ Índice IDX_GS_CHAT_USUARIO criado');
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -1408 THEN
            DBMS_OUTPUT.PUT_LINE('• Índice IDX_GS_CHAT_USUARIO já existe');
        ELSE
            RAISE;
        END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'CREATE INDEX IDX_GS_CHAT_DATA ON TB_GS_CHAT_HISTORY(DT_CRIACAO)';
    DBMS_OUTPUT.PUT_LINE('✓ Índice IDX_GS_CHAT_DATA criado');
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -1408 THEN
            DBMS_OUTPUT.PUT_LINE('• Índice IDX_GS_CHAT_DATA já existe');
        ELSE
            RAISE;
        END IF;
END;
/

BEGIN
    DBMS_OUTPUT.PUT_LINE('✓ Tabela TB_GS_CHAT_HISTORY criada com sucesso!');
END;
/

-- 7. EXPORT_LOG (controle de exportações para MongoDB)
CREATE TABLE TB_GS_EXPORT_LOG (
    ID_EXPORT      NUMBER(8)      NOT NULL,
    DT_GERACAO     DATE           DEFAULT SYSDATE,
    TP_EXPORT      VARCHAR2(50)   DEFAULT 'FULL',
    QT_REGISTROS   NUMBER(8),
    DS_DATASET_JSON CLOB,
    FL_SUCESSO     CHAR(1)        DEFAULT 'N' CHECK (FL_SUCESSO IN ('Y','N')),
    DS_OBSERVACAO  VARCHAR2(500),
    
    CONSTRAINT PK_GS_EXPORT PRIMARY KEY (ID_EXPORT)
);

CREATE SEQUENCE SEQ_TB_GS_EXPORT START WITH 1 INCREMENT BY 1 CACHE 10;

PROMPT Tabelas criadas com sucesso!

--------------------------------------------------------------------------------
-- PACKAGE REMOTEREADY (empacotamento conforme requisito)
--------------------------------------------------------------------------------
PROMPT Criando Package PKG_REMOTEREADY...

CREATE OR REPLACE PACKAGE PKG_REMOTEREADY AS
    
    -- ========================================================================
    -- PROCEDURE 1: HISTÓRICO ESPECIALIZADO DO USUÁRIO (Requisito: 15 pontos)
    -- Foco: Sistema de histórico completo ao invés de CRUD tradicional
    -- ========================================================================
    
    PROCEDURE PRC_HISTORICO_USUARIO(
        P_ID_USUARIO IN NUMBER,
        P_TIPO_HISTORICO IN VARCHAR2 DEFAULT 'COMPLETO' -- COMPLETO, POSTS, CHAT, AUDITORIA
    );
    
    PROCEDURE PRC_INSERIR_CHAT_HISTORY(
        P_ID_USUARIO IN NUMBER,
        P_PROMPT     IN CLOB,
        P_RESPONSE   IN CLOB DEFAULT NULL,
        P_ID_OUT     OUT NUMBER
    );
    
    PROCEDURE PRC_ATUALIZAR_CHAT_RESPONSE(
        P_ID_CHAT    IN NUMBER,
        P_RESPONSE   IN CLOB
    );
    
    PROCEDURE PRC_BUSCAR_HISTORICO_CHAT(
        P_ID_USUARIO IN NUMBER,
        P_LIMITE     IN NUMBER DEFAULT 10
    );
    
    PROCEDURE PRC_LIMPAR_HISTORICO_ANTIGO(
        P_ID_USUARIO IN NUMBER,
        P_DIAS_ANTES IN NUMBER DEFAULT 365
    );
    -- ========================================================================
    -- PROCEDURES AUXILIARES (para funcionamento do sistema)
    -- ========================================================================
    
    PROCEDURE PRC_INSERIR_POST(
        P_TITULO    IN VARCHAR2,
        P_DESCRICAO IN VARCHAR2,
        P_TAG       IN VARCHAR2,
        P_ID_CRIADOR IN NUMBER,
        P_ID_OUT    OUT NUMBER
    );
    
    PROCEDURE PRC_INSERIR_USUARIO(
        P_NOME      IN VARCHAR2,
        P_EMAIL     IN VARCHAR2,
        P_PASSWORD  IN VARCHAR2,
        P_ROLE      IN VARCHAR2 DEFAULT 'USER',
        P_ID_OUT    OUT NUMBER
    );
    
    PROCEDURE PRC_INSERIR_EMPRESA(
        P_NOME      IN VARCHAR2,
        P_AREA      IN VARCHAR2,
        P_HIRING    IN CHAR DEFAULT 'N',
        P_WEBSITE   IN VARCHAR2 DEFAULT NULL,
        P_ID_OUT    OUT NUMBER
    );
    
    -- ========================================================================
    -- PROCEDURE 2: RELATÓRIOS E ANÁLISES (Requisito: 15 pontos)
    -- ========================================================================
    PROCEDURE PRC_RELATORIO_ENGAJAMENTO(
        P_DIAS IN NUMBER DEFAULT 30
    );
    
    PROCEDURE PRC_REGISTRAR_LEITURA(
        P_ID_USUARIO IN NUMBER,
        P_ID_POST    IN NUMBER,
        P_STATUS     IN VARCHAR2 DEFAULT 'LIDO'
    );
    
    -- ========================================================================
    -- FUNÇÃO 1: TRANSFORMAÇÃO DE DADOS (Requisito: 15 pontos)
    -- Retorna JSON completo do perfil do usuário
    -- ========================================================================
    FUNCTION FN_USER_PROFILE_JSON(
        P_ID_USUARIO IN NUMBER
    ) RETURN CLOB;
    
    -- ========================================================================
    -- FUNÇÃO 2: COMPATIBILIDADE COM TRABALHO REMOTO (Requisito: 15 pontos)
    -- Verifica se usuário leu 10+ posts (retorna Y ou N)
    -- ========================================================================
    FUNCTION FN_CALC_COMPATIBILIDADE(
        P_ID_USUARIO IN NUMBER
    ) RETURN VARCHAR2;
    
    FUNCTION FN_VALIDAR_EMAIL(
        P_EMAIL IN VARCHAR2
    ) RETURN VARCHAR2;
    
    -- ========================================================================
    -- INTEGRAÇÃO NOSQL (Requisito: 10 pontos)
    -- ========================================================================
    PROCEDURE PRC_EXPORT_MONGODB(
        P_TIPO IN VARCHAR2 DEFAULT 'FULL'
    );
    
    -- Procedimento para gerar scripts SPOOL de exportação JSON
    PROCEDURE PRC_GERAR_SCRIPTS_EXPORT;

END PKG_REMOTEREADY;
/

PROMPT Package specification criada!

CREATE OR REPLACE PACKAGE BODY PKG_REMOTEREADY AS

    -- ========================================================================
    -- PROCEDURE 1.1: HISTÓRICO COMPLETO DO USUÁRIO
    -- ========================================================================
    PROCEDURE PRC_HISTORICO_USUARIO(
        P_ID_USUARIO IN NUMBER,
        P_TIPO_HISTORICO IN VARCHAR2 DEFAULT 'COMPLETO'
    ) AS
        V_COUNT NUMBER;
        V_NOME VARCHAR2(100);
        V_EMAIL VARCHAR2(150);
        V_ROLE VARCHAR2(20);
        V_DT_CRIACAO DATE;
    BEGIN
        -- Verificar se usuário existe
        SELECT COUNT(*) INTO V_COUNT FROM TB_GS_USUARIO WHERE ID_USUARIO = P_ID_USUARIO;
        IF V_COUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20004, 'Usuário não encontrado');
        END IF;
        
        -- Buscar dados básicos do usuário
        SELECT NM_USUARIO, DS_EMAIL, TP_ROLE, DT_CRIACAO 
        INTO V_NOME, V_EMAIL, V_ROLE, V_DT_CRIACAO
        FROM TB_GS_USUARIO 
        WHERE ID_USUARIO = P_ID_USUARIO;
        
        DBMS_OUTPUT.PUT_LINE('========================================');
        DBMS_OUTPUT.PUT_LINE('HISTÓRICO DO USUÁRIO ID: ' || P_ID_USUARIO);
        DBMS_OUTPUT.PUT_LINE('========================================');
        DBMS_OUTPUT.PUT_LINE('Nome: ' || V_NOME);
        DBMS_OUTPUT.PUT_LINE('Email: ' || V_EMAIL);
        DBMS_OUTPUT.PUT_LINE('Role: ' || V_ROLE);
        DBMS_OUTPUT.PUT_LINE('Data Criação: ' || TO_CHAR(V_DT_CRIACAO, 'DD/MM/YYYY HH24:MI:SS'));
        DBMS_OUTPUT.PUT_LINE('========================================');
        
        -- Histórico de Posts (se for ADMIN)
        IF P_TIPO_HISTORICO IN ('COMPLETO', 'POSTS') THEN
            DBMS_OUTPUT.PUT_LINE('POSTS CRIADOS:');
            FOR post_rec IN (
                SELECT ID_POST, DS_TITULO, DS_TAG, DT_CRIACAO
                FROM TB_GS_BLOG_POST 
                WHERE ID_USUARIO_CRIADOR = P_ID_USUARIO
                ORDER BY DT_CRIACAO DESC
            ) LOOP
                DBMS_OUTPUT.PUT_LINE('• Post ' || post_rec.ID_POST || ': ' || post_rec.DS_TITULO || 
                                   ' [' || post_rec.DS_TAG || '] - ' || 
                                   TO_CHAR(post_rec.DT_CRIACAO, 'DD/MM/YYYY'));
            END LOOP;
            DBMS_OUTPUT.PUT_LINE('----------------------------------------');
        END IF;
        
        -- Histórico de Chat
        IF P_TIPO_HISTORICO IN ('COMPLETO', 'CHAT') THEN
            DBMS_OUTPUT.PUT_LINE('HISTÓRICO DE CONVERSAS:');
            FOR chat_rec IN (
                SELECT ID_CHAT, SUBSTR(DS_PROMPT, 1, 50) AS PROMPT_SHORT, DT_CRIACAO
                FROM TB_GS_CHAT_HISTORY 
                WHERE ID_USUARIO = P_ID_USUARIO
                ORDER BY DT_CRIACAO DESC
                FETCH FIRST 10 ROWS ONLY
            ) LOOP
                DBMS_OUTPUT.PUT_LINE('• Chat ' || chat_rec.ID_CHAT || ': "' || 
                                   chat_rec.PROMPT_SHORT || '..." - ' ||
                                   TO_CHAR(chat_rec.DT_CRIACAO, 'DD/MM/YYYY HH24:MI'));
            END LOOP;
            DBMS_OUTPUT.PUT_LINE('----------------------------------------');
        END IF;
        
        -- Histórico de Auditoria
        IF P_TIPO_HISTORICO IN ('COMPLETO', 'AUDITORIA') THEN
            DBMS_OUTPUT.PUT_LINE('ÚLTIMAS ATIVIDADES (AUDITORIA):');
            FOR aud_rec IN (
                SELECT NM_TABELA, TP_OPERACAO, DT_OPERACAO
                FROM TB_GS_AUDITORIA 
                WHERE ID_REGISTRO = P_ID_USUARIO
                ORDER BY DT_OPERACAO DESC
                FETCH FIRST 5 ROWS ONLY
            ) LOOP
                DBMS_OUTPUT.PUT_LINE('• ' || aud_rec.TP_OPERACAO || ' em ' || 
                                   aud_rec.NM_TABELA || ' - ' ||
                                   TO_CHAR(aud_rec.DT_OPERACAO, 'DD/MM/YYYY HH24:MI:SS'));
            END LOOP;
        END IF;
        
        DBMS_OUTPUT.PUT_LINE('========================================');
        
    EXCEPTION
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20020, 'Erro ao gerar histórico: ' || SQLERRM);
    END PRC_HISTORICO_USUARIO;
    
    -- ========================================================================
    -- PROCEDURE 1.2: INSERIR HISTÓRICO DE CHAT
    -- ========================================================================
    PROCEDURE PRC_INSERIR_CHAT_HISTORY(
        P_ID_USUARIO IN NUMBER,
        P_PROMPT     IN CLOB,
        P_RESPONSE   IN CLOB DEFAULT NULL,
        P_ID_OUT     OUT NUMBER
    ) AS
        V_COUNT NUMBER;
    BEGIN
        -- Verificar se usuário existe
        SELECT COUNT(*) INTO V_COUNT FROM TB_GS_USUARIO WHERE ID_USUARIO = P_ID_USUARIO;
        IF V_COUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20021, 'Usuário não encontrado');
        END IF;
        
        -- Inserir histórico de chat
        INSERT INTO TB_GS_CHAT_HISTORY (
            ID_USUARIO, DS_PROMPT, DS_RESPONSE, DT_CRIACAO
        ) VALUES (
            P_ID_USUARIO, P_PROMPT, P_RESPONSE, SYSDATE
        ) RETURNING ID_CHAT INTO P_ID_OUT;
        
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Histórico de chat criado: ID=' || P_ID_OUT);
        
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20022, 'Erro ao salvar histórico: ' || SQLERRM);
    END PRC_INSERIR_CHAT_HISTORY;
    
    -- ========================================================================
    -- PROCEDURE 1.3: ATUALIZAR RESPOSTA DO CHAT
    -- ========================================================================
    PROCEDURE PRC_ATUALIZAR_CHAT_RESPONSE(
        P_ID_CHAT    IN NUMBER,
        P_RESPONSE   IN CLOB
    ) AS
        V_COUNT NUMBER;
    BEGIN
        -- Verificar se chat existe
        SELECT COUNT(*) INTO V_COUNT FROM TB_GS_CHAT_HISTORY WHERE ID_CHAT = P_ID_CHAT;
        IF V_COUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20023, 'Chat não encontrado');
        END IF;
        
        -- Atualizar resposta
        UPDATE TB_GS_CHAT_HISTORY 
        SET DS_RESPONSE = P_RESPONSE
        WHERE ID_CHAT = P_ID_CHAT;
        
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Resposta do chat atualizada: ID=' || P_ID_CHAT);
        
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20024, 'Erro ao atualizar resposta: ' || SQLERRM);
    END PRC_ATUALIZAR_CHAT_RESPONSE;
    
    -- ========================================================================
    -- PROCEDURE 1.4: BUSCAR HISTÓRICO DE CHAT
    -- ========================================================================
    PROCEDURE PRC_BUSCAR_HISTORICO_CHAT(
        P_ID_USUARIO IN NUMBER,
        P_LIMITE     IN NUMBER DEFAULT 10
    ) AS
        V_COUNT NUMBER;
    BEGIN
        -- Verificar se usuário existe
        SELECT COUNT(*) INTO V_COUNT FROM TB_GS_USUARIO WHERE ID_USUARIO = P_ID_USUARIO;
        IF V_COUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20025, 'Usuário não encontrado');
        END IF;
        
        DBMS_OUTPUT.PUT_LINE('========================================');
        DBMS_OUTPUT.PUT_LINE('HISTÓRICO DE CHAT - USUÁRIO ' || P_ID_USUARIO);
        DBMS_OUTPUT.PUT_LINE('========================================');
        
        FOR chat_rec IN (
            SELECT ID_CHAT, SUBSTR(DS_PROMPT, 1, 100) AS PROMPT_SHORT, 
                   SUBSTR(NVL(DS_RESPONSE, 'Sem resposta'), 1, 100) AS RESPONSE_SHORT,
                   TO_CHAR(DT_CRIACAO, 'DD/MM/YYYY HH24:MI:SS') AS DATA_CHAT
            FROM TB_GS_CHAT_HISTORY 
            WHERE ID_USUARIO = P_ID_USUARIO
            ORDER BY DT_CRIACAO DESC
            FETCH FIRST P_LIMITE ROWS ONLY
        ) LOOP
            DBMS_OUTPUT.PUT_LINE('• Chat ' || chat_rec.ID_CHAT || ' (' || chat_rec.DATA_CHAT || ')');
            DBMS_OUTPUT.PUT_LINE('  Pergunta: ' || chat_rec.PROMPT_SHORT || '...');
            DBMS_OUTPUT.PUT_LINE('  Resposta: ' || chat_rec.RESPONSE_SHORT || '...');
            DBMS_OUTPUT.PUT_LINE('----------------------------------------');
        END LOOP;
        
    EXCEPTION
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20026, 'Erro ao buscar histórico: ' || SQLERRM);
    END PRC_BUSCAR_HISTORICO_CHAT;
    
    -- ========================================================================
    -- PROCEDURE 1.5: LIMPAR HISTÓRICO ANTIGO
    -- ========================================================================
    PROCEDURE PRC_LIMPAR_HISTORICO_ANTIGO(
        P_ID_USUARIO IN NUMBER,
        P_DIAS_ANTES IN NUMBER DEFAULT 365
    ) AS
        V_COUNT NUMBER;
        V_DELETED NUMBER;
    BEGIN
        -- Verificar se usuário existe
        SELECT COUNT(*) INTO V_COUNT FROM TB_GS_USUARIO WHERE ID_USUARIO = P_ID_USUARIO;
        IF V_COUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20027, 'Usuário não encontrado');
        END IF;
        
        -- Deletar conversas antigas
        DELETE FROM TB_GS_CHAT_HISTORY 
        WHERE ID_USUARIO = P_ID_USUARIO 
        AND DT_CRIACAO < SYSDATE - P_DIAS_ANTES;
        
        V_DELETED := SQL%ROWCOUNT;
        COMMIT;
        
        DBMS_OUTPUT.PUT_LINE('Histórico limpo: ' || V_DELETED || ' conversas removidas (>' || P_DIAS_ANTES || ' dias)');
        
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20028, 'Erro ao limpar histórico: ' || SQLERRM);
    END PRC_LIMPAR_HISTORICO_ANTIGO;
    
    -- ========================================================================
    -- PROCEDURE 1.3: INSERIR USUÁRIO (MANTIDA PARA TESTES)
    -- ========================================================================
    PROCEDURE PRC_INSERIR_USUARIO(
        P_NOME      IN VARCHAR2,
        P_EMAIL     IN VARCHAR2,
        P_PASSWORD  IN VARCHAR2,
        P_ROLE      IN VARCHAR2 DEFAULT 'USER',
        P_ID_OUT    OUT NUMBER
    ) AS
        V_EMAIL_VALIDO VARCHAR2(10);
    BEGIN
        -- Validar email com REGEXP
        V_EMAIL_VALIDO := FN_VALIDAR_EMAIL(P_EMAIL);
        
        IF V_EMAIL_VALIDO = 'INVALIDO' THEN
            RAISE_APPLICATION_ERROR(-20001, 'Email inválido: ' || P_EMAIL);
        END IF;
        
        -- Inserir usuário
        INSERT INTO TB_GS_USUARIO (
            ID_USUARIO, NM_USUARIO, DS_EMAIL, DS_PASSWORD, TP_ROLE
        ) VALUES (
            SEQ_TB_GS_USUARIO.NEXTVAL, P_NOME, P_EMAIL, P_PASSWORD, P_ROLE
        ) RETURNING ID_USUARIO INTO P_ID_OUT;
        
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Usuário criado: ID=' || P_ID_OUT || ' Email=' || P_EMAIL);
        
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            RAISE_APPLICATION_ERROR(-20002, 'Email já cadastrado: ' || P_EMAIL);
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20003, 'Erro ao inserir usuário: ' || SQLERRM);
    END PRC_INSERIR_USUARIO;
    
    -- ========================================================================
    -- PROCEDURE 1.2: INSERIR HISTÓRICO DE CHAT
    -- ========================================================================
    -- PROCEDURE 1.3: INSERIR POST (COM VALIDAÇÃO DE ADMIN)
    -- ========================================================================
    PROCEDURE PRC_INSERIR_POST(
        P_TITULO    IN VARCHAR2,
        P_DESCRICAO IN VARCHAR2,
        P_TAG       IN VARCHAR2,
        P_ID_CRIADOR IN NUMBER,
        P_ID_OUT    OUT NUMBER
    ) AS
        V_ROLE VARCHAR2(20);
    BEGIN
        -- Verificar se criador é ADMIN
        SELECT TP_ROLE INTO V_ROLE
        FROM TB_GS_USUARIO
        WHERE ID_USUARIO = P_ID_CRIADOR;
        
        IF V_ROLE != 'ADMIN' THEN
            RAISE_APPLICATION_ERROR(-20009, 'Apenas ADMIN pode criar posts');
        END IF;
        
        -- Inserir post
        INSERT INTO TB_GS_BLOG_POST (
            ID_POST, DS_TITULO, DS_DESCRICAO, DS_TAG, ID_USUARIO_CRIADOR
        ) VALUES (
            SEQ_TB_GS_POST.NEXTVAL, P_TITULO, P_DESCRICAO, P_TAG, P_ID_CRIADOR
        ) RETURNING ID_POST INTO P_ID_OUT;
        
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Post criado: ID=' || P_ID_OUT);
        
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20010, 'Usuário criador não encontrado');
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20011, 'Erro ao criar post: ' || SQLERRM);
    END PRC_INSERIR_POST;
    
    -- ========================================================================
    -- PROCEDURE 1.5: INSERIR EMPRESA (CRUD)
    -- ========================================================================
    PROCEDURE PRC_INSERIR_EMPRESA(
        P_NOME      IN VARCHAR2,
        P_AREA      IN VARCHAR2,
        P_HIRING    IN CHAR DEFAULT 'N',
        P_WEBSITE   IN VARCHAR2 DEFAULT NULL,
        P_ID_OUT    OUT NUMBER
    ) AS
    BEGIN
        INSERT INTO TB_GS_EMPRESA (
            ID_EMPRESA, NM_EMPRESA, DS_AREA, FL_HIRING_NOW, DS_WEBSITE
        ) VALUES (
            SEQ_TB_GS_EMPRESA.NEXTVAL, P_NOME, P_AREA, P_HIRING, P_WEBSITE
        ) RETURNING ID_EMPRESA INTO P_ID_OUT;
        
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Empresa criada: ID=' || P_ID_OUT);
        
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20012, 'Erro ao criar empresa: ' || SQLERRM);
    END PRC_INSERIR_EMPRESA;
    
    -- ========================================================================
    -- PROCEDURE 2.1: RELATÓRIO DE ENGAJAMENTO (Análise)
    -- ========================================================================
    PROCEDURE PRC_RELATORIO_ENGAJAMENTO(
        P_DIAS IN NUMBER DEFAULT 30
    ) AS
        V_DT_INICIO DATE := SYSDATE - P_DIAS;
        V_TOTAL_USUARIOS NUMBER;
        V_TOTAL_POSTS NUMBER;
        V_TOTAL_LEITURAS NUMBER;
        V_TOTAL_CERTIFICADOS NUMBER;
    BEGIN
        DBMS_OUTPUT.PUT_LINE('========================================');
        DBMS_OUTPUT.PUT_LINE('RELATÓRIO DE ENGAJAMENTO - Últimos ' || P_DIAS || ' dias');
        DBMS_OUTPUT.PUT_LINE('Período: ' || TO_CHAR(V_DT_INICIO, 'DD/MM/YYYY') || ' até ' || TO_CHAR(SYSDATE, 'DD/MM/YYYY'));
        DBMS_OUTPUT.PUT_LINE('========================================');
        
        -- Total de usuários ativos
        SELECT COUNT(*) INTO V_TOTAL_USUARIOS
        FROM TB_GS_USUARIO
        WHERE DT_CRIACAO >= V_DT_INICIO AND FL_ATIVO = 'Y';
        
        DBMS_OUTPUT.PUT_LINE('Novos usuários: ' || V_TOTAL_USUARIOS);
        
        -- Total de posts criados
        SELECT COUNT(*) INTO V_TOTAL_POSTS
        FROM TB_GS_BLOG_POST
        WHERE DT_CRIACAO >= V_DT_INICIO;
        
        DBMS_OUTPUT.PUT_LINE('Novos posts: ' || V_TOTAL_POSTS);
        
        -- Total de leituras
        SELECT COUNT(*) INTO V_TOTAL_LEITURAS
        FROM TB_GS_USER_POST
        WHERE DT_LEITURA >= V_DT_INICIO
        AND DS_STATUS = 'LIDO';
        
        DBMS_OUTPUT.PUT_LINE('Total de leituras: ' || V_TOTAL_LEITURAS);
        
        -- Total de certificados emitidos
        SELECT COUNT(*) INTO V_TOTAL_CERTIFICADOS
        FROM TB_GS_CERTIFICADO
        WHERE DT_EMISSAO >= V_DT_INICIO;
        
        DBMS_OUTPUT.PUT_LINE('Certificados emitidos: ' || V_TOTAL_CERTIFICADOS);
        
        -- Top 5 posts mais lidos
        DBMS_OUTPUT.PUT_LINE('');
        DBMS_OUTPUT.PUT_LINE('TOP 5 POSTS MAIS LIDOS:');
        DBMS_OUTPUT.PUT_LINE('----------------------------------------');
        
        FOR R IN (
            SELECT P.DS_TITULO, P.QT_VISUALIZACOES, P.DS_TAG
            FROM TB_GS_BLOG_POST P
            WHERE P.DT_CRIACAO >= V_DT_INICIO
            ORDER BY P.QT_VISUALIZACOES DESC
            FETCH FIRST 5 ROWS ONLY
        ) LOOP
            DBMS_OUTPUT.PUT_LINE('- ' || R.DS_TITULO || ' (' || R.QT_VISUALIZACOES || ' views) [' || R.DS_TAG || ']');
        END LOOP;
        
        DBMS_OUTPUT.PUT_LINE('========================================');
        
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Erro ao gerar relatório: ' || SQLERRM);
    END PRC_RELATORIO_ENGAJAMENTO;
    
    -- ========================================================================
    -- PROCEDURE 2.2: REGISTRAR LEITURA (com auto-certificação)
    -- ========================================================================
    PROCEDURE PRC_REGISTRAR_LEITURA(
        P_ID_USUARIO IN NUMBER,
        P_ID_POST    IN NUMBER,
        P_STATUS     IN VARCHAR2 DEFAULT 'LIDO'
    ) AS
        V_QT_LEITURAS NUMBER;
        V_JA_POSSUI_CERT NUMBER;
        V_ID_USER_POST NUMBER;
    BEGIN
        -- Inserir leitura (idempotente devido ao UNIQUE)
        BEGIN
            INSERT INTO TB_GS_USER_POST (
                ID_USUARIO, ID_POST, DS_STATUS, DT_LEITURA
            ) VALUES (
                P_ID_USUARIO, P_ID_POST, P_STATUS, SYSDATE
            ) RETURNING ID_USER_POST INTO V_ID_USER_POST;
            
            -- Incrementar visualizações do post
            UPDATE TB_GS_BLOG_POST
            SET QT_VISUALIZACOES = QT_VISUALIZACOES + 1
            WHERE ID_POST = P_ID_POST;
            
            DBMS_OUTPUT.PUT_LINE('Leitura registrada: ID=' || V_ID_USER_POST);
            
        EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
                DBMS_OUTPUT.PUT_LINE('Usuário já leu este post anteriormente');
                RETURN; -- Já leu, não precisa reprocessar
        END;
        
        -- Contar total de posts LIDOS pelo usuário
        SELECT COUNT(*) INTO V_QT_LEITURAS
        FROM TB_GS_USER_POST
        WHERE ID_USUARIO = P_ID_USUARIO
        AND DS_STATUS = 'LIDO';
        
        DBMS_OUTPUT.PUT_LINE('Total de posts lidos pelo usuário: ' || V_QT_LEITURAS);
        
        -- Verificar se atingiu 10 leituras e não possui certificado
        IF V_QT_LEITURAS >= 10 THEN
            SELECT COUNT(*) INTO V_JA_POSSUI_CERT
            FROM TB_GS_CERTIFICADO
            WHERE ID_USUARIO = P_ID_USUARIO
            AND DS_TITULO = 'Leitor Ativo - 10+ Posts';
            
            IF V_JA_POSSUI_CERT = 0 THEN
                -- Conceder certificado automaticamente
                INSERT INTO TB_GS_CERTIFICADO (
                    ID_CERTIFICADO, ID_USUARIO, DS_TITULO, DS_DESCRICAO
                ) VALUES (
                    SEQ_TB_GS_CERTIFICADO.NEXTVAL,
                    P_ID_USUARIO,
                    'Leitor Ativo - 10+ Posts',
                    'Parabéns! Você leu 10 ou mais posts sobre trabalho remoto.'
                );
                
                DBMS_OUTPUT.PUT_LINE('*** CERTIFICADO CONCEDIDO: Leitor Ativo - 10+ Posts ***');
            END IF;
        END IF;
        
        COMMIT;
        
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20013, 'Erro ao registrar leitura: ' || SQLERRM);
    END PRC_REGISTRAR_LEITURA;
    
    -- ========================================================================
    -- FUNÇÃO 1: TRANSFORMAÇÃO JSON DO PERFIL (Requisito: 15 pontos)
    -- ========================================================================
    FUNCTION FN_USER_PROFILE_JSON(
        P_ID_USUARIO IN NUMBER
    ) RETURN CLOB AS
        V_JSON CLOB;
        V_USUARIO TB_GS_USUARIO%ROWTYPE;
        V_QT_POSTS_LIDOS NUMBER;
        V_QT_CERTIFICADOS NUMBER;
        V_COMPATIBILIDADE VARCHAR2(1);
        V_FIRST BOOLEAN := TRUE;
    BEGIN
        -- Buscar dados do usuário
        SELECT * INTO V_USUARIO
        FROM TB_GS_USUARIO
        WHERE ID_USUARIO = P_ID_USUARIO;
        
        -- Contar posts lidos
        SELECT COUNT(*) INTO V_QT_POSTS_LIDOS
        FROM TB_GS_USER_POST
        WHERE ID_USUARIO = P_ID_USUARIO
        AND DS_STATUS = 'LIDO';
        
        -- Contar certificados
        SELECT COUNT(*) INTO V_QT_CERTIFICADOS
        FROM TB_GS_CERTIFICADO
        WHERE ID_USUARIO = P_ID_USUARIO;
        
        -- Calcular compatibilidade
        V_COMPATIBILIDADE := FN_CALC_COMPATIBILIDADE(P_ID_USUARIO);
        
        -- Construir JSON manualmente
        DBMS_LOB.CREATETEMPORARY(V_JSON, TRUE);
        
        DBMS_LOB.APPEND(V_JSON, '{');
        DBMS_LOB.APPEND(V_JSON, '"id_usuario":' || P_ID_USUARIO || ',');
        DBMS_LOB.APPEND(V_JSON, '"nome":"' || REPLACE(V_USUARIO.NM_USUARIO, '"', '\"') || '",');
        DBMS_LOB.APPEND(V_JSON, '"email":"' || V_USUARIO.DS_EMAIL || '",');
        DBMS_LOB.APPEND(V_JSON, '"role":"' || V_USUARIO.TP_ROLE || '",');
        DBMS_LOB.APPEND(V_JSON, '"ativo":"' || V_USUARIO.FL_ATIVO || '",');
        DBMS_LOB.APPEND(V_JSON, '"data_criacao":"' || TO_CHAR(V_USUARIO.DT_CRIACAO, 'YYYY-MM-DD') || '",');
        DBMS_LOB.APPEND(V_JSON, '"posts_lidos":' || V_QT_POSTS_LIDOS || ',');
        DBMS_LOB.APPEND(V_JSON, '"certificados":' || V_QT_CERTIFICADOS || ',');
        DBMS_LOB.APPEND(V_JSON, '"compatibilidade_remoto":"' || V_COMPATIBILIDADE || '",');
        
        -- Lista de certificados
        DBMS_LOB.APPEND(V_JSON, '"lista_certificados":[');
        
        FOR R IN (
            SELECT DS_TITULO, DS_DESCRICAO, 
                   TO_CHAR(DT_EMISSAO, 'YYYY-MM-DD') AS DT_EMISSAO
            FROM TB_GS_CERTIFICADO
            WHERE ID_USUARIO = P_ID_USUARIO
            ORDER BY DT_EMISSAO DESC
        ) LOOP
            IF NOT V_FIRST THEN
                DBMS_LOB.APPEND(V_JSON, ',');
            ELSE
                V_FIRST := FALSE;
            END IF;
            
            DBMS_LOB.APPEND(V_JSON, '{');
            DBMS_LOB.APPEND(V_JSON, '"titulo":"' || REPLACE(R.DS_TITULO, '"', '\"') || '",');
            DBMS_LOB.APPEND(V_JSON, '"descricao":"' || REPLACE(NVL(R.DS_DESCRICAO, ''), '"', '\"') || '",');
            DBMS_LOB.APPEND(V_JSON, '"data_emissao":"' || R.DT_EMISSAO || '"');
            DBMS_LOB.APPEND(V_JSON, '}');
        END LOOP;
        
        DBMS_LOB.APPEND(V_JSON, ']');
        DBMS_LOB.APPEND(V_JSON, '}');
        
        RETURN V_JSON;
        
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN '{"erro":"Usuario nao encontrado"}';
        WHEN OTHERS THEN
            RETURN '{"erro":"' || SQLERRM || '"}';
    END FN_USER_PROFILE_JSON;
    
    -- ========================================================================
    -- FUNÇÃO 2.1: VALIDAR EMAIL COM REGEXP (Requisito: 15 pontos)
    -- ========================================================================
    FUNCTION FN_VALIDAR_EMAIL(
        P_EMAIL IN VARCHAR2
    ) RETURN VARCHAR2 AS
    BEGIN
        -- Validação com REGEXP_LIKE
        -- Padrão: texto@texto.texto (simplificado mas funcional)
        IF REGEXP_LIKE(P_EMAIL, '^[a-zA-Z0-9._%-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$') THEN
            RETURN 'VALIDO';
        ELSE
            RETURN 'INVALIDO';
        END IF;
        
    EXCEPTION
        WHEN OTHERS THEN
            RETURN 'ERRO';
    END FN_VALIDAR_EMAIL;
    
    -- ========================================================================
    -- FUNÇÃO 2.2: VERIFICAR COMPATIBILIDADE (Requisito: 15 pontos)
    -- Verifica se usuário leu 10 ou mais posts (retorna 'Y' ou 'N')
    -- Regra: Usuário preparado para trabalho remoto = 10+ posts lidos
    -- ========================================================================
    FUNCTION FN_CALC_COMPATIBILIDADE(
        P_ID_USUARIO IN NUMBER
    ) RETURN VARCHAR2 AS
        V_POSTS_LIDOS NUMBER;
    BEGIN
        -- Contar posts LIDOS pelo usuário
        SELECT COUNT(*) INTO V_POSTS_LIDOS
        FROM TB_GS_USER_POST
        WHERE ID_USUARIO = P_ID_USUARIO
        AND DS_STATUS = 'LIDO';
        
        -- Retornar 'Y' se leu 10 ou mais posts, 'N' caso contrário
        IF V_POSTS_LIDOS >= 10 THEN
            RETURN 'Y';
        ELSE
            RETURN 'N';
        END IF;
        
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN 'N';
        WHEN OTHERS THEN
            RETURN 'N';
    END FN_CALC_COMPATIBILIDADE;
    
    -- ========================================================================
    -- INTEGRAÇÃO NOSQL: EXPORTAR PARA MONGODB (Requisito: 10 pontos)
    -- ========================================================================
    PROCEDURE PRC_EXPORT_MONGODB(
        P_TIPO IN VARCHAR2 DEFAULT 'FULL'
    ) AS
        V_JSON CLOB;
        V_TEMP_JSON CLOB;
        V_FIRST BOOLEAN := TRUE;
        V_COUNT NUMBER := 0;
        V_ID_EXPORT NUMBER;
    BEGIN
        DBMS_OUTPUT.PUT_LINE('========================================');
        DBMS_OUTPUT.PUT_LINE('Iniciando exportação para MongoDB...');
        DBMS_OUTPUT.PUT_LINE('Tipo: ' || P_TIPO);
        DBMS_OUTPUT.PUT_LINE('========================================');
        
        -- Inicializar CLOB
        DBMS_LOB.CREATETEMPORARY(V_JSON, TRUE);
        DBMS_LOB.APPEND(V_JSON, '[');
        
        -- Iterar sobre usuários e gerar JSON de cada um
        FOR R IN (
            SELECT ID_USUARIO
            FROM TB_GS_USUARIO
            WHERE FL_ATIVO = 'Y'
            ORDER BY ID_USUARIO
        ) LOOP
            V_COUNT := V_COUNT + 1;
            
            -- Adicionar vírgula se não for o primeiro
            IF NOT V_FIRST THEN
                DBMS_LOB.APPEND(V_JSON, ',');
            ELSE
                V_FIRST := FALSE;
            END IF;
            
            -- Obter JSON do perfil do usuário
            V_TEMP_JSON := FN_USER_PROFILE_JSON(R.ID_USUARIO);
            DBMS_LOB.APPEND(V_JSON, V_TEMP_JSON);
            
            -- Log a cada 10 registros
            IF MOD(V_COUNT, 10) = 0 THEN
                DBMS_OUTPUT.PUT_LINE('Processados: ' || V_COUNT || ' usuários');
            END IF;
        END LOOP;
        
        -- Fechar array JSON
        DBMS_LOB.APPEND(V_JSON, ']');
        
        -- Salvar no log
        INSERT INTO TB_GS_EXPORT_LOG (
            ID_EXPORT, DT_GERACAO, TP_EXPORT, QT_REGISTROS, 
            DS_DATASET_JSON, FL_SUCESSO, DS_OBSERVACAO
        ) VALUES (
            SEQ_TB_GS_EXPORT.NEXTVAL,
            SYSDATE,
            P_TIPO,
            V_COUNT,
            V_JSON,
            'Y',
            'Exportacao completa - ' || V_COUNT || ' usuarios ativos'
        ) RETURNING ID_EXPORT INTO V_ID_EXPORT;
        
        COMMIT;
        
        DBMS_OUTPUT.PUT_LINE('========================================');
        DBMS_OUTPUT.PUT_LINE('Exportação concluída com sucesso!');
        DBMS_OUTPUT.PUT_LINE('Total de registros: ' || V_COUNT);
        DBMS_OUTPUT.PUT_LINE('ID do Export: ' || V_ID_EXPORT);
        DBMS_OUTPUT.PUT_LINE('========================================');
        DBMS_OUTPUT.PUT_LINE('');
        DBMS_OUTPUT.PUT_LINE('Para extrair o JSON e importar no MongoDB:');
        DBMS_OUTPUT.PUT_LINE('');
        DBMS_OUTPUT.PUT_LINE('1) Extrair JSON do banco:');
        DBMS_OUTPUT.PUT_LINE('   SELECT DS_DATASET_JSON FROM TB_GS_EXPORT_LOG');
        DBMS_OUTPUT.PUT_LINE('   WHERE ID_EXPORT = ' || V_ID_EXPORT || ';');
        DBMS_OUTPUT.PUT_LINE('');
        DBMS_OUTPUT.PUT_LINE('2) Salvar em arquivo: remoteready_export.json');
        DBMS_OUTPUT.PUT_LINE('');
        DBMS_OUTPUT.PUT_LINE('3) Importar no MongoDB:');
        DBMS_OUTPUT.PUT_LINE('   mongoimport --db remoteready --collection users');
        DBMS_OUTPUT.PUT_LINE('   --file remoteready_export.json --jsonArray');
        DBMS_OUTPUT.PUT_LINE('========================================');
        
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('ERRO na exportação: ' || SQLERRM);
            RAISE_APPLICATION_ERROR(-20014, 'Erro na exportação MongoDB: ' || SQLERRM);
    END PRC_EXPORT_MONGODB;

    -- ========================================================================
    -- PROCEDIMENTO PARA GERAR SCRIPTS DE EXPORTAÇÃO JSON
    -- ========================================================================
    -- Gera scripts SPOOL dinâmicos sem hard inserts
    -- Baseado no padrão do arquivo de referência da Sprint 4
    
    PROCEDURE PRC_GERAR_SCRIPTS_EXPORT AS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('-- ============================================================================');
        DBMS_OUTPUT.PUT_LINE('-- SCRIPTS DE EXPORTAÇÃO JSON PARA MONGODB - REMOTEREADY');
        DBMS_OUTPUT.PUT_LINE('-- ============================================================================');
        DBMS_OUTPUT.PUT_LINE('-- Execute cada bloco individualmente no SQL*Plus ou SQLcl');
        DBMS_OUTPUT.PUT_LINE('-- ============================================================================');
        DBMS_OUTPUT.PUT_LINE('');
        
        DBMS_OUTPUT.PUT_LINE('SET SERVEROUTPUT ON SIZE UNLIMITED');
        DBMS_OUTPUT.PUT_LINE('SET LINESIZE 32767');
        DBMS_OUTPUT.PUT_LINE('SET LONG 1000000');
        DBMS_OUTPUT.PUT_LINE('SET PAGESIZE 0');
        DBMS_OUTPUT.PUT_LINE('SET TRIMSPOOL ON');
        DBMS_OUTPUT.PUT_LINE('SET FEEDBACK OFF');
        DBMS_OUTPUT.PUT_LINE('SET HEADING OFF');
        DBMS_OUTPUT.PUT_LINE('');
        
        -- EXPORTAÇÃO DE USUÁRIOS
        DBMS_OUTPUT.PUT_LINE('PROMPT =========================================================================');
        DBMS_OUTPUT.PUT_LINE('PROMPT EXPORTANDO TABELA: TB_GS_USUARIO -> remoteready_usuarios.json');
        DBMS_OUTPUT.PUT_LINE('PROMPT =========================================================================');
        DBMS_OUTPUT.PUT_LINE('SPOOL remoteready_usuarios.json');
        DBMS_OUTPUT.PUT_LINE('DECLARE');
        DBMS_OUTPUT.PUT_LINE('  v_first BOOLEAN := TRUE;');
        DBMS_OUTPUT.PUT_LINE('  v_obj VARCHAR2(32767);');
        DBMS_OUTPUT.PUT_LINE('BEGIN');
        DBMS_OUTPUT.PUT_LINE('  DBMS_OUTPUT.PUT_LINE(''['');');
        DBMS_OUTPUT.PUT_LINE('  FOR r IN (SELECT * FROM TB_GS_USUARIO ORDER BY ID_USUARIO) LOOP');
        DBMS_OUTPUT.PUT_LINE('    IF NOT v_first THEN DBMS_OUTPUT.PUT_LINE('',''); ELSE v_first := FALSE; END IF;');
        DBMS_OUTPUT.PUT_LINE('    v_obj := ''{'' ||');
        DBMS_OUTPUT.PUT_LINE('      ''"id_usuario":'' || TO_CHAR(r.id_usuario) || '','' ||');
        DBMS_OUTPUT.PUT_LINE('      ''"nm_usuario":'' || FN_JSON_ESCAPE(r.nm_usuario) || '','' ||');
        DBMS_OUTPUT.PUT_LINE('      ''"ds_email":'' || FN_JSON_ESCAPE(r.ds_email) || '','' ||');
        DBMS_OUTPUT.PUT_LINE('      ''"tp_perfil":'' || FN_JSON_ESCAPE(r.tp_perfil) || '','' ||');
        DBMS_OUTPUT.PUT_LINE('      ''"tp_role":'' || FN_JSON_ESCAPE(r.tp_role) || '','' ||');
        DBMS_OUTPUT.PUT_LINE('      ''"nr_experiencia":'' || FN_JSON_NUMBER(r.nr_experiencia) || '','' ||');
        DBMS_OUTPUT.PUT_LINE('      ''"vl_avaliacao":'' || FN_JSON_NUMBER(r.vl_avaliacao) || '','' ||');
        DBMS_OUTPUT.PUT_LINE('      ''"fl_ativo":'' || FN_JSON_ESCAPE(r.fl_ativo) || '','' ||');
        DBMS_OUTPUT.PUT_LINE('      ''"dt_criacao":'' || FN_JSON_DATE(r.dt_criacao) ||');
        DBMS_OUTPUT.PUT_LINE('    ''}'';');
        DBMS_OUTPUT.PUT_LINE('    DBMS_OUTPUT.PUT_LINE(v_obj);');
        DBMS_OUTPUT.PUT_LINE('  END LOOP;');
        DBMS_OUTPUT.PUT_LINE('  DBMS_OUTPUT.PUT_LINE('']'');');
        DBMS_OUTPUT.PUT_LINE('END;');
        DBMS_OUTPUT.PUT_LINE('/');
        DBMS_OUTPUT.PUT_LINE('SPOOL OFF');
        DBMS_OUTPUT.PUT_LINE('');
        
        -- EXPORTAÇÃO DE EMPRESAS
        DBMS_OUTPUT.PUT_LINE('PROMPT =========================================================================');
        DBMS_OUTPUT.PUT_LINE('PROMPT EXPORTANDO TABELA: TB_GS_EMPRESA -> remoteready_empresas.json');
        DBMS_OUTPUT.PUT_LINE('PROMPT =========================================================================');
        DBMS_OUTPUT.PUT_LINE('SPOOL remoteready_empresas.json');
        DBMS_OUTPUT.PUT_LINE('DECLARE');
        DBMS_OUTPUT.PUT_LINE('  v_first BOOLEAN := TRUE;');
        DBMS_OUTPUT.PUT_LINE('  v_obj VARCHAR2(32767);');
        DBMS_OUTPUT.PUT_LINE('BEGIN');
        DBMS_OUTPUT.PUT_LINE('  DBMS_OUTPUT.PUT_LINE(''['');');
        DBMS_OUTPUT.PUT_LINE('  FOR r IN (SELECT * FROM TB_GS_EMPRESA ORDER BY ID_EMPRESA) LOOP');
        DBMS_OUTPUT.PUT_LINE('    IF NOT v_first THEN DBMS_OUTPUT.PUT_LINE('',''); ELSE v_first := FALSE; END IF;');
        DBMS_OUTPUT.PUT_LINE('    v_obj := ''{'' ||');
        DBMS_OUTPUT.PUT_LINE('      ''"id_empresa":'' || TO_CHAR(r.id_empresa) || '','' ||');
        DBMS_OUTPUT.PUT_LINE('      ''"nm_empresa":'' || FN_JSON_ESCAPE(r.nm_empresa) || '','' ||');
        DBMS_OUTPUT.PUT_LINE('      ''"ds_setor":'' || FN_JSON_ESCAPE(r.ds_setor) || '','' ||');
        DBMS_OUTPUT.PUT_LINE('      ''"nr_funcionarios":'' || FN_JSON_NUMBER(r.nr_funcionarios) || '','' ||');
        DBMS_OUTPUT.PUT_LINE('      ''"fl_ativo":'' || FN_JSON_ESCAPE(r.fl_ativo) || '','' ||');
        DBMS_OUTPUT.PUT_LINE('      ''"dt_cadastro":'' || FN_JSON_DATE(r.dt_cadastro) ||');
        DBMS_OUTPUT.PUT_LINE('    ''}'';');
        DBMS_OUTPUT.PUT_LINE('    DBMS_OUTPUT.PUT_LINE(v_obj);');
        DBMS_OUTPUT.PUT_LINE('  END LOOP;');
        DBMS_OUTPUT.PUT_LINE('  DBMS_OUTPUT.PUT_LINE('']'');');
        DBMS_OUTPUT.PUT_LINE('END;');
        DBMS_OUTPUT.PUT_LINE('/');
        DBMS_OUTPUT.PUT_LINE('SPOOL OFF');
        DBMS_OUTPUT.PUT_LINE('');
        
        -- EXPORTAÇÃO DE POSTS
        DBMS_OUTPUT.PUT_LINE('PROMPT =========================================================================');
        DBMS_OUTPUT.PUT_LINE('PROMPT EXPORTANDO TABELA: TB_GS_BLOG_POST -> remoteready_blog_posts.json');
        DBMS_OUTPUT.PUT_LINE('PROMPT =========================================================================');
        DBMS_OUTPUT.PUT_LINE('SPOOL remoteready_blog_posts.json');
        DBMS_OUTPUT.PUT_LINE('DECLARE');
        DBMS_OUTPUT.PUT_LINE('  v_first BOOLEAN := TRUE;');
        DBMS_OUTPUT.PUT_LINE('  v_obj VARCHAR2(32767);');
        DBMS_OUTPUT.PUT_LINE('BEGIN');
        DBMS_OUTPUT.PUT_LINE('  DBMS_OUTPUT.PUT_LINE(''['');');
        DBMS_OUTPUT.PUT_LINE('  FOR r IN (SELECT * FROM TB_GS_BLOG_POST ORDER BY ID_POST) LOOP');
        DBMS_OUTPUT.PUT_LINE('    IF NOT v_first THEN DBMS_OUTPUT.PUT_LINE('',''); ELSE v_first := FALSE; END IF;');
        DBMS_OUTPUT.PUT_LINE('    v_obj := ''{'' ||');
        DBMS_OUTPUT.PUT_LINE('      ''"id_post":'' || TO_CHAR(r.id_post) || '','' ||');
        DBMS_OUTPUT.PUT_LINE('      ''"id_usuario":'' || TO_CHAR(r.id_usuario_criador) || '','' ||');
        DBMS_OUTPUT.PUT_LINE('      ''"ds_titulo":'' || FN_JSON_ESCAPE(r.ds_titulo) || '','' ||');
        DBMS_OUTPUT.PUT_LINE('      ''"ds_descricao":'' || FN_JSON_ESCAPE(SUBSTR(r.ds_descricao,1,200)) || '','' ||');
        DBMS_OUTPUT.PUT_LINE('      ''"ds_tag":'' || FN_JSON_ESCAPE(r.ds_tag) || '','' ||');
        DBMS_OUTPUT.PUT_LINE('      ''"qt_visualizacoes":'' || FN_JSON_NUMBER(r.qt_visualizacoes) || '','' ||');
        DBMS_OUTPUT.PUT_LINE('      ''"dt_criacao":'' || FN_JSON_DATE(r.dt_criacao) ||');
        DBMS_OUTPUT.PUT_LINE('    ''}'';');
        DBMS_OUTPUT.PUT_LINE('    DBMS_OUTPUT.PUT_LINE(v_obj);');
        DBMS_OUTPUT.PUT_LINE('  END LOOP;');
        DBMS_OUTPUT.PUT_LINE('  DBMS_OUTPUT.PUT_LINE('']'');');
        DBMS_OUTPUT.PUT_LINE('END;');
        DBMS_OUTPUT.PUT_LINE('/');
        DBMS_OUTPUT.PUT_LINE('SPOOL OFF');
        DBMS_OUTPUT.PUT_LINE('');
        
        -- EXPORTAÇÃO DE CERTIFICADOS
        DBMS_OUTPUT.PUT_LINE('PROMPT =========================================================================');
        DBMS_OUTPUT.PUT_LINE('PROMPT EXPORTANDO TABELA: TB_GS_CERTIFICADO -> remoteready_certificados.json');
        DBMS_OUTPUT.PUT_LINE('PROMPT =========================================================================');
        DBMS_OUTPUT.PUT_LINE('SPOOL remoteready_certificados.json');
        DBMS_OUTPUT.PUT_LINE('DECLARE');
        DBMS_OUTPUT.PUT_LINE('  v_first BOOLEAN := TRUE;');
        DBMS_OUTPUT.PUT_LINE('  v_obj VARCHAR2(32767);');
        DBMS_OUTPUT.PUT_LINE('BEGIN');
        DBMS_OUTPUT.PUT_LINE('  DBMS_OUTPUT.PUT_LINE(''['');');
        DBMS_OUTPUT.PUT_LINE('  FOR r IN (SELECT * FROM TB_GS_CERTIFICADO ORDER BY ID_CERTIFICADO) LOOP');
        DBMS_OUTPUT.PUT_LINE('    IF NOT v_first THEN DBMS_OUTPUT.PUT_LINE('',''); ELSE v_first := FALSE; END IF;');
        DBMS_OUTPUT.PUT_LINE('    v_obj := ''{'' ||');
        DBMS_OUTPUT.PUT_LINE('      ''"id_certificado":'' || TO_CHAR(r.id_certificado) || '','' ||');
        DBMS_OUTPUT.PUT_LINE('      ''"id_usuario":'' || TO_CHAR(r.id_usuario) || '','' ||');
        DBMS_OUTPUT.PUT_LINE('      ''"ds_titulo":'' || FN_JSON_ESCAPE(r.ds_titulo) || '','' ||');
        DBMS_OUTPUT.PUT_LINE('      ''"ds_descricao":'' || FN_JSON_ESCAPE(r.ds_descricao) || '','' ||');
        DBMS_OUTPUT.PUT_LINE('      ''"dt_emissao":'' || FN_JSON_DATE(r.dt_emissao) ||');
        DBMS_OUTPUT.PUT_LINE('    ''}'';');
        DBMS_OUTPUT.PUT_LINE('    DBMS_OUTPUT.PUT_LINE(v_obj);');
        DBMS_OUTPUT.PUT_LINE('  END LOOP;');
        DBMS_OUTPUT.PUT_LINE('  DBMS_OUTPUT.PUT_LINE('']'');');
        DBMS_OUTPUT.PUT_LINE('END;');
        DBMS_OUTPUT.PUT_LINE('/');
        DBMS_OUTPUT.PUT_LINE('SPOOL OFF');
        DBMS_OUTPUT.PUT_LINE('');
        
        -- EXPORTAÇÃO DE USER_POST
        DBMS_OUTPUT.PUT_LINE('PROMPT =========================================================================');
        DBMS_OUTPUT.PUT_LINE('PROMPT EXPORTANDO TABELA: TB_GS_USER_POST -> remoteready_user_posts.json');
        DBMS_OUTPUT.PUT_LINE('PROMPT =========================================================================');
        DBMS_OUTPUT.PUT_LINE('SPOOL remoteready_user_posts.json');
        DBMS_OUTPUT.PUT_LINE('DECLARE');
        DBMS_OUTPUT.PUT_LINE('  v_first BOOLEAN := TRUE;');
        DBMS_OUTPUT.PUT_LINE('  v_obj VARCHAR2(32767);');
        DBMS_OUTPUT.PUT_LINE('BEGIN');
        DBMS_OUTPUT.PUT_LINE('  DBMS_OUTPUT.PUT_LINE(''['');');
        DBMS_OUTPUT.PUT_LINE('  FOR r IN (SELECT * FROM TB_GS_USER_POST ORDER BY ID_USER_POST) LOOP');
        DBMS_OUTPUT.PUT_LINE('    IF NOT v_first THEN DBMS_OUTPUT.PUT_LINE('',''); ELSE v_first := FALSE; END IF;');
        DBMS_OUTPUT.PUT_LINE('    v_obj := ''{'' ||');
        DBMS_OUTPUT.PUT_LINE('      ''"id_user_post":'' || TO_CHAR(r.id_user_post) || '','' ||');
        DBMS_OUTPUT.PUT_LINE('      ''"id_usuario":'' || TO_CHAR(r.id_usuario) || '','' ||');
        DBMS_OUTPUT.PUT_LINE('      ''"id_post":'' || TO_CHAR(r.id_post) || '','' ||');
        DBMS_OUTPUT.PUT_LINE('      ''"ds_status":'' || FN_JSON_ESCAPE(r.ds_status) || '','' ||');
        DBMS_OUTPUT.PUT_LINE('      ''"dt_leitura":'' || FN_JSON_DATE(r.dt_leitura) ||');
        DBMS_OUTPUT.PUT_LINE('    ''}'';');
        DBMS_OUTPUT.PUT_LINE('    DBMS_OUTPUT.PUT_LINE(v_obj);');
        DBMS_OUTPUT.PUT_LINE('  END LOOP;');
        DBMS_OUTPUT.PUT_LINE('  DBMS_OUTPUT.PUT_LINE('']'');');
        DBMS_OUTPUT.PUT_LINE('END;');
        DBMS_OUTPUT.PUT_LINE('/');
        DBMS_OUTPUT.PUT_LINE('SPOOL OFF');
        DBMS_OUTPUT.PUT_LINE('');
        
        -- EXPORTAÇÃO DE CHAT HISTORY
        DBMS_OUTPUT.PUT_LINE('PROMPT =========================================================================');
        DBMS_OUTPUT.PUT_LINE('PROMPT EXPORTANDO TABELA: TB_GS_CHAT_HISTORY -> remoteready_chat_history.json');
        DBMS_OUTPUT.PUT_LINE('PROMPT =========================================================================');
        DBMS_OUTPUT.PUT_LINE('SPOOL remoteready_chat_history.json');
        DBMS_OUTPUT.PUT_LINE('DECLARE');
        DBMS_OUTPUT.PUT_LINE('  v_first BOOLEAN := TRUE;');
        DBMS_OUTPUT.PUT_LINE('  v_obj VARCHAR2(32767);');
        DBMS_OUTPUT.PUT_LINE('BEGIN');
        DBMS_OUTPUT.PUT_LINE('  DBMS_OUTPUT.PUT_LINE(''['');');
        DBMS_OUTPUT.PUT_LINE('  FOR r IN (SELECT * FROM TB_GS_CHAT_HISTORY ORDER BY ID_CHAT) LOOP');
        DBMS_OUTPUT.PUT_LINE('    IF NOT v_first THEN DBMS_OUTPUT.PUT_LINE('',''); ELSE v_first := FALSE; END IF;');
        DBMS_OUTPUT.PUT_LINE('    v_obj := ''{'' ||');
        DBMS_OUTPUT.PUT_LINE('      ''"id_chat":'' || TO_CHAR(r.id_chat) || '','' ||');
        DBMS_OUTPUT.PUT_LINE('      ''"id_usuario":'' || TO_CHAR(r.id_usuario) || '','' ||');
        DBMS_OUTPUT.PUT_LINE('      ''"prompt":'' || FN_JSON_ESCAPE(SUBSTR(r.ds_prompt,1,500)) || '','' ||');
        DBMS_OUTPUT.PUT_LINE('      ''"response":'' || FN_JSON_ESCAPE(SUBSTR(r.ds_response,1,500)) || '','' ||');
        DBMS_OUTPUT.PUT_LINE('      ''"dt_criacao":'' || FN_JSON_DATE(r.dt_criacao) ||');
        DBMS_OUTPUT.PUT_LINE('    ''}'';');
        DBMS_OUTPUT.PUT_LINE('    DBMS_OUTPUT.PUT_LINE(v_obj);');
        DBMS_OUTPUT.PUT_LINE('  END LOOP;');
        DBMS_OUTPUT.PUT_LINE('  DBMS_OUTPUT.PUT_LINE('']'');');
        DBMS_OUTPUT.PUT_LINE('END;');
        DBMS_OUTPUT.PUT_LINE('/');
        DBMS_OUTPUT.PUT_LINE('SPOOL OFF');
        DBMS_OUTPUT.PUT_LINE('');
        
        DBMS_OUTPUT.PUT_LINE('-- ============================================================================');
        DBMS_OUTPUT.PUT_LINE('-- COMANDOS MONGODB PARA IMPORTAÇÃO:');
        DBMS_OUTPUT.PUT_LINE('-- ============================================================================');
        DBMS_OUTPUT.PUT_LINE('-- mongoimport --db remoteready --collection usuarios --file remoteready_usuarios.json --jsonArray');
        DBMS_OUTPUT.PUT_LINE('-- mongoimport --db remoteready --collection empresas --file remoteready_empresas.json --jsonArray');
        DBMS_OUTPUT.PUT_LINE('-- mongoimport --db remoteready --collection blog_posts --file remoteready_blog_posts.json --jsonArray');
        DBMS_OUTPUT.PUT_LINE('-- mongoimport --db remoteready --collection certificados --file remoteready_certificados.json --jsonArray');
        DBMS_OUTPUT.PUT_LINE('-- mongoimport --db remoteready --collection user_posts --file remoteready_user_posts.json --jsonArray');
        DBMS_OUTPUT.PUT_LINE('-- mongoimport --db remoteready --collection chat_history --file remoteready_chat_history.json --jsonArray');
        DBMS_OUTPUT.PUT_LINE('-- ============================================================================');
        
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('ERRO: ' || SQLERRM);
            RAISE_APPLICATION_ERROR(-20019, 'Erro na geração dos scripts: ' || SQLERRM);
    END PRC_GERAR_SCRIPTS_EXPORT;

END PKG_REMOTEREADY;
/

PROMPT Package body criada com sucesso!

-- ========================================================================
-- FUNÇÕES AUXILIARES PARA JSON (independentes)
-- ========================================================================
PROMPT Criando funções auxiliares para JSON...

CREATE OR REPLACE FUNCTION FN_JSON_ESCAPE(p_str IN VARCHAR2)
RETURN VARCHAR2
IS
BEGIN
    IF p_str IS NULL THEN
        RETURN 'null';
    END IF;
    RETURN '"' || REPLACE(REPLACE(REPLACE(p_str, '\', '\\'), '"', '\"'), CHR(10), '\n') || '"';
EXCEPTION
    WHEN OTHERS THEN
        RETURN 'null';
END;
/

CREATE OR REPLACE FUNCTION FN_JSON_NUMBER(p_num IN NUMBER)
RETURN VARCHAR2
IS
BEGIN
    RETURN CASE WHEN p_num IS NULL THEN 'null' ELSE TO_CHAR(p_num) END;
EXCEPTION
    WHEN OTHERS THEN
        RETURN 'null';
END;
/

CREATE OR REPLACE FUNCTION FN_JSON_DATE(p_date IN DATE)
RETURN VARCHAR2
IS
BEGIN
    RETURN CASE 
        WHEN p_date IS NULL THEN 'null' 
        ELSE '"' || TO_CHAR(p_date, 'YYYY-MM-DD"T"HH24:MI:SS') || '"'
    END;
EXCEPTION
    WHEN OTHERS THEN
        RETURN 'null';
END;
/

PROMPT Funções JSON criadas com sucesso!

--------------------------------------------------------------------------------
-- TRIGGER DE AUDITORIA (Requisito: 10 pontos)
--------------------------------------------------------------------------------
PROMPT Criando trigger de auditoria...

CREATE OR REPLACE TRIGGER TRG_AUD_USUARIO
AFTER INSERT OR UPDATE OR DELETE ON TB_GS_USUARIO
FOR EACH ROW
DECLARE
    V_OPERACAO VARCHAR2(10);
    V_OLD_DATA VARCHAR2(4000);
    V_NEW_DATA VARCHAR2(4000);
    V_ID_REGISTRO NUMBER;
BEGIN
    -- Identificar tipo de operação e ID do registro
    IF INSERTING THEN
        V_OPERACAO := 'INSERT';
        V_ID_REGISTRO := :NEW.ID_USUARIO;
        V_NEW_DATA := 'ID=' || :NEW.ID_USUARIO || 
                      ' NOME=' || :NEW.NM_USUARIO || 
                      ' EMAIL=' || :NEW.DS_EMAIL ||
                      ' ROLE=' || :NEW.TP_ROLE;
        
    ELSIF UPDATING THEN
        V_OPERACAO := 'UPDATE';
        V_ID_REGISTRO := :NEW.ID_USUARIO;
        V_OLD_DATA := 'ID=' || :OLD.ID_USUARIO || 
                      ' NOME=' || :OLD.NM_USUARIO || 
                      ' EMAIL=' || :OLD.DS_EMAIL ||
                      ' ROLE=' || :OLD.TP_ROLE;
        V_NEW_DATA := 'ID=' || :NEW.ID_USUARIO || 
                      ' NOME=' || :NEW.NM_USUARIO || 
                      ' EMAIL=' || :NEW.DS_EMAIL ||
                      ' ROLE=' || :NEW.TP_ROLE;
        
    ELSIF DELETING THEN
        V_OPERACAO := 'DELETE';
        V_ID_REGISTRO := :OLD.ID_USUARIO;
        V_OLD_DATA := 'ID=' || :OLD.ID_USUARIO || 
                      ' NOME=' || :OLD.NM_USUARIO || 
                      ' EMAIL=' || :OLD.DS_EMAIL ||
                      ' ROLE=' || :OLD.TP_ROLE;
    END IF;
    
    -- Registrar na auditoria
    INSERT INTO TB_GS_AUDITORIA (
        ID_AUDITORIA, NM_TABELA, TP_OPERACAO, ID_REGISTRO,
        NM_USUARIO_DB, DS_DADOS_OLD, DS_DADOS_NEW, DT_OPERACAO
    ) VALUES (
        SEQ_TB_GS_AUDITORIA.NEXTVAL,
        'TB_GS_USUARIO',
        V_OPERACAO,
        V_ID_REGISTRO,
        USER,
        V_OLD_DATA,
        V_NEW_DATA,
        SYSDATE
    );
    
EXCEPTION
    WHEN OTHERS THEN
        -- Não bloquear operação por erro de auditoria
        NULL;
END;
/

PROMPT Trigger de auditoria criado com sucesso!

--------------------------------------------------------------------------------
-- DADOS DE TESTE
--------------------------------------------------------------------------------
PROMPT Inserindo dados de teste...

DECLARE
    V_ID_USER1 NUMBER;
    V_ID_USER2 NUMBER;
    V_ID_ADMIN NUMBER;
    V_ID_POST1 NUMBER;
    V_ID_POST2 NUMBER;
    V_ID_POST3 NUMBER;
    V_ID_EMP1 NUMBER;
BEGIN
    -- Criar usuário ADMIN
    PKG_REMOTEREADY.PRC_INSERIR_USUARIO(
        'Admin RemoteReady',
        'admin@remoteready.com',
        'admin123',
        'ADMIN',
        V_ID_ADMIN
    );
    
    -- Criar usuários USER
    PKG_REMOTEREADY.PRC_INSERIR_USUARIO(
        'João Silva',
        'joao.silva@email.com',
        'senha123',
        'USER',
        V_ID_USER1
    );
    
    PKG_REMOTEREADY.PRC_INSERIR_USUARIO(
        'Maria Santos',
        'maria.santos@email.com',
        'senha456',
        'USER',
        V_ID_USER2
    );
    
    -- Criar empresas
    PKG_REMOTEREADY.PRC_INSERIR_EMPRESA(
        'TechCorp Brasil',
        'Tecnologia',
        'Y',
        'https://techcorp.com.br',
        V_ID_EMP1
    );
    
    PKG_REMOTEREADY.PRC_INSERIR_EMPRESA(
        'Remote Solutions',
        'Consultoria',
        'N',
        'https://remotesolutions.io',
        V_ID_EMP1
    );
    
    -- Criar posts (apenas ADMIN)
    PKG_REMOTEREADY.PRC_INSERIR_POST(
        'Como iniciar no trabalho remoto',
        'Guia completo para quem está começando a trabalhar remotamente. Dicas essenciais sobre comunicação, produtividade e gestão de tempo.',
        'iniciante',
        V_ID_ADMIN,
        V_ID_POST1
    );
    
    PKG_REMOTEREADY.PRC_INSERIR_POST(
        'Ferramentas essenciais para trabalho remoto',
        'Conheça as principais ferramentas para comunicação, gestão de projetos e colaboração em equipes remotas.',
        'ferramentas',
        V_ID_ADMIN,
        V_ID_POST2
    );
    
    PKG_REMOTEREADY.PRC_INSERIR_POST(
        'Ergonomia no home office',
        'Aprenda a montar um ambiente de trabalho saudável em casa, evitando problemas de saúde.',
        'saude',
        V_ID_ADMIN,
        V_ID_POST3
    );
    
    -- Registrar leituras (João lê 3 posts)
    PKG_REMOTEREADY.PRC_REGISTRAR_LEITURA(V_ID_USER1, V_ID_POST1, 'LIDO');
    PKG_REMOTEREADY.PRC_REGISTRAR_LEITURA(V_ID_USER1, V_ID_POST2, 'LIDO');
    PKG_REMOTEREADY.PRC_REGISTRAR_LEITURA(V_ID_USER1, V_ID_POST3, 'LIDO');
    
    -- Registrar leituras (Maria lê 1 post)
    PKG_REMOTEREADY.PRC_REGISTRAR_LEITURA(V_ID_USER2, V_ID_POST1, 'LIDO');
    
    COMMIT;
    
    DBMS_OUTPUT.PUT_LINE('Dados de teste inseridos com sucesso!');
    DBMS_OUTPUT.PUT_LINE('- 1 Admin, 2 Users');
    DBMS_OUTPUT.PUT_LINE('- 2 Empresas');
    DBMS_OUTPUT.PUT_LINE('- 3 Posts');
    DBMS_OUTPUT.PUT_LINE('- 4 Leituras registradas');
    
END;
/

PROMPT Dados de teste inseridos com sucesso!

--------------------------------------------------------------------------------
-- TESTES FINAIS E DEMONSTRAÇÃO
--------------------------------------------------------------------------------
PROMPT
PROMPT ========================================;
PROMPT EXECUTANDO TESTES DA DISCIPLINA
PROMPT ========================================;
PROMPT

-- TESTE 1: CRUD com Package
PROMPT === TESTE 1: CRUD com Package ===;
DECLARE
    V_ID NUMBER;
BEGIN
    PKG_REMOTEREADY.PRC_INSERIR_USUARIO(
        'Teste BD', 
        'teste.bd@fiap.com.br', 
        'senha789', 
        'USER', 
        V_ID
    );
    DBMS_OUTPUT.PUT_LINE('Usuário de teste criado: ID=' || V_ID);
    
    -- Testar histórico do usuário criado
    PKG_REMOTEREADY.PRC_HISTORICO_USUARIO(V_ID, 'COMPLETO');
    DBMS_OUTPUT.PUT_LINE('Histórico do usuário exibido com sucesso!');
END;
/

-- TESTE 2: Validação de Email (REGEXP)
PROMPT
PROMPT === TESTE 2: Validação de Email (REGEXP) ===;
SELECT 
    PKG_REMOTEREADY.FN_VALIDAR_EMAIL('usuario@email.com') AS EMAIL_VALIDO,
    PKG_REMOTEREADY.FN_VALIDAR_EMAIL('email_invalido') AS EMAIL_INVALIDO
FROM DUAL;

-- TESTE 3: Verificação de Compatibilidade (10+ posts lidos)
PROMPT
PROMPT === TESTE 3: Verificação de Compatibilidade (10+ posts) ===;
SELECT 
    U.NM_USUARIO,
    PKG_REMOTEREADY.FN_CALC_COMPATIBILIDADE(U.ID_USUARIO) AS PRONTO_REMOTO,
    (SELECT COUNT(*) FROM TB_GS_USER_POST WHERE ID_USUARIO = U.ID_USUARIO AND DS_STATUS = 'LIDO') AS POSTS_LIDOS
FROM TB_GS_USUARIO U
ORDER BY U.ID_USUARIO;

-- TESTE 4: JSON do Perfil
PROMPT
PROMPT === TESTE 4: JSON do Perfil (amostra) ===;
SELECT 
    SUBSTR(PKG_REMOTEREADY.FN_USER_PROFILE_JSON(2), 1, 500) AS JSON_PERFIL_SAMPLE
FROM DUAL;

-- TESTE 5: Relatório de Engajamento
PROMPT
PROMPT === TESTE 5: Relatório de Engajamento ===;
EXEC PKG_REMOTEREADY.PRC_RELATORIO_ENGAJAMENTO(30);

-- TESTE 6: Exportação para MongoDB
PROMPT
PROMPT === TESTE 6: Exportação para MongoDB ===;
EXEC PKG_REMOTEREADY.PRC_EXPORT_MONGODB('TESTE_DISCIPLINA');

-- TESTE 6B: Scripts de Exportação JSON
PROMPT
PROMPT === TESTE 6B: Scripts de Exportação JSON ===;
EXEC PKG_REMOTEREADY.PRC_GERAR_SCRIPTS_EXPORT;

-- TESTE 7: Sistema de Histórico Especializado
PROMPT
PROMPT === TESTE 7: Sistema de Histórico Especializado ===;
DECLARE
    V_ID_CHAT NUMBER;
    V_ID_CHAT2 NUMBER;
BEGIN
    -- Teste 1: Inserir conversa inicial (sem resposta)
    PKG_REMOTEREADY.PRC_INSERIR_CHAT_HISTORY(
        P_ID_USUARIO => 1,
        P_PROMPT => 'Como posso melhorar meu perfil para trabalho remoto?',
        P_RESPONSE => NULL, -- Resposta pendente
        P_ID_OUT => V_ID_CHAT
    );
    DBMS_OUTPUT.PUT_LINE('Chat criado (resposta pendente): ID=' || V_ID_CHAT);
    
    -- Teste 2: Atualizar com resposta completa
    PKG_REMOTEREADY.PRC_ATUALIZAR_CHAT_RESPONSE(
        P_ID_CHAT => V_ID_CHAT,
        P_RESPONSE => 'Para melhorar seu perfil remoto: 1) Desenvolva comunicação digital, 2) Domine ferramentas colaborativas, 3) Crie portfólio online...'
    );
    
    -- Teste 3: Inserir conversa completa
    PKG_REMOTEREADY.PRC_INSERIR_CHAT_HISTORY(
        P_ID_USUARIO => 1,
        P_PROMPT => 'Quais certificados são mais valorizados?',
        P_RESPONSE => 'Certificados mais valorizados: Scrum Master, AWS Cloud, Google Analytics, Microsoft Teams...',
        P_ID_OUT => V_ID_CHAT2
    );
    
    -- Teste 4: Buscar histórico recente
    PKG_REMOTEREADY.PRC_BUSCAR_HISTORICO_CHAT(1, 5);
    
    DBMS_OUTPUT.PUT_LINE('Sistema de histórico testado com sucesso!');
END;
/

-- TESTE 8: Histórico Completo do Usuário
PROMPT
PROMPT === TESTE 8: Histórico Completo do Usuário ===;
EXEC PKG_REMOTEREADY.PRC_HISTORICO_USUARIO(1, 'COMPLETO');

-- TESTE 9: Histórico Específico de Posts (ADMIN)
PROMPT
PROMPT === TESTE 9: Histórico de Posts do Admin ===;
EXEC PKG_REMOTEREADY.PRC_HISTORICO_USUARIO(2, 'POSTS');

-- TESTE 10: Busca Específica de Chat
PROMPT
PROMPT === TESTE 10: Busca Específica de Chat ===;
EXEC PKG_REMOTEREADY.PRC_BUSCAR_HISTORICO_CHAT(1, 3);

-- TESTE 11: Manutenção de Histórico
PROMPT
PROMPT === TESTE 11: Manutenção de Histórico ===;
BEGIN
    -- Demonstrar limpeza de histórico muito antigo (>2 anos)
    PKG_REMOTEREADY.PRC_LIMPAR_HISTORICO_ANTIGO(1, 730);
    DBMS_OUTPUT.PUT_LINE('Teste de manutenção concluído - histórico preservado por ser recente');
END;
/

-- TESTE 12: Verificar Auditoria
PROMPT
PROMPT === TESTE 12: Auditoria (últimas 5 operações) ===;
SELECT 
    ID_AUDITORIA,
    NM_TABELA,
    TP_OPERACAO,
    NM_USUARIO_DB,
    TO_CHAR(DT_OPERACAO, 'DD/MM/YYYY HH24:MI:SS') AS DATA_OPERACAO
FROM TB_GS_AUDITORIA
ORDER BY DT_OPERACAO DESC
FETCH FIRST 5 ROWS ONLY;

-- TESTE 8: Verificar último JSON exportado
PROMPT
PROMPT === TESTE 8: Último Export (primeiros 300 chars) ===;
SELECT 
    ID_EXPORT,
    TP_EXPORT,
    QT_REGISTROS,
    FL_SUCESSO,
    SUBSTR(DS_DATASET_JSON, 1, 300) AS JSON_PREVIEW
FROM TB_GS_EXPORT_LOG
WHERE ID_EXPORT = (SELECT MAX(ID_EXPORT) FROM TB_GS_EXPORT_LOG);

PROMPT
PROMPT ========================================;
PROMPT SCRIPT CONCLUÍDO COM SUCESSO!
PROMPT ========================================;
PROMPT
PROMPT RESUMO DO QUE FOI CRIADO:
PROMPT - 7 Tabelas (3FN com PKs/FKs)
PROMPT - 1 Package com todas procedures/funções
PROMPT - 1 Trigger de auditoria
PROMPT - Índices para performance
PROMPT - Sistema de exportação JSON para MongoDB
PROMPT - Dados de teste completos
PROMPT
PROMPT ========================================;
PROMPT COMO EXTRAIR JSON PARA MONGODB:
PROMPT ========================================;
PROMPT
PROMPT 1) Consultar último export:
PROMPT    SELECT DS_DATASET_JSON 
PROMPT    FROM TB_GS_EXPORT_LOG 
PROMPT    WHERE ID_EXPORT = (SELECT MAX(ID_EXPORT) FROM TB_GS_EXPORT_LOG);
PROMPT
PROMPT 2) Copiar o resultado e salvar em: remoteready_export.json
PROMPT
PROMPT 3) No terminal do MongoDB:
PROMPT    mongoimport --db remoteready --collection users_profile
PROMPT    --file remoteready_export.json --jsonArray
PROMPT
PROMPT 4) Verificar no MongoDB:
PROMPT    use remoteready
PROMPT    db.users_profile.find().pretty()
PROMPT
PROMPT ========================================;
PROMPT FIM DO SCRIPT - REMOTEREADY
PROMPT ========================================;