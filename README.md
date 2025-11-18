# 🚀 RemoteReady – Banco de Dados (Global Solution)

**Disciplina:** _MASTERING RELATIONAL AND NON-RELATIONAL DATABASE_  
**Projeto:** Global Solution (GS) - Novembro 2025  
**Aluno:** **Alexsandro Macedo** – **RM 557068**  
**Tema:** O Futuro do Trabalho

---

## 📋 Sobre o Projeto

**RemoteReady** é uma plataforma educacional e marketplace completo para o mercado de trabalho remoto, desenvolvida como solução integrada para a Global Solution da FIAP.

### 🎯 Arquitetura do Sistema

Este banco de dados Oracle alimenta o ecossistema completo RemoteReady:

- **🗄️ Backend Java** - API REST que consome este banco Oracle
- **📱 App Mobile** - Aplicativo React Native **RemoteReady** (frontend)
- **🤖 Chatbot IA** - **RemoteCoach**: Assistente virtual para orientação sobre trabalho remoto
- **📊 Analytics** - Pipeline MongoDB para análises avançadas de comportamento

### ⚙️ Funcionalidades Principais

- 📚 **Conteúdo Educacional**: Blog com posts sobre trabalho remoto (apenas ADMIN publica)
- 💬 **RemoteCoach (Chat IA)**: Histórico completo de conversas dos usuários com assistente virtual
- 🏢 **Marketplace**: Empresas parceiras com vagas remotas
- 🎓 **Gamificação**: Certificados automáticos por engajamento (10+ posts lidos)
- 📊 **Analytics**: Cálculo de compatibilidade do usuário com mercado remoto ('Y'/'N')
- 🔄 **Integração NoSQL**: Pipeline Oracle → MongoDB para análises avançadas

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

### 2. Procedure 1 - Histórico do Usuário (15 pontos) 
**`PRC_HISTORICO_USUARIO`** - Procedure principal completa com 3 modos:
- **COMPLETO**: Posts lidos + Certificados + Chat RemoteCoach + Auditoria
- **RESUMO**: Apenas estatísticas agregadas
- **CHAT**: Histórico isolado de conversas com RemoteCoach

**Procedures auxiliares de histórico:**
- `PRC_INSERIR_CHAT_HISTORY` - Registra conversas do RemoteCoach
- `PRC_ATUALIZAR_CHAT_RESPONSE` - Atualiza resposta do chatbot
- `PRC_BUSCAR_HISTORICO_CHAT` - Recupera conversas específicas
- `PRC_LIMPAR_HISTORICO_ANTIGO` - Manutenção de dados antigos

### 3. Procedure 2 - Relatórios e Análises (15 pontos) 
**`PRC_RELATORIO_ENGAJAMENTO`** - Análise completa do sistema:
- Total de usuários ativos
- Posts criados no blog
- Leituras registradas (TB_GS_USER_POST)
- Certificados emitidos
- Top 5 posts mais lidos

**`PRC_REGISTRAR_LEITURA`** - Lógica de negócio inteligente:
- Registro idempotente (não duplica leituras)
- Auto-certificação automática aos 10+ posts lidos com status 'LIDO'
- Incremento de visualizações no post
- Validação de status

### 4. Função 1 - Transformação de Dados (15 pontos) 
**`FN_USER_PROFILE_JSON`** - Gera JSON completo do perfil do usuário:
- Dados pessoais (nome, email, role)
- Estatísticas de engajamento (posts lidos, certificados conquistados)
- Score de compatibilidade (Y/N)
- Lista detalhada de certificados
- Formato: JSON válido para integração com backend Java e app React Native

### 5. Função 2 - Validação com REGEXP (15 pontos) 
**`FN_VALIDAR_EMAIL`** - Validação rigorosa com expressão regular:
- Padrão: `^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$`
- Retorna: 'VALIDO' ou 'INVALIDO'
- Usado na criação de usuários

**`FN_CALC_COMPATIBILIDADE`** - Verifica prontidão para trabalho remoto:
- Analisa TB_GS_USER_POST onde DS_STATUS = 'LIDO'
- Retorna 'Y' se usuário leu 10+ posts (preparado)
- Retorna 'N' caso contrário
- Critério simples baseado em engajamento com conteúdo educacional

### 6. Package PL/SQL (15 pontos) 
**`PKG_REMOTEREADY`** - Encapsulamento completo:
- **Specification**: Interface pública com 9 procedures e 3 functions
- **Body**: Implementação detalhada com tratamento de erros
- **Organização**: Todas procedures e funções agrupadas logicamente
- **Procedures**: Histórico (5) + Relatórios (2) + Negócio (2)
- **Functions**: Transformação JSON (1) + Validações (2)

### 7. Trigger de Auditoria (10 pontos) 
**`TRG_AUD_USUARIO`** - Auditoria automática completa:
- **Eventos**: INSERT, UPDATE, DELETE em TB_GS_USUARIO
- **Dados capturados**: Valores antigos (OLD) e novos (NEW)
- **Rastreamento**: Usuário do banco (USER) e timestamp (SYSTIMESTAMP)
- **Armazenamento**: TB_GS_AUDITORIA para trilha de auditoria
- **Uso**: Segurança e compliance do sistema

### 8. Integração NoSQL - MongoDB (10 pontos) 
**Pipeline completo Oracle → MongoDB:**

**Script de Exportação** (`export_remoteready_json.sql`):
- Gera 6 arquivos JSON separados (usuarios, empresas, blog_posts, certificados, user_posts, chat_history)
- Formato JSON Array compatível com `mongoimport`
- Funções auxiliares: `FN_JSON_ESCAPE`, `FN_JSON_NUMBER`, `FN_JSON_DATE`
- Execução via SPOOL (SQL*Plus/SQLcl)

**Scripts de Importação:**
- `import_data.ps1` (PowerShell - automação Windows)
- `import_mongo.bat` (Batch - linha de comando Windows)
- Comandos manuais `mongoimport` para qualquer plataforma

**Uso no Sistema:**
- Backend Java consulta MongoDB para análises rápidas
- Agregações complexas de comportamento de usuários
- Cache de dados para app React Native

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