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
- 🔄 **Integração**: Pipeline Oracle → MongoDB para análises

---

## ✅ Requisitos Atendidos (100 pontos)

### 1. Modelagem Relacional 3FN (10 pts) ✅
- 8 tabelas normalizadas (incluindo histórico de chat)
- PKs, FKs, UKs, CHECKs implementados
- Relacionamentos corretos com ON DELETE CASCADE

**Tabelas:**
- `TB_GS_USUARIO` - Usuários (ADMIN/USER)
- `TB_GS_EMPRESA` - Empresas parceiras
- `TB_GS_BLOG_POST` - Posts educacionais
- `TB_GS_CERTIFICADO` - Certificados de conquista
- `TB_GS_POST_LEITURA` - Registro de leituras
- `TB_GS_CHAT_HISTORY` - **NOVA**: Histórico de conversas com IA
- `TB_GS_AUDITORIA` - Trilha de auditoria
- `TB_GS_EXPORT_LOG` - Controle de exportações

### 2. Procedure 1 - Histórico do Usuário (15 pts) ✅
Procedures especializadas em histórico encapsuladas no package:
- `PRC_HISTORICO_USUARIO` - Exibe histórico completo do usuário (posts, chat, auditoria)
- `PRC_INSERIR_CHAT_HISTORY` - Registra conversas com IA do usuário  
- `PRC_INSERIR_USUARIO` - Create com validação (mantida)
- `PRC_INSERIR_POST` - Validação rigorosa de role ADMIN
- `PRC_INSERIR_EMPRESA` - Insert com defaults

### 3. Procedure 2 - Relatórios (15 pts) ✅
- `PRC_RELATORIO_ENGAJAMENTO` - Análise de métricas (usuários, posts, leituras, certificados)
- `PRC_REGISTRAR_LEITURA` - Registro com auto-certificação aos 10+ posts

### 4. Função 1 - Transformação (15 pts) ✅
- `FN_USER_PROFILE_JSON` - Gera JSON completo do perfil:
  - Dados pessoais
  - Estatísticas (posts lidos, certificados)
  - Score de compatibilidade
  - Lista de certificados

### 5. Função 2 - Validação REGEXP (15 pts) ✅
- `FN_VALIDAR_EMAIL` - Validação com expressão regular
- `FN_CALC_COMPATIBILIDADE` - Cálculo de score (0-100) baseado em:
  - Quantidade de posts lidos (peso 50%)
  - Certificados conquistados (peso 30%)
  - Tempo na plataforma (peso 20%)

### 6. Empacotamento (10 pts) ✅
- Package `PKG_REMOTEREADY` com:
  - Specification (interface pública)
  - Body (implementação)
  - Todas procedures e funções organizadas

### 7. Trigger de Auditoria (10 pts) ✅
- `TRG_AUD_USUARIO` - Registra automaticamente:
  - INSERT, UPDATE, DELETE
  - Dados antigos e novos
  - Usuário do banco
  - Timestamp

### 8. Integração NoSQL (10 pts) ✅
- `PRC_EXPORT_MONGODB` - Exportação completa:
  - Gera array JSON de todos os usuários
  - Inclui perfis completos
  - Salva em TB_GS_EXPORT_LOG
  - Pronto para import no MongoDB

---

## 🗂️ Arquivos do Projeto

```
remoteready-bd/
├── gs-bd-remoteready-otimizado.sql    # Script principal (completo)
├── export-mongodb.sql                  # Script de exportação facilitado
├── GUIA_DE_USO.md                      # Documentação detalhada
└── README.md                           # Este arquivo
```

---

## 🚀 Como Executar

### Passo 1: Executar Script Principal

```sql
-- No SQL*Plus ou SQL Developer
sqlplus usuario/senha@database

SET SERVEROUTPUT ON SIZE 1000000;
@gs-bd-remoteready-otimizado.sql
```

**O script fará automaticamente:**
1. Limpar estruturas antigas
2. Criar tabelas e sequences
3. Criar package completo
4. Criar triggers
5. Inserir dados de teste
6. Executar testes de validação

### Passo 2: Testar Funcionalidades

```sql
-- CRUD e Histórico
DECLARE
    V_ID NUMBER;
    V_CHAT_ID NUMBER;
BEGIN
    -- Criar usuário
    PKG_REMOTEREADY.PRC_INSERIR_USUARIO(
        'Teste User',
        'teste@email.com',
        'senha123',
        'USER',
        V_ID
    );
    DBMS_OUTPUT.PUT_LINE('Usuário criado: ' || V_ID);
    
    -- Inserir conversa no chat
    PKG_REMOTEREADY.PRC_INSERIR_CHAT_HISTORY(
        V_ID,
        'Como posso melhorar meu currículo para trabalho remoto?',
        'Aqui estão algumas dicas para aprimorar seu currículo...',
        V_CHAT_ID
    );
    
    -- Ver histórico completo
    PKG_REMOTEREADY.PRC_HISTORICO_USUARIO(V_ID, 'COMPLETO');
END;
/

-- Validação REGEXP
SELECT PKG_REMOTEREADY.FN_VALIDAR_EMAIL('teste@email.com') FROM DUAL;

-- Compatibilidade
SELECT PKG_REMOTEREADY.FN_CALC_COMPATIBILIDADE(2) FROM DUAL;

-- JSON Perfil
SELECT PKG_REMOTEREADY.FN_USER_PROFILE_JSON(2) FROM DUAL;

-- Relatório
EXEC PKG_REMOTEREADY.PRC_RELATORIO_ENGAJAMENTO(30);

-- Histórico específico de chat
EXEC PKG_REMOTEREADY.PRC_HISTORICO_USUARIO(1, 'CHAT');
```

### Passo 3: Exportar para MongoDB

```sql
-- Opção 1: Usando procedure direta
EXEC PKG_REMOTEREADY.PRC_EXPORT_MONGODB('FULL');

-- Opção 2: Usando script facilitador
@export-mongodb.sql
```

**Extrair JSON:**
```sql
SELECT DS_DATASET_JSON
FROM TB_GS_EXPORT_LOG
WHERE ID_EXPORT = (SELECT MAX(ID_EXPORT) FROM TB_GS_EXPORT_LOG);
```

**Importar no MongoDB:**
```bash
mongoimport --db remoteready --collection users_profile --file remoteready_export.json --jsonArray
```

---

## 📊 Exemplo de JSON Exportado

```json
[
  {
    "id_usuario": 2,
    "nome": "João Silva",
    "email": "joao.silva@email.com",
    "role": "USER",
    "ativo": "Y",
    "data_criacao": "2025-11-16",
    "posts_lidos": 3,
    "certificados": 0,
    "compatibilidade_remoto": 15,
    "lista_certificados": []
  }
]
```

---

## 🎯 Destaques Técnicos

### 🔹 Inovações Implementadas:
- **Gamificação no BD**: Certificado automático ao ler 10+ posts
- **Histórico de Chat**: Armazenamento completo de conversas com IA
- **Score de Compatibilidade**: Algoritmo ponderado (0-100)
- **JSON Nativo**: Construção manual sem dependências
- **Auditoria Automática**: Trigger para rastreamento completo
- **Pipeline Híbrido**: Oracle (OLTP) → MongoDB (OLAP)
- **Controle de Roles**: Validação rigorosa USER vs ADMIN

### 🔹 Performance:
- Índices estratégicos em colunas críticas
- Sequences com CACHE para melhor throughput
- Constraints para garantir integridade
- UNIQUE para evitar duplicatas

### 🔹 Segurança:
- Validação de role (apenas ADMIN cria posts)
- Validação de email com REGEXP
- Auditoria completa de operações
- Tratamento de exceções robusto

### 🔹 Manutenibilidade:
- Código organizado em package único
- Documentação inline
- Mensagens de erro descritivas
- Dados de teste incluídos

---

## 📈 Modelo de Dados

```
TB_GS_USUARIO (usuários)
    ↓ (1:N)
TB_GS_BLOG_POST (posts do blog)
    ↓ (1:N)
TB_GS_POST_LEITURA (leituras) ← (N:1) → TB_GS_USUARIO
    ↓ (trigger automático)
TB_GS_CERTIFICADO (certificados) ← (N:1) → TB_GS_USUARIO

TB_GS_CHAT_HISTORY (histórico chat) ← (N:1) → TB_GS_USUARIO

TB_GS_EMPRESA (empresas parceiras - independente)
TB_GS_AUDITORIA (auditoria - independente)
TB_GS_EXPORT_LOG (exports - independente)
```

---

## 🧪 Testes Incluídos

O script executa automaticamente 11 testes:

1. **CRUD com Package** - Inserção de usuários e empresas
2. **Validação de Email** - REGEXP
3. **Cálculo de Compatibilidade** - Algoritmo ponderado
4. **JSON do Perfil** - Transformação
5. **Relatório de Engajamento** - Análise
6. **Exportação MongoDB** - Integração NoSQL
7. **Histórico de Chat** - **NOVO**: Inserção e consulta de conversas
8. **Histórico Completo** - **NOVO**: Visualização completa do usuário
9. **Histórico de Posts** - **NOVO**: Posts criados por ADMIN
10. **Histórico de Chat** - **NOVO**: Conversas específicas
11. **Auditoria** - Verificação de logs

---

## 📏 Regras de Negócio

1. **Apenas ADMIN pode criar posts** (validado na procedure)
2. **Usuários comuns apenas leem posts** e usam chat
3. **Email único por usuário** (UNIQUE constraint)
4. **Leitura única por usuário/post** (UNIQUE constraint composta)
5. **Certificado automático** com 10+ leituras
6. **Histórico de chat** preservado por usuário
7. **Visualizações incrementadas** automaticamente
8. **Auditoria automática** em todas operações de usuário

---

## 🔧 Tecnologias Utilizadas

- **Oracle Database 19c+**
- **PL/SQL** (Procedures, Functions, Triggers, Packages)
- **JSON** (manipulação manual via CLOB)
- **MongoDB** (destino da integração)
- **REGEXP** (validações)

---

## 📞 Informações do Projeto

- **Aluno:** Alexsandro Macedo
- **RM:** 557068
- **Disciplina:** MASTERING RELATIONAL AND NON-RELATIONAL DATABASE
- **Professor:** [Nome do Professor]
- **Turma:** 2TDSR
- **Data:** Novembro 2025

---

## 📖 Documentação Adicional

Para guia detalhado de uso, consulte: [GUIA_DE_USO.md](GUIA_DE_USO.md)

Para exemplos de queries e testes: Execute o script principal e veja os outputs

---

## 🎓 Apresentação

### Roteiro Sugerido (5 min):

1. **Introdução** (30s) - Contexto do RemoteReady com Chat IA
2. **Modelagem** (1min) - Mostrar 8 tabelas e relacionamentos incluindo histórico
3. **Procedures/Funções** (1min 30s) - Demonstrar histórico do usuário e validações
4. **Gamificação** (1min) - Auto-certificação em ação
5. **Integração NoSQL** (1min) - Export e import MongoDB com dados de chat

---

## ✨ Diferenciais

✅ **Código limpo e organizado**  
✅ **Empacotamento completo**  
✅ **Validações REGEXP**  
✅ **Gamificação automática**  
✅ **Histórico completo do usuário**  
✅ **Chat IA integrado ao banco**  
✅ **JSON manual (sem dependências)**  
✅ **Integração Oracle-MongoDB funcional**  
✅ **Dados de teste incluídos**  
✅ **Documentação completa**  

---

**Este projeto demonstra domínio completo em bancos relacionais e não-relacionais, integrando ACID com flexibilidade NoSQL para cenários empresariais reais, incluindo funcionalidades modernas como chat com IA e histórico completo do usuário. 🚀**