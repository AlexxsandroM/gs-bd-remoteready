
-- =============================================
-- 07_SPOOL_LAST_EXPORT_GS.sql
-- Exporta o CLOB (última exportação) para arquivo .json
-- Use no SQL*Plus/SQLcl (ajuste o caminho do SPOOL conforme seu ambiente)
-- =============================================

SET TERMOUT ON
SET LONG 100000000
SET PAGESIZE 0
SET LINESIZE 32767
SET TRIMSPOOL ON

-- >>>> Ajuste o caminho/arquivo aqui <<<<
SPOOL export_latest.json

SELECT DS_DATASET_JSON
FROM TB_GS_EXPORT_LOG
ORDER BY ID_EXPORT DESC
FETCH FIRST 1 ROW ONLY;

SPOOL OFF

PROMPT ==== Arquivo 'export_latest.json' gerado (pasta atual do cliente) ====
