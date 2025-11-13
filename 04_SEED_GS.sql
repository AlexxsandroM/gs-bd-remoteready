
-- =============================================
-- 04_SEED_GS.sql
-- Popular dados via PRC_*
-- =============================================

BEGIN
  PRC_INS_USUARIO('Ana Silva','ana.silva@remoteready.dev','123456','ADMIN');
  PRC_INS_USUARIO('Bruno Santos','bruno.santos@remoteready.dev','123456','USER');
  PRC_INS_USUARIO('Carla Souza','carla.souza@remoteready.dev','123456','USER');
  PRC_INS_USUARIO('Diego Lima','diego.lima@remoteready.dev','123456','USER');
  PRC_INS_USUARIO('Eduarda Reis','eduarda.reis@remoteready.dev','123456','USER');
  PRC_INS_USUARIO('Felipe Camargo','felipe.camargo@remoteready.dev','123456','USER');
  PRC_INS_USUARIO('Guilherme Silva','guilherme.silva@remoteready.dev','123456','USER');
  PRC_INS_USUARIO('Helena Souza','helena.souza@remoteready.dev','123456','USER');
  PRC_INS_USUARIO('Igor Mendes','igor.mendes@remoteready.dev','123456','USER');
  PRC_INS_USUARIO('Julia Rocha','julia.rocha@remoteready.dev','123456','USER');
END;
/

BEGIN
  PRC_INS_EMPRESA('RemoteX','Plataforma de recrutamento remoto','RH','Y',NULL,'https://remotex.example');
  PRC_INS_EMPRESA('CloudWork','Ferramentas de colaboração','Tecnologia','Y',NULL,'https://cloudwork.example');
  PRC_INS_EMPRESA('GreenFuture','Consultoria ESG','Consultoria','N',NULL,'https://greenfuture.example');
  PRC_INS_EMPRESA('EduFlex','Cursos online','Educação','Y',NULL,'https://eduflex.example');
  PRC_INS_EMPRESA('DataBridge','Análise de dados','Tecnologia','N',NULL,'https://databridge.example');
  PRC_INS_EMPRESA('MindCare','Saúde mental corporativa','Saúde','Y',NULL,'https://mindcare.example');
  PRC_INS_EMPRESA('TaskFlow','Automação de processos','Tecnologia','Y',NULL,'https://taskflow.example');
  PRC_INS_EMPRESA('SkillHub','Marketplace de cursos','Educação','N',NULL,'https://skillhub.example');
  PRC_INS_EMPRESA('GlobalTeams','Times distribuídos','RH','Y',NULL,'https://globalteams.example');
  PRC_INS_EMPRESA('OpenTalent','Gig economy','RH','N',NULL,'https://opentalent.example');
END;
/
DECLARE
  v_imgs SYS.ODCIVARCHAR2LIST := SYS.ODCIVARCHAR2LIST(
    'https://firebasestorage.googleapis.com/v0/b/bucket/o/img1.jpg?alt=media',
    'https://firebasestorage.googleapis.com/v0/b/bucket/o/img2.jpg?alt=media',
    'https://firebasestorage.googleapis.com/v0/b/bucket/o/img3.jpg?alt=media',
    'https://firebasestorage.googleapis.com/v0/b/bucket/o/img4.jpg?alt=media',
    'https://firebasestorage.googleapis.com/v0/b/bucket/o/img5.jpg?alt=media',
    'https://firebasestorage.googleapis.com/v0/b/bucket/o/img6.jpg?alt=media',
    'https://firebasestorage.googleapis.com/v0/b/bucket/o/img7.jpg?alt=media',
    'https://firebasestorage.googleapis.com/v0/b/bucket/o/img8.jpg?alt=media',
    'https://firebasestorage.googleapis.com/v0/b/bucket/o/img9.jpg?alt=media',
    'https://firebasestorage.googleapis.com/v0/b/bucket/o/img10.jpg?alt=media'
  );
BEGIN
  FOR i IN 1..10 LOOP
    PRC_INS_POST('Produtividade no remoto #'||i,
                 'Dicas práticas para foco, ergonomia e rotina no home office.',
                 v_imgs(i),'produtividade',
                 CASE WHEN i <= 2 THEN 1 WHEN i <= 4 THEN 2 ELSE 3 END);
  END LOOP;
END;
/
BEGIN
  PRC_INS_CERTIFICADO(1,'Remote Work Ready');
  PRC_INS_CERTIFICADO(2,'Time Management Basics');
  PRC_INS_CERTIFICADO(3,'Remote Communication');
  PRC_INS_CERTIFICADO(4,'Async Collaboration');
  PRC_INS_CERTIFICADO(5,'Cyber Hygiene');
  PRC_INS_CERTIFICADO(6,'AI Literacy');
  PRC_INS_CERTIFICADO(7,'Cloud Basics');
  PRC_INS_CERTIFICADO(8,'Digital Wellbeing');
  PRC_INS_CERTIFICADO(9,'DevOps Foundations');
  PRC_INS_CERTIFICADO(10,'Agile Mindset');
END;
/

BEGIN
  PRC_INS_CHAT(1,'Como organizar meu dia no remoto?','Use blocos de tempo e pausas programadas.');
  PRC_INS_CHAT(2,'Quais empresas contratam remoto?','Veja a aba Empresas e filtre por Hiring Now.');
  PRC_INS_CHAT(3,'Como melhorar meu currículo?','Foque em resultados e projetos; adicione certificações.');
  PRC_INS_CHAT(4,'Quais hard skills estudar?','Git, APIs REST, Cloud, SQL/NoSQL, testes.');
  PRC_INS_CHAT(5,'Ergonomia em casa?','Cadeira adequada e tela na altura dos olhos.');
  PRC_INS_CHAT(6,'Como estudar IA?','Comece por prompts, fundamentos de ML e ética.');
  PRC_INS_CHAT(7,'Foco sem distrações?','Desligue notificações e use pomodoro.');
  PRC_INS_CHAT(8,'Inglês é necessário?','Ajuda muito; pratique 15 min/dia.');
  PRC_INS_CHAT(9,'Como negociar horário?','Combine metas claras e entregas semanais.');
  PRC_INS_CHAT(10,'Home x Coworking?','Teste semanalmente e compare produtividade.');
END;
/

BEGIN
  PRC_EXPORT_DATASET;
END;
/
COMMIT;
