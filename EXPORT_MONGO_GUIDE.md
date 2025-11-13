
# Guia — Exportação (Oracle) e Importação (MongoDB)
Este passo a passo mostra como gerar um **snapshot JSON** do Oracle (usando a tabela `TB_GS_EXPORT_LOG`) e importar no **MongoDB** (via `mongoimport`). Serve tanto para demonstração da disciplina quanto para integração NoSQL do seu app.

---

## 1) Gerar o JSON no Oracle
A procedure `PRC_EXPORT_DATASET` monta um array JSON com os usuários e seus dados relacionados (posts, certificados) **manualmente** (sem funções JSON nativas) e grava o resultado em `TB_GS_EXPORT_LOG` (CLOB).

### 1.1 Rodar a exportação
**Forma 1 (F5/Run Script):**
```sql
BEGIN
  PRC_EXPORT_DATASET;
END;
/
```

**Forma 2 (Ctrl+Enter / Run Statement, SQL Developer/SQLcl):**
```sql
EXEC PRC_EXPORT_DATASET;
```

### 1.2 Verificar a última exportação
```sql
SELECT ID_EXPORT,
       DT_GERACAO,
       DBMS_LOB.SUBSTR(DS_DATASET_JSON, 4000, 1) AS JSON_INICIO
FROM TB_GS_EXPORT_LOG
ORDER BY ID_EXPORT DESC
FETCH FIRST 1 ROW ONLY;
```

### 1.3 Extrair o CLOB para arquivo `.json`
**SQL*Plus/SQLcl – Windows/macOS/Linux**  
> Ajuste o `SET LONG` conforme o tamanho esperado.

```sql
SET LONG 100000000
SET PAGESIZE 0
SET LINESIZE 32767
SET TRIMSPOOL ON
SPOOL export_latest.json

SELECT DS_DATASET_JSON
FROM TB_GS_EXPORT_LOG
ORDER BY ID_EXPORT DESC
FETCH FIRST 1 ROW ONLY;

SPOOL OFF
```

**Dicas**
- Se usar **SQL Developer**, você também pode clicar no resultado, botão direito → **Export** → Formato **CLOB** → Arquivo `.json`.
- Se houver caracteres especiais, garanta **AL32UTF8** no cliente e salve como UTF‑8.

---

## 2) Importar o JSON no MongoDB
Aqui vamos usar o `mongoimport` (parte do **MongoDB Database Tools**).

### 2.1 Pré‑requisitos
- Instalar **MongoDB Database Tools** (inclui `mongoimport`).
- Ter o **mongod** rodando localmente ou possuir a string de conexão para um cluster/Atlas.

### 2.2 Comandos de importação
**JSON é um array `[...]`** com objetos; portanto use `--jsonArray`.

#### Localhost (sem auth):
```bash
mongoimport --db remoteready --collection users_profile \
  --file export_latest.json --jsonArray
```

#### Com host/porta específicos:
```bash
mongoimport --host 127.0.0.1 --port 27017 \
  --db remoteready --collection users_profile \
  --file export_latest.json --jsonArray
```

#### MongoDB Atlas (SRV + auth):
```bash
mongoimport \
  --uri "mongodb+srv://<usuario>:<senha>@<cluster>.mongodb.net/remoteready" \
  --collection users_profile \
  --file export_latest.json --jsonArray
```

> Troque `<usuario>`, `<senha>` e `<cluster>` pelos seus valores.

### 2.3 Consultas rápidas no `mongosh`
```javascript
// Total de documentos
db.users_profile.countDocuments()

// Buscar admins
db.users_profile.find({ role: "ADMIN" })

// Projetar apenas nome e certificados
db.users_profile.find({}, { nome: 1, certificados: 1, _id: 0 })

// Filtrar por certificados que contenham “Remote”
db.users_profile.find({ "certificados.titulo": /Remote/ })

// Index para busca por email
db.users_profile.createIndex({ email: 1 }, { unique: true })
```

---

## 3) Rotina de manutenção (opcional)
### 3.1 Manter somente N exportações no Oracle
```sql
DELETE FROM TB_GS_EXPORT_LOG
WHERE ID_EXPORT NOT IN (
  SELECT ID_EXPORT FROM TB_GS_EXPORT_LOG
  ORDER BY ID_EXPORT DESC FETCH FIRST 10 ROWS ONLY
);
COMMIT;
```

### 3.2 Job diário (DBMS_SCHEDULER)
```sql
BEGIN
  DBMS_SCHEDULER.CREATE_JOB (
    job_name        => 'JOB_EXPORT_JSON_DAILY',
    job_type        => 'PLSQL_BLOCK',
    job_action      => 'BEGIN PRC_EXPORT_DATASET; END;',
    start_date      => SYSTIMESTAMP,
    repeat_interval => 'FREQ=DAILY;BYHOUR=02;BYMINUTE=00;BYSECOND=00',
    enabled         => TRUE,
    comments        => 'Gera snapshot JSON diário em TB_GS_EXPORT_LOG'
  );
END;
/
```

---

## 4) Troubleshooting
- **`PLS-00103: Encountered the symbol "/"`:** No modo script, o `/` deve ficar **sozinho** em nova linha após `END;`.
- **JSON cortado no arquivo:** aumente `SET LONG` e `SET LINESIZE` antes do `SPOOL`.
- **`invalid UTF-8` no `mongoimport`:** confirme que o arquivo `.json` está em UTF‑8 (sem BOM).
- **`E11000 duplicate key` no Mongo:** remova/ajuste `unique index` ou limpe a collection antes de reimportar:
  ```javascript
  db.users_profile.deleteMany({})
  ```
- **Conexão Atlas bloqueada:** libere o IP do cliente no **Network Access** do Atlas.

---

## 5) Fluxo resumido (cola)
1. `EXEC PRC_EXPORT_DATASET;`
2. Exportar CLOB da `TB_GS_EXPORT_LOG` para `export_latest.json` (SQL*Plus/SQLcl/SQL Developer)
3. `mongoimport --db remoteready --collection users_profile --file export_latest.json --jsonArray`
4. Conferir no `mongosh` com `db.users_profile.find().limit(3)`

Pronto! Você tem um ciclo simples de **Export (Oracle) → Import (Mongo)** para o seu projeto.
