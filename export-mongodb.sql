--------------------------------------------------------------------------------
-- SCRIPT DE EXPORTAÇÃO MONGODB - REMOTEREADY
-- Execute este script APÓS ter executado o gs-bd-remoteready-otimizado.sql
--------------------------------------------------------------------------------

SET SERVEROUTPUT ON SIZE 1000000;
SET VERIFY OFF;
SET LINESIZE 32767;
SET PAGESIZE 0;
SET LONG 999999999;
SET LONGCHUNKSIZE 32767;
SET TRIMSPOOL ON;
SET TRIMOUT ON;
SET FEEDBACK OFF;
SET HEADING OFF;

PROMPT ========================================;
PROMPT EXPORTAÇÃO PARA MONGODB - REMOTEREADY
PROMPT ========================================;
PROMPT;

--------------------------------------------------------------------------------
-- ETAPA 1: GERAR EXPORT
--------------------------------------------------------------------------------
PROMPT [1/3] Gerando exportação de dados...;
PROMPT;

EXEC PKG_REMOTEREADY.PRC_EXPORT_MONGODB('PRODUCAO');

PROMPT;
PROMPT Exportação gerada com sucesso!;
PROMPT;

--------------------------------------------------------------------------------
-- ETAPA 2: VERIFICAR EXPORT
--------------------------------------------------------------------------------
PROMPT [2/3] Verificando dados do export...;
PROMPT;

SET HEADING ON;
SET FEEDBACK ON;

SELECT 
    ID_EXPORT,
    TP_EXPORT,
    QT_REGISTROS,
    FL_SUCESSO,
    TO_CHAR(DT_GERACAO, 'DD/MM/YYYY HH24:MI:SS') AS DATA_GERACAO,
    DS_OBSERVACAO
FROM TB_GS_EXPORT_LOG
WHERE ID_EXPORT = (SELECT MAX(ID_EXPORT) FROM TB_GS_EXPORT_LOG);

SET HEADING OFF;
SET FEEDBACK OFF;

PROMPT;
PROMPT;

--------------------------------------------------------------------------------
-- ETAPA 3: EXTRAIR JSON
--------------------------------------------------------------------------------
PROMPT [3/3] Extraindo JSON...;
PROMPT;
PROMPT IMPORTANTE: Copie TODO o conteúdo abaixo (até o último ]) e salve em: remoteready_export.json;
PROMPT;
PROMPT ========== INÍCIO DO JSON ==========;

SELECT DS_DATASET_JSON
FROM TB_GS_EXPORT_LOG
WHERE ID_EXPORT = (SELECT MAX(ID_EXPORT) FROM TB_GS_EXPORT_LOG);

PROMPT ========== FIM DO JSON ==========;
PROMPT;
PROMPT;

--------------------------------------------------------------------------------
-- INSTRUÇÕES DE IMPORTAÇÃO
--------------------------------------------------------------------------------
SET HEADING ON;
PROMPT ========================================;
PROMPT PRÓXIMOS PASSOS:
PROMPT ========================================;
PROMPT;
PROMPT 1) Copie o JSON acima (do [ até o ])
PROMPT 2) Cole em um arquivo de texto
PROMPT 3) Salve como: remoteready_export.json
PROMPT;
PROMPT 4) No terminal, execute:
PROMPT    mongoimport --db remoteready --collection users_profile --file remoteready_export.json --jsonArray
PROMPT;
PROMPT 5) Verifique no MongoDB:
PROMPT    use remoteready
PROMPT    db.users_profile.find().pretty()
PROMPT;
PROMPT ========================================;

-- Resetar configurações
SET PAGESIZE 14;
SET LINESIZE 80;
SET FEEDBACK ON;
SET HEADING ON;