
-- =============================================
-- 02_FUNCS_PROCS_GS.sql (sem packages)
-- Tabelas com prefixo TB_GS_*
-- =============================================

-- ============ FUNÇÕES ============
CREATE OR REPLACE FUNCTION FN_VALIDATE_EMAIL(p_email IN VARCHAR2) RETURN NUMBER IS
BEGIN
  IF REGEXP_LIKE(p_email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$') THEN
    RETURN 1;
  ELSE
    RETURN 0;
  END IF;
END;
/

CREATE OR REPLACE FUNCTION FN_VALIDATE_LOGIN(p_email IN VARCHAR2, p_password IN VARCHAR2) RETURN VARCHAR2 IS
  v_count NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_count FROM TB_GS_USUARIO WHERE DS_EMAIL = p_email AND DS_PASSWORD = p_password;
  IF v_count = 1 THEN
    RETURN 'Login válido';
  ELSE
    RETURN 'Credenciais inválidas';
  END IF;
END;
/

CREATE OR REPLACE FUNCTION FN_USER_JSON(p_id_usuario IN NUMBER) RETURN CLOB IS
  v_nome   TB_GS_USUARIO.NM_USUARIO%TYPE;
  v_email  TB_GS_USUARIO.DS_EMAIL%TYPE;
  v_role   TB_GS_USUARIO.TP_ROLE%TYPE;
  v_json   CLOB := NULL;
BEGIN
  SELECT NM_USUARIO, DS_EMAIL, TP_ROLE INTO v_nome, v_email, v_role
  FROM TB_GS_USUARIO WHERE ID_USUARIO = p_id_usuario;

  v_json := '{' ||
    '"id":'||p_id_usuario||','||
    '"nome":"' || REPLACE(v_nome,'"','\"') || '",' ||
    '"email":"' || REPLACE(v_email,'"','\"') || '",' ||
    '"role":"' || v_role || '",' ||
    '"certificados":[';

  FOR c IN (SELECT DS_TITULO, DT_EMISSAO FROM TB_GS_CERTIFICADO WHERE ID_USUARIO = p_id_usuario ORDER BY DT_EMISSAO) LOOP
    v_json := v_json ||
      '{"titulo":"' || REPLACE(c.DS_TITULO,'"','\"') || '","data":"' ||
       TO_CHAR(c.DT_EMISSAO, 'DD/MM/YYYY') || '"},';
  END LOOP;
  v_json := RTRIM(v_json, ',') || '],';

  v_json := v_json || '"posts":[';
  FOR p IN (SELECT DS_TITULO, DS_TAG, DT_CRIACAO FROM TB_GS_BLOG_POST WHERE ID_USUARIO_CRIADOR = p_id_usuario ORDER BY DT_CRIACAO) LOOP
    v_json := v_json ||
      '{"titulo":"' || REPLACE(p.DS_TITULO,'"','\"') || '","tag":"' ||
       NVL(p.DS_TAG,'') || '","data":"' || TO_CHAR(p.DT_CRIACAO,'DD/MM/YYYY') || '"},';
  END LOOP;
  v_json := RTRIM(v_json, ',') || ']}';

  RETURN v_json;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN '{"erro":"Usuario nao encontrado","id":'||p_id_usuario||'}';
  WHEN OTHERS THEN
    RETURN '{"erro":"Falha ao gerar JSON para usuario '||p_id_usuario||'"}';
END;
/

-- ============ PROCEDURES (CRUD BÁSICO) ============
CREATE OR REPLACE PROCEDURE PRC_INS_USUARIO(p_nome IN VARCHAR2, p_email IN VARCHAR2, p_password IN VARCHAR2, p_role IN VARCHAR2 DEFAULT 'USER') AS
BEGIN
  IF FN_VALIDATE_EMAIL(p_email) = 0 THEN
    RAISE_APPLICATION_ERROR(-20001, 'E-mail inválido: '||p_email);
  END IF;

  INSERT INTO TB_GS_USUARIO(ID_USUARIO, NM_USUARIO, DS_EMAIL, DS_PASSWORD, TP_ROLE, DT_CRIACAO)
  VALUES (SEQ_TB_GS_USUARIO.NEXTVAL, p_nome, p_email, p_password, NVL(p_role,'USER'), SYSDATE);
EXCEPTION
  WHEN DUP_VAL_ON_INDEX THEN
    RAISE_APPLICATION_ERROR(-20002, 'E-mail já cadastrado: '||p_email);
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20099, 'Erro ao inserir usuário: '||SQLERRM);
END;
/

CREATE OR REPLACE PROCEDURE PRC_INS_EMPRESA(p_nome IN VARCHAR2, p_descricao IN VARCHAR2, p_area IN VARCHAR2,
                                            p_hiring IN CHAR, p_logo IN VARCHAR2, p_site IN VARCHAR2) AS
BEGIN
  INSERT INTO TB_GS_EMPRESA(ID_EMPRESA, NM_EMPRESA, DS_EMPRESA, DS_AREA, FL_HIRING_NOW, DS_LOGO_URL, DS_WEBSITE, DT_CRIACAO)
  VALUES (SEQ_TB_GS_EMPRESA.NEXTVAL, p_nome, p_descricao, p_area, NVL(p_hiring,'N'), p_logo, p_site, SYSDATE);
END;
/

CREATE OR REPLACE PROCEDURE PRC_INS_POST(p_titulo IN VARCHAR2, p_desc IN VARCHAR2, p_img IN VARCHAR2, p_tag IN VARCHAR2, p_id_usuario IN NUMBER) AS
BEGIN
  INSERT INTO TB_GS_BLOG_POST(ID_POST, DS_TITULO, DS_DESCRICAO, DS_IMAGE_URL, DS_TAG, DT_CRIACAO, ID_USUARIO_CRIADOR)
  VALUES (SEQ_TB_GS_BLOG_POST.NEXTVAL, p_titulo, p_desc, p_img, p_tag, SYSDATE, p_id_usuario);
END;
/

CREATE OR REPLACE PROCEDURE PRC_INS_CHAT(p_id_usuario IN NUMBER, p_prompt IN VARCHAR2, p_response IN VARCHAR2) AS
BEGIN
  INSERT INTO TB_GS_CHAT_HIST(ID_CHAT, ID_USUARIO, DS_PROMPT, DS_RESPONSE, DT_CRIACAO)
  VALUES (SEQ_TB_GS_CHAT_HIST.NEXTVAL, p_id_usuario, p_prompt, p_response, SYSDATE);
END;
/

CREATE OR REPLACE PROCEDURE PRC_INS_CERTIFICADO(p_id_usuario IN NUMBER, p_titulo IN VARCHAR2) AS
BEGIN
  INSERT INTO TB_GS_CERTIFICADO(ID_CERTIFICADO, ID_USUARIO, DT_EMISSAO, DS_TITULO)
  VALUES (SEQ_TB_GS_CERTIFICADO.NEXTVAL, p_id_usuario, SYSDATE, NVL(p_titulo,'Remote Work Ready'));
END;
/

CREATE OR REPLACE PROCEDURE PRC_EXPORT_DATASET AS
  v_json CLOB := '[';
  v_first BOOLEAN := TRUE;
BEGIN
  FOR r IN (SELECT ID_USUARIO FROM TB_GS_USUARIO ORDER BY ID_USUARIO) LOOP
    IF v_first THEN v_first := FALSE; ELSE v_json := v_json || ','; END IF;
    v_json := v_json || FN_USER_JSON(r.ID_USUARIO);
  END LOOP;
  v_json := v_json || ']';

  INSERT INTO TB_GS_EXPORT_LOG(ID_EXPORT, DT_GERACAO, DS_DATASET_JSON)
  VALUES (SEQ_TB_GS_EXPORT_LOG.NEXTVAL, SYSDATE, v_json);
END;
/
