# 🚀 RemoteReady – Banco de Dados (Global Solution)

**Disciplina:** _MASTERING RELATIONAL AND NON-RELATIONAL DATABASE_  
**Projeto:** Global Solution (GS) - Novembro 2025  
**Aluno:** **Alexsandro Macedo** – **RM 557068**  
**Tema:** O Futuro do Trabalho

---

## 📋 Sobre o Projeto

**RemoteReady** é uma plataforma educacional e marketplace para o mercado de trabalho remoto, desenvolvida como solução integrada para a Global Solution da FIAP.

**Funcionalidades Principais:**
- 📚 **Conteúdo Educacional**: Blog com posts sobre trabalho remoto (apenas ADMIN publica)
- 💬 **Chat IA**: Histórico de conversas dos usuários com assistente virtual
- 🏢 **Marketplace**: Empresas parceiras com vagas remotas
- 🎓 **Gamificação**: Certificados automáticos por engajamento (10+ posts lidos)
- 📊 **Analytics**: Cálculo de compatibilidade do usuário com mercado remoto
- 🔄 **Integração**: Pipeline Oracle → MongoDB para análises avançadas

---

### 1. Modelagem Relacional 3FN 
- 8 tabelas normalizadas (incluindo histórico de chat)
- PKs, FKs, UKs, CHECKs implementados
- Relacionamentos corretos com ON DELETE CASCADE

**Tabelas:**
- `TB_GS_USUARIO` - Usuários (ADMIN/USER)
- `TB_GS_EMPRESA` - Empresas parceiras
- `TB_GS_BLOG_POST` - Posts educacionais
- `TB_GS_CERTIFICADO` - Certificados de conquista
- `TB_GS_USER_POST` - Registro de leituras com status
- `TB_GS_CHAT_HISTORY` - **NOVA**: Histórico de conversas com IA
- `TB_GS_AUDITORIA` - Trilha de auditoria
- `TB_GS_EXPORT_LOG` - Controle de exportações

### 2. Procedure 1 - Histórico do Usuário 
Procedures especializadas em histórico encapsuladas no package:
- `PRC_HISTORICO_USUARIO` - Exibe histórico completo do usuário (posts, chat, auditoria)
- `PRC_INSERIR_CHAT_HISTORY` - Registra conversas com IA do usuário  
- `PRC_INSERIR_USUARIO` - Create com validação (mantida)
- `PRC_INSERIR_POST` - Validação rigorosa de role ADMIN
- `PRC_INSERIR_EMPRESA` - Insert com defaults

### 3. Procedure 2 - Relatórios 
- `PRC_RELATORIO_ENGAJAMENTO` - Análise de métricas (usuários, posts, leituras, certificados)
- `PRC_REGISTRAR_LEITURA` - Registro com auto-certificação aos 10+ posts

### 4. Função 1 - Transformação
- `FN_USER_PROFILE_JSON` - Gera JSON completo do perfil:
  - Dados pessoais
  - Estatísticas (posts lidos, certificados)
  - Score de compatibilidade
  - Lista de certificados

### 5. Função 2 - Validação REGEXP
- `FN_VALIDAR_EMAIL` - Validação com expressão regular
- `FN_CALC_COMPATIBILIDADE` - Verifica se usuário leu 10+ posts:
  - Retorna 'Y' se preparado para trabalho remoto (10+ posts lidos)
  - Retorna 'N' caso contrário
  - Critério simples e direto baseado em engajamento

### 6. Empacotamento 
- Package `PKG_REMOTEREADY` com:
  - Specification (interface pública)
  - Body (implementação)
  - Todas procedures e funções organizadas

### 7. Trigger de Auditoria 
- `TRG_AUD_USUARIO` - Registra automaticamente:
  - INSERT, UPDATE, DELETE
  - Dados antigos e novos
  - Usuário do banco
  - Timestamp

### 8. Integração NoSQL 
- `PRC_EXPORT_MONGODB` - Exportação completa:
  - Gera array JSON de todos os usuários
  - Inclui perfis completos
  - Salva em TB_GS_EXPORT_LOG
  - Pronto para import no MongoDB

---

## 🔄 Pipeline Oracle → MongoDB

### 📤 Métodos de Exportação

#### **Método 1: Via Package (Integrado)**
```sql
-- Exportação completa usando package
EXEC PKG_REMOTEREADY.PRC_EXPORT_MONGODB('FULL_DATASET');

-- Verificar exportação
SELECT ID_EXPORT, QT_REGISTROS, LENGTH(DS_DATASET_JSON) AS TAMANHO_BYTES
FROM TB_GS_EXPORT_LOG 
ORDER BY DT_GERACAO DESC;

-- Extrair JSON
SELECT DS_DATASET_JSON
FROM TB_GS_EXPORT_LOG
WHERE ID_EXPORT = (SELECT MAX(ID_EXPORT) FROM TB_GS_EXPORT_LOG);
```

#### **Método 2: Script Independente (Recomendado)**
```sql
-- Executar script de exportação dedicado
@export_remoteready_json.sql
```

**Características:**
- ✅ **Gera 6 arquivos JSON separados** por entidade
- ✅ **Execução direta**: Não precisa copiar/colar resultados
- ✅ **100% dinâmico**: Sem hard inserts
- ✅ **Compatível**: Formato JSON Array para MongoDB

**Arquivos gerados:**
- `remoteready_usuarios.json`
- `remoteready_empresas.json`
- `remoteready_blog_posts.json`
- `remoteready_certificados.json`
- `remoteready_user_posts.json`
- `remoteready_chat_history.json`

#### **Método 3: Via Procedure Especializada**
```sql
-- Gerar scripts SPOOL dinâmicos
EXEC PKG_REMOTEREADY.PRC_GERAR_SCRIPTS_EXPORT;

-- Copiar a saída e executar os blocos SPOOL gerados
```

### 📥 Importação MongoDB

#### **1. Configuração do MongoDB**
```bash
# Iniciar MongoDB
mongod --dbpath /data/db

# Conectar ao MongoDB
mongosh
```

#### **2. Criar Database e Coleções**
```bash
# Executar script de configuração
mongosh --file create_mongo_db.js
```

#### **3. Importar Dados**

**PowerShell (Windows - Recomendado):**
```powershell
.\import_data.ps1
```

**Batch (Windows cmd):**
```cmd
import_mongo.bat
```

**Manual (qualquer sistema):**
```bash
# Usuários
mongoimport --db remoteready --collection usuarios \
  --file remoteready_usuarios.json --jsonArray --drop

# Empresas
mongoimport --db remoteready --collection empresas \
  --file remoteready_empresas.json --jsonArray --drop

# Posts do Blog
mongoimport --db remoteready --collection blog_posts \
  --file remoteready_blog_posts.json --jsonArray --drop

# Certificados
mongoimport --db remoteready --collection certificados \
  --file remoteready_certificados.json --jsonArray --drop

# Leituras de Posts (User Posts)
mongoimport --db remoteready --collection user_posts \
  --file remoteready_user_posts.json --jsonArray --drop

# Histórico de Chat
mongoimport --db remoteready --collection chat_history \
  --file remoteready_chat_history.json --jsonArray --drop
```

#### **4. Verificação dos Dados**
```javascript