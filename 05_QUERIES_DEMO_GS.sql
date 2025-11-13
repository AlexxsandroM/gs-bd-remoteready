
-- =============================================
-- 05_QUERIES_DEMO_GS.sql (refeito • robusto)
-- Uso:
--  • F5 (Run Script): blocos PL/SQL terminam com "/" em linha separada
--  • Ctrl+Enter (Run Statement): pode usar EXEC para procedures
-- =============================================

PROMPT === 1) Sanidade: há usuários para exportar? ==============================
SELECT COUNT(*) AS QTD_USUARIOS FROM TB_GS_USUARIO;

-- (Opcional) ver alguns usuários
SELECT ID_USUARIO, NM_USUARIO FROM TB_GS_USUARIO FETCH FIRST 5 ROWS ONLY;

PROMPT === 2) Testes de função de login (ok e falha) ===========================
SELECT FN_VALIDATE_LOGIN('ana.silva@remoteready.dev','123456') AS RESULTADO_OK FROM dual;
SELECT FN_VALIDATE_LOGIN('ana.silva@remoteready.dev','errada')  AS RESULTADO_FAIL FROM dual;

PROMPT === 3) JSON manual de um usuário (FN_USER_JSON) =========================
SELECT FN_USER_JSON(1) AS JSON_USER_1 FROM dual;

PROMPT === 4) Exportar dataset para TB_GS_EXPORT_LOG ===========================
BEGIN
  PRC_EXPORT_DATASET;
END;
/
COMMIT;

PROMPT === 5) Conferir exportações e tamanho do CLOB ===========================
SELECT COUNT(*) AS QTD_EXPORTS FROM TB_GS_EXPORT_LOG;

SELECT ID_EXPORT,
       DT_GERACAO,
       DBMS_LOB.GETLENGTH(DS_DATASET_JSON) AS TAMANHO_BYTES
FROM TB_GS_EXPORT_LOG
ORDER BY ID_EXPORT DESC
FETCH FIRST 3 ROWS ONLY;

PROMPT === 6) Ver início do JSON da última exportação ==========================
SELECT DBMS_LOB.SUBSTR(DS_DATASET_JSON, 4000, 1) AS JSON_INICIO
FROM TB_GS_EXPORT_LOG
ORDER BY ID_EXPORT DESC
FETCH FIRST 1 ROW ONLY;

PROMPT === 7) CRUD em TB_GS_EMPRESA + auditoria ================================
BEGIN
  PRC_INS_EMPRESA('NovaCo','Tech para remoto','Tecnologia','Y',NULL,'https://novaco.example');
END;
/
SELECT ID_EMPRESA, NM_EMPRESA, FL_HIRING_NOW
FROM TB_GS_EMPRESA
WHERE FL_HIRING_NOW='Y';

UPDATE TB_GS_EMPRESA SET FL_HIRING_NOW='N' WHERE ID_EMPRESA=1;
COMMIT;

DELETE FROM TB_GS_EMPRESA WHERE ID_EMPRESA=1;
COMMIT;

SELECT TP_OPERACAO, NM_TABELA, ID_REGISTRO, DT_OPERACAO
FROM TB_GS_AUDITORIA
WHERE NM_TABELA='TB_GS_EMPRESA'
ORDER BY ID_AUDITORIA DESC
FETCH FIRST 5 ROWS ONLY;

-- =============================================
-- Dicas rápidas
-- • Se QTD_USUARIOS = 0, execute o seed: @04_SEED_GS.sql e rode de novo a etapa 4
-- • Para Ctrl+Enter, alternativa:
--     EXEC PRC_EXPORT_DATASET;
--     COMMIT;
-- • Para exportar o CLOB para arquivo: use o guia EXPORT_MONGO_GUIDE.md
-- =============================================
