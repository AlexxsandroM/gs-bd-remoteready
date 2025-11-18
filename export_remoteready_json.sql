-- ============================================================================
-- SCRIPTS DE EXPORTAÇÃO JSON PARA MONGODB - REMOTEREADY
-- ============================================================================
-- Execute cada bloco individualmente no SQL*Plus ou SQLcl
-- Os arquivos JSON serão gerados no diretório atual
-- ============================================================================

SET SERVEROUTPUT ON SIZE UNLIMITED
SET LINESIZE 32767
SET LONG 1000000
SET PAGESIZE 0
SET TRIMSPOOL ON
SET FEEDBACK OFF
SET HEADING OFF

-- ============================================================================
-- EXPORTAÇÃO DE USUÁRIOS
-- ============================================================================
PROMPT =========================================================================
PROMPT EXPORTANDO TABELA: TB_GS_USUARIO -> remoteready_usuarios.json
PROMPT =========================================================================
SPOOL remoteready_usuarios.json
DECLARE
  v_first BOOLEAN := TRUE;
  v_obj VARCHAR2(32767);
BEGIN
  DBMS_OUTPUT.PUT_LINE('[');
  FOR r IN (SELECT * FROM TB_GS_USUARIO ORDER BY ID_USUARIO) LOOP
    IF NOT v_first THEN DBMS_OUTPUT.PUT_LINE(','); ELSE v_first := FALSE; END IF;
    v_obj := '{' ||
      '"id_usuario":' || TO_CHAR(r.id_usuario) || ',' ||
      '"nm_usuario":' || FN_JSON_ESCAPE(r.nm_usuario) || ',' ||
      '"ds_email":' || FN_JSON_ESCAPE(r.ds_email) || ',' ||
      '"tp_role":' || FN_JSON_ESCAPE(r.tp_role) || ',' ||
      '"dt_criacao":' || FN_JSON_DATE(r.dt_criacao) ||
    '}';
    DBMS_OUTPUT.PUT_LINE(v_obj);
  END LOOP;
  DBMS_OUTPUT.PUT_LINE(']');
END;
/
SPOOL OFF

-- ============================================================================
-- EXPORTAÇÃO DE EMPRESAS
-- ============================================================================
PROMPT =========================================================================
PROMPT EXPORTANDO TABELA: TB_GS_EMPRESA -> remoteready_empresas.json
PROMPT =========================================================================
SPOOL remoteready_empresas.json
DECLARE
  v_first BOOLEAN := TRUE;
  v_obj VARCHAR2(32767);
BEGIN
  DBMS_OUTPUT.PUT_LINE('[');
  FOR r IN (SELECT * FROM TB_GS_EMPRESA ORDER BY ID_EMPRESA) LOOP
    IF NOT v_first THEN DBMS_OUTPUT.PUT_LINE(','); ELSE v_first := FALSE; END IF;
    v_obj := '{' ||
      '"id_empresa":' || TO_CHAR(r.id_empresa) || ',' ||
      '"nm_empresa":' || FN_JSON_ESCAPE(r.nm_empresa) || ',' ||
      '"ds_area":' || FN_JSON_ESCAPE(r.ds_area) || ',' ||
      '"fl_hiring_now":' || FN_JSON_ESCAPE(r.fl_hiring_now) || ',' ||
      '"ds_website":' || FN_JSON_ESCAPE(r.ds_website) ||
    '}';
    DBMS_OUTPUT.PUT_LINE(v_obj);
  END LOOP;
  DBMS_OUTPUT.PUT_LINE(']');
END;
/
SPOOL OFF

-- ============================================================================
-- EXPORTAÇÃO DE POSTS
-- ============================================================================
PROMPT =========================================================================
PROMPT EXPORTANDO TABELA: TB_GS_BLOG_POST -> remoteready_blog_posts.json
PROMPT =========================================================================
SPOOL remoteready_blog_posts.json
DECLARE
  v_first BOOLEAN := TRUE;
  v_obj VARCHAR2(32767);
BEGIN
  DBMS_OUTPUT.PUT_LINE('[');
  FOR r IN (SELECT * FROM TB_GS_BLOG_POST ORDER BY ID_POST) LOOP
    IF NOT v_first THEN DBMS_OUTPUT.PUT_LINE(','); ELSE v_first := FALSE; END IF;
    v_obj := '{' ||
      '"id_post":' || TO_CHAR(r.id_post) || ',' ||
      '"id_usuario":' || TO_CHAR(r.id_usuario_criador) || ',' ||
      '"ds_titulo":' || FN_JSON_ESCAPE(r.ds_titulo) || ',' ||
      '"ds_descricao":' || FN_JSON_ESCAPE(SUBSTR(r.ds_descricao,1,200)) || ',' ||
      '"ds_tag":' || FN_JSON_ESCAPE(r.ds_tag) || ',' ||
      '"qt_visualizacoes":' || FN_JSON_NUMBER(r.qt_visualizacoes) || ',' ||
      '"dt_criacao":' || FN_JSON_DATE(r.dt_criacao) ||
    '}';
    DBMS_OUTPUT.PUT_LINE(v_obj);
  END LOOP;
  DBMS_OUTPUT.PUT_LINE(']');
END;
/
SPOOL OFF

-- ============================================================================
-- EXPORTAÇÃO DE CERTIFICADOS
-- ============================================================================
PROMPT =========================================================================
PROMPT EXPORTANDO TABELA: TB_GS_CERTIFICADO -> remoteready_certificados.json
PROMPT =========================================================================
SPOOL remoteready_certificados.json
DECLARE
  v_first BOOLEAN := TRUE;
  v_obj VARCHAR2(32767);
BEGIN
  DBMS_OUTPUT.PUT_LINE('[');
  FOR r IN (SELECT * FROM TB_GS_CERTIFICADO ORDER BY ID_CERTIFICADO) LOOP
    IF NOT v_first THEN DBMS_OUTPUT.PUT_LINE(','); ELSE v_first := FALSE; END IF;
    v_obj := '{' ||
      '"id_certificado":' || TO_CHAR(r.id_certificado) || ',' ||
      '"id_usuario":' || TO_CHAR(r.id_usuario) || ',' ||
      '"ds_titulo":' || FN_JSON_ESCAPE(r.ds_titulo) || ',' ||
      '"ds_descricao":' || FN_JSON_ESCAPE(r.ds_descricao) || ',' ||
      '"dt_emissao":' || FN_JSON_DATE(r.dt_emissao) ||
    '}';
    DBMS_OUTPUT.PUT_LINE(v_obj);
  END LOOP;
  DBMS_OUTPUT.PUT_LINE(']');
END;
/
SPOOL OFF

-- ============================================================================
-- EXPORTAÇÃO DE USER_POST (LEITURAS DE POSTS)
-- ============================================================================
PROMPT =========================================================================
PROMPT EXPORTANDO TABELA: TB_GS_USER_POST -> remoteready_user_posts.json
PROMPT =========================================================================
SPOOL remoteready_user_posts.json
DECLARE
  v_first BOOLEAN := TRUE;
  v_obj VARCHAR2(32767);
BEGIN
  DBMS_OUTPUT.PUT_LINE('[');
  FOR r IN (SELECT * FROM TB_GS_USER_POST ORDER BY ID_USER_POST) LOOP
    IF NOT v_first THEN DBMS_OUTPUT.PUT_LINE(','); ELSE v_first := FALSE; END IF;
    v_obj := '{' ||
      '"id_user_post":' || TO_CHAR(r.id_user_post) || ',' ||
      '"id_usuario":' || TO_CHAR(r.id_usuario) || ',' ||
      '"id_post":' || TO_CHAR(r.id_post) || ',' ||
      '"ds_status":' || FN_JSON_ESCAPE(r.ds_status) || ',' ||
      '"dt_leitura":' || FN_JSON_DATE(r.dt_leitura) ||
    '}';
    DBMS_OUTPUT.PUT_LINE(v_obj);
  END LOOP;
  DBMS_OUTPUT.PUT_LINE(']');
END;
/
SPOOL OFF

-- ============================================================================
-- EXPORTAÇÃO DE CHAT HISTORY
-- ============================================================================
PROMPT =========================================================================
PROMPT EXPORTANDO TABELA: TB_GS_CHAT_HISTORY -> remoteready_chat_history.json
PROMPT =========================================================================
SPOOL remoteready_chat_history.json
DECLARE
  v_first BOOLEAN := TRUE;
  v_obj VARCHAR2(32767);
BEGIN
  DBMS_OUTPUT.PUT_LINE('[');
  FOR r IN (SELECT * FROM TB_GS_CHAT_HISTORY ORDER BY ID_CHAT) LOOP
    IF NOT v_first THEN DBMS_OUTPUT.PUT_LINE(','); ELSE v_first := FALSE; END IF;
    v_obj := '{' ||
      '"id_chat":' || TO_CHAR(r.id_chat) || ',' ||
      '"id_usuario":' || TO_CHAR(r.id_usuario) || ',' ||
      '"prompt":' || FN_JSON_ESCAPE(SUBSTR(r.ds_prompt,1,500)) || ',' ||
      '"response":' || FN_JSON_ESCAPE(SUBSTR(r.ds_response,1,500)) || ',' ||
      '"dt_criacao":' || FN_JSON_DATE(r.dt_criacao) ||
    '}';
    DBMS_OUTPUT.PUT_LINE(v_obj);
  END LOOP;
  DBMS_OUTPUT.PUT_LINE(']');
END;
/
SPOOL OFF

-- ============================================================================
-- FINALIZAÇÃO
-- ============================================================================
SET FEEDBACK ON
SET HEADING ON
SET PAGESIZE 14

PROMPT ============================================================================
PROMPT EXPORTAÇÃO CONCLUÍDA!
PROMPT ============================================================================
PROMPT Arquivos gerados:
PROMPT - remoteready_usuarios.json
PROMPT - remoteready_empresas.json
PROMPT - remoteready_blog_posts.json
PROMPT - remoteready_certificados.json
PROMPT - remoteready_user_posts.json
PROMPT - remoteready_chat_history.json
PROMPT ============================================================================
PROMPT COMANDOS MONGODB PARA IMPORTAÇÃO:
PROMPT ============================================================================
PROMPT mongoimport --db remoteready --collection usuarios --file remoteready_usuarios.json --jsonArray
PROMPT mongoimport --db remoteready --collection empresas --file remoteready_empresas.json --jsonArray
PROMPT mongoimport --db remoteready --collection blog_posts --file remoteready_blog_posts.json --jsonArray
PROMPT mongoimport --db remoteready --collection certificados --file remoteready_certificados.json --jsonArray
PROMPT mongoimport --db remoteready --collection user_posts --file remoteready_user_posts.json --jsonArray
PROMPT mongoimport --db remoteready --collection chat_history --file remoteready_chat_history.json --jsonArray
PROMPT ============================================================================