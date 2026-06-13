INSERT INTO company (company_id, company_name, company_email, company_inscription) OVERRIDING SYSTEM VALUE VALUES
(1, 'FitCorp', 'contact@fitcorp.com', '2021-03-15'),
(2, 'HealthPlus', 'info@healthplus.fr', '2020-07-01'),
(3, 'SportElite', 'admin@sportelite.io', '2022-01-10'),
(4, 'WellnessGroup', 'hello@wellnessgroup.com', '2021-11-20'),
(5, 'ActiveLife', 'contact@activelife.fr', '2023-02-28');

INSERT INTO subscription (subscription_id, subscription_price, subscription_name, company_id, subscription_company_end) OVERRIDING SYSTEM VALUE VALUES
(1, 0.00, 'Freemium', NULL, NULL),
(2, 9.99, 'Premium', NULL, NULL),
(3, 19.99, 'Premium+', NULL, NULL),
(4, 149.99, 'B2B', 1, '2025-03-15'),
(5, 149.99, 'B2B', 2, '2025-07-01'),
(6, 149.99, 'B2B', 3, '2026-01-10'),
(7, 149.99, 'B2B', 4, '2025-11-20'),
(8, 149.99, 'B2B', 5, '2026-02-28');

INSERT INTO authorization_ (authorization_id, authorization_type) OVERRIDING SYSTEM VALUE VALUES
(1, 'Freemium'),
(2, 'Premium'),
(3, 'Premium+');

INSERT INTO subscription_authorization (subscription_id, authorization_id) VALUES (1, 1);
INSERT INTO subscription_authorization (subscription_id, authorization_id) VALUES (2, 1), (2, 2);
INSERT INTO subscription_authorization (subscription_id, authorization_id) VALUES (3, 1), (3, 2), (3, 3);
INSERT INTO subscription_authorization (subscription_id, authorization_id) VALUES (4, 1), (4, 2), (4, 3);
INSERT INTO subscription_authorization (subscription_id, authorization_id) VALUES (5, 1), (5, 2), (5, 3);
INSERT INTO subscription_authorization (subscription_id, authorization_id) VALUES (6, 1), (6, 2), (6, 3);
INSERT INTO subscription_authorization (subscription_id, authorization_id) VALUES (7, 1), (7, 2), (7, 3);
INSERT INTO subscription_authorization (subscription_id, authorization_id) VALUES (8, 1), (8, 2), (8, 3);

INSERT INTO sport_equipment (sport_equipment_id, sport_equipment_name) OVERRIDING SYSTEM VALUE VALUES
(1, 'Haltères'),
(2, 'Barre de traction'),
(3, 'Tapis de sol'),
(4, 'Corde à sauter'),
(5, 'Kettlebell'),
(6, 'Bande élastique'),
(7, 'Banc de musculation'),
(8, 'Vélo stationnaire'),
(9, 'Treadmill'),
(10, 'TRX');

INSERT INTO sport_exercise (sport_exercise_id, sport_exercise_name, sport_exercise_objective, sport_exercise_difficulty, sport_exercise_duration, sport_exercise_muscle_group, sport_exercise_video, sport_exercise_instruction, sport_exercise_cal_burned) OVERRIDING SYSTEM VALUE VALUES
(1, 'Pompes', 'muscle_gain', 'beginner', 10, 'chest', 'https://vid.example.com/pompes', 'Position planche, descendre la poitrine vers le sol, remonter.', 60),
(2, 'Tractions', 'muscle_gain', 'intermediate', 10, 'back', 'https://vid.example.com/tractions', 'Saisir la barre, tirer le corps vers le haut jusqu''au menton au-dessus.', 80),
(3, 'Squats', 'muscle_gain', 'beginner', 15, 'quadriceps', 'https://vid.example.com/squats', 'Pieds écartés, descendre les hanches jusqu''aux genoux à 90°.', 100),
(4, 'Planche', 'endurance', 'beginner', 5, 'abs', 'https://vid.example.com/planche', 'Position planche sur les avant-bras, maintenir le corps droit.', 30),
(5, 'Burpees', 'endurance', 'intermediate', 10, 'full_body', 'https://vid.example.com/burpees', 'Sauter, pompe, revenir debout en saut.', 150),
(6, 'Fentes avant', 'muscle_gain', 'beginner', 12, 'quadriceps', 'https://vid.example.com/fentes', 'Un pied en avant, genou à 90°, revenir.', 80),
(7, 'Soulevé de terre', 'muscle_gain', 'advanced', 15, 'back', 'https://vid.example.com/sdt', 'Barre au sol, dos droit, soulever jusqu''à la debout.', 120),
(8, 'Développé couché', 'muscle_gain', 'intermediate', 12, 'chest', 'https://vid.example.com/bench', 'Sur le banc, descendre la barre sur la poitrine, pousser.', 90),
(9, 'Rowing haltères', 'muscle_gain', 'intermediate', 12, 'back', 'https://vid.example.com/rowing', 'Penché en avant, tirer l''haltère vers le bas-ventre.', 70),
(10, 'Curl biceps', 'muscle_gain', 'beginner', 12, 'biceps', 'https://vid.example.com/curl', 'Haltère en main, plier le coude pour amener le poids vers l''épaule.', 50),
(11, 'Dips triceps', 'muscle_gain', 'intermediate', 12, 'triceps', 'https://vid.example.com/dips', 'Mains sur banc, descendre le corps, remonter.', 65),
(12, 'Gainage latéral', 'endurance', 'beginner', 5, 'abs', 'https://vid.example.com/gainage', 'Sur le côté sur un avant-bras, corps aligné.', 25),
(13, 'Mountain climbers', 'endurance', 'intermediate', 10, 'abs', 'https://vid.example.com/mtnclimbers', 'Position planche, ramener alternativement les genoux vers la poitrine.', 110),
(14, 'Hip thrust', 'muscle_gain', 'intermediate', 12, 'glutes', 'https://vid.example.com/hipthrust', 'Dos sur le banc, pousser les hanches vers le haut avec une barre.', 85),
(15, 'Corde à sauter', 'endurance', 'beginner', 15, 'full_body', 'https://vid.example.com/corde', 'Sauter à la corde en rythme.', 140),
(16, 'Press militaire', 'muscle_gain', 'intermediate', 12, 'shoulders', 'https://vid.example.com/press', 'Barre en bas du menton, pousser vers le haut.', 75),
(17, 'Élévations latérales', 'muscle_gain', 'beginner', 12, 'shoulders', 'https://vid.example.com/elevations', 'Haltères sur les côtés, lever jusqu''à l''horizontale.', 45),
(18, 'Extensions triceps', 'muscle_gain', 'beginner', 12, 'triceps', 'https://vid.example.com/exttri', 'Haltère derrière la tête, étendre le bras.', 40),
(19, 'Crunchs', 'muscle_gain', 'beginner', 15, 'abs', 'https://vid.example.com/crunchs', 'Sur le dos, genoux pliés, contracter les abdos pour monter.', 35),
(20, 'Sprint 30s', 'endurance', 'advanced', 5, 'full_body', 'https://vid.example.com/sprint', 'Sprint maximal pendant 30 secondes.', 120);

INSERT INTO sport_exercise_equipment (sport_exercise_id, sport_equipment_id)
SELECT se.sport_exercise_id, eq.sport_equipment_id
FROM (VALUES
  ('Pompes','Tapis de sol'),
  ('Tractions','Barre de traction'),
  ('Squats','Tapis de sol'),
  ('Planche','Tapis de sol'),
  ('Burpees','Tapis de sol'),
  ('Fentes avant','Tapis de sol'),
  ('Soulevé de terre','Haltères'),
  ('Développé couché','Banc de musculation'),
  ('Développé couché','Haltères'),
  ('Rowing haltères','Haltères'),
  ('Curl biceps','Haltères'),
  ('Dips triceps','Banc de musculation'),
  ('Gainage latéral','Tapis de sol'),
  ('Mountain climbers','Tapis de sol'),
  ('Hip thrust','Banc de musculation'),
  ('Corde à sauter','Corde à sauter'),
  ('Press militaire','Haltères'),
  ('Élévations latérales','Haltères'),
  ('Extensions triceps','Haltères'),
  ('Crunchs','Tapis de sol'),
  ('Sprint 30s','Treadmill')
) AS pairs(ex_name, eq_name)
JOIN sport_exercise se ON se.sport_exercise_name = pairs.ex_name
JOIN sport_equipment eq ON eq.sport_equipment_name = pairs.eq_name;

INSERT INTO sport_session (sport_session_id, sport_session_name) OVERRIDING SYSTEM VALUE VALUES
(1, 'Full Body Débutant A'),
(2, 'Full Body Débutant B'),
(3, 'Upper Body Force'),
(4, 'Lower Body Force'),
(5, 'Cardio HIIT'),
(6, 'Core & Abdos'),
(7, 'Push Day'),
(8, 'Pull Day'),
(9, 'Legs Day'),
(10, 'Cardio Endurance'),
(11, 'Full Body Intermédiaire'),
(12, 'Upper Body Hypertrophie'),
(13, 'Lower Body Hypertrophie'),
(14, 'HIIT Avancé'),
(15, 'Récupération Active');

INSERT INTO sport_session_exercise (sport_session_id, sport_exercise_id, sport_session_exercise_rank)
SELECT s.sport_session_id, e.sport_exercise_id, v.rank
FROM (VALUES
  -- Full Body Débutant A
  ('Full Body Débutant A','Squats',1),
  ('Full Body Débutant A','Pompes',2),
  ('Full Body Débutant A','Crunchs',3),
  ('Full Body Débutant A','Planche',4),
  ('Full Body Débutant A','Corde à sauter',5),
  -- Full Body Débutant B
  ('Full Body Débutant B','Fentes avant',1),
  ('Full Body Débutant B','Pompes',2),
  ('Full Body Débutant B','Curl biceps',3),
  ('Full Body Débutant B','Gainage latéral',4),
  ('Full Body Débutant B','Corde à sauter',5),
  -- Upper Body Force
  ('Upper Body Force','Développé couché',1),
  ('Upper Body Force','Tractions',2),
  ('Upper Body Force','Press militaire',3),
  ('Upper Body Force','Rowing haltères',4),
  ('Upper Body Force','Curl biceps',5),
  ('Upper Body Force','Dips triceps',6),
  -- Lower Body Force
  ('Lower Body Force','Squats',1),
  ('Lower Body Force','Soulevé de terre',2),
  ('Lower Body Force','Fentes avant',3),
  ('Lower Body Force','Hip thrust',4),
  -- Cardio HIIT
  ('Cardio HIIT','Burpees',1),
  ('Cardio HIIT','Corde à sauter',2),
  ('Cardio HIIT','Mountain climbers',3),
  ('Cardio HIIT','Sprint 30s',4),
  -- Core & Abdos
  ('Core & Abdos','Planche',1),
  ('Core & Abdos','Crunchs',2),
  ('Core & Abdos','Gainage latéral',3),
  ('Core & Abdos','Mountain climbers',4),
  -- Push Day
  ('Push Day','Développé couché',1),
  ('Push Day','Pompes',2),
  ('Push Day','Press militaire',3),
  ('Push Day','Élévations latérales',4),
  ('Push Day','Dips triceps',5),
  ('Push Day','Extensions triceps',6),
  -- Pull Day
  ('Pull Day','Tractions',1),
  ('Pull Day','Rowing haltères',2),
  ('Pull Day','Curl biceps',3),
  -- Legs Day
  ('Legs Day','Squats',1),
  ('Legs Day','Soulevé de terre',2),
  ('Legs Day','Fentes avant',3),
  ('Legs Day','Hip thrust',4),
  -- Cardio Endurance
  ('Cardio Endurance','Corde à sauter',1),
  ('Cardio Endurance','Sprint 30s',2),
  ('Cardio Endurance','Burpees',3),
  -- Full Body Intermédiaire
  ('Full Body Intermédiaire','Soulevé de terre',1),
  ('Full Body Intermédiaire','Développé couché',2),
  ('Full Body Intermédiaire','Squats',3),
  ('Full Body Intermédiaire','Tractions',4),
  ('Full Body Intermédiaire','Burpees',5),
  ('Full Body Intermédiaire','Crunchs',6),
  -- Upper Body Hypertrophie
  ('Upper Body Hypertrophie','Développé couché',1),
  ('Upper Body Hypertrophie','Rowing haltères',2),
  ('Upper Body Hypertrophie','Pompes',3),
  ('Upper Body Hypertrophie','Tractions',4),
  ('Upper Body Hypertrophie','Élévations latérales',5),
  ('Upper Body Hypertrophie','Press militaire',6),
  ('Upper Body Hypertrophie','Curl biceps',7),
  ('Upper Body Hypertrophie','Dips triceps',8),
  -- Lower Body Hypertrophie
  ('Lower Body Hypertrophie','Squats',1),
  ('Lower Body Hypertrophie','Fentes avant',2),
  ('Lower Body Hypertrophie','Hip thrust',3),
  ('Lower Body Hypertrophie','Soulevé de terre',4),
  -- HIIT Avancé
  ('HIIT Avancé','Sprint 30s',1),
  ('HIIT Avancé','Burpees',2),
  ('HIIT Avancé','Mountain climbers',3),
  ('HIIT Avancé','Corde à sauter',4),
  ('HIIT Avancé','Pompes',5),
  -- Récupération Active
  ('Récupération Active','Planche',1),
  ('Récupération Active','Gainage latéral',2),
  ('Récupération Active','Crunchs',3)
) AS v(session_name, ex_name, rank)
JOIN sport_session s ON s.sport_session_name = v.session_name
JOIN sport_exercise e ON e.sport_exercise_name = v.ex_name;

INSERT INTO sport_program (sport_program_id, sport_program_name, sport_program_objective, sport_program_sessions, sport_program_duration, sport_program_is_active) OVERRIDING SYSTEM VALUE VALUES
(1, 'Débutant Total Body 4 sem', 'muscle_gain', 12, 28, TRUE),
(2, 'Prise de Masse Intermédiaire', 'muscle_gain', 16, 56, TRUE),
(3, 'Cardio Fat Burner', 'weight_loss', 12, 28, TRUE),
(4, 'Endurance Elite', 'endurance', 20, 60, TRUE),
(5, 'Flexibilité & Mobilité', 'flexibility', 8, 28, TRUE),
(6, 'Maintien Forme', 'maintenance', 12, 42, TRUE),
(7, 'HIIT Warrior', 'weight_loss', 16, 42, TRUE),
(8, 'Force & Puissance', 'muscle_gain', 20, 70, TRUE);

INSERT INTO program_sport_session (sport_program_id, sport_session_id, program_sport_session_rank) VALUES
(1, 1, 1), (1, 6, 2), (1, 2, 3),
(1, 1, 4), (1, 6, 5), (1, 2, 6),
(1, 1, 7), (1, 6, 8), (1, 2, 9),
(1, 1, 10), (1, 6, 11), (1, 2, 12);

INSERT INTO program_sport_session (sport_program_id, sport_session_id, program_sport_session_rank) VALUES
(2, 7, 1), (2, 8, 2), (2, 9, 3), (2, 15, 4),
(2, 7, 5), (2, 8, 6), (2, 9, 7), (2, 15, 8),
(2, 12, 9), (2, 8, 10), (2, 13, 11), (2, 15, 12),
(2, 12, 13), (2, 8, 14), (2, 13, 15), (2, 15, 16);

INSERT INTO program_sport_session (sport_program_id, sport_session_id, program_sport_session_rank) VALUES
(3, 5, 1), (3, 10, 2), (3, 6, 3),
(3, 5, 4), (3, 10, 5), (3, 6, 6),
(3, 5, 7), (3, 10, 8), (3, 6, 9),
(3, 5, 10), (3, 10, 11), (3, 6, 12);

INSERT INTO program_sport_session (sport_program_id, sport_session_id, program_sport_session_rank) VALUES
(4, 10, 1), (4, 5, 2), (4, 15, 3), (4, 10, 4), (4, 5, 5),
(4, 10, 6), (4, 5, 7), (4, 15, 8), (4, 10, 9), (4, 5, 10),
(4, 10, 11), (4, 14, 12), (4, 15, 13), (4, 10, 14), (4, 14, 15),
(4, 10, 16), (4, 5, 17), (4, 15, 18), (4, 10, 19), (4, 14, 20);

INSERT INTO program_sport_session (sport_program_id, sport_session_id, program_sport_session_rank) VALUES
(7, 14, 1), (7, 5, 2), (7, 15, 3), (7, 14, 4),
(7, 5, 5), (7, 6, 6), (7, 14, 7), (7, 5, 8),
(7, 15, 9), (7, 14, 10), (7, 5, 11), (7, 6, 12),
(7, 14, 13), (7, 5, 14), (7, 15, 15), (7, 14, 16);

INSERT INTO program_sport_session (sport_program_id, sport_session_id, program_sport_session_rank) VALUES
(8, 3, 1), (8, 4, 2), (8, 15, 3), (8, 3, 4), (8, 4, 5),
(8, 11, 6), (8, 3, 7), (8, 4, 8), (8, 15, 9), (8, 11, 10),
(8, 3, 11), (8, 4, 12), (8, 15, 13), (8, 11, 14), (8, 3, 15),
(8, 4, 16), (8, 15, 17), (8, 11, 18), (8, 3, 19), (8, 4, 20);

INSERT INTO ingredient (ingredient_id, ingredient_name, ingredient_type, ingredient_energy_100g, ingredient_protein_100g, ingredient_fiber_100g, ingredient_sugars_100g, ingredient_carbohydrate_100g, ingredient_salt_100g, ingredient_fats_100g, ingredient_saturated_fats_100g) OVERRIDING SYSTEM VALUE VALUES
(1, 'Blanc de poulet', 'meat', 110.0, 23.0, 0.0, 0.0, 0.0, 0.07, 1.2, 0.3),
(2, 'Riz blanc cuit', 'grain', 130.0, 2.7, 0.4, 0.1, 28.0, 0.01, 0.3, 0.1),
(3, 'Brocoli', 'vegetable', 34.0, 2.8, 2.6, 1.7, 6.6, 0.04, 0.4, 0.1),
(4, 'Saumon', 'fish', 208.0, 20.0, 0.0, 0.0, 0.0, 0.06, 13.0, 3.1),
(5, 'Oeuf entier', 'dairy', 143.0, 13.0, 0.0, 0.4, 0.7, 0.14, 10.0, 3.1),
(6, 'Flocons d''avoine', 'grain', 389.0, 17.0, 10.6, 1.1, 66.0, 0.01, 7.0, 1.3),
(7, 'Banane', 'fruit', 89.0, 1.1, 2.6, 12.2, 23.0, 0.0, 0.3, 0.1),
(8, 'Amande', 'other', 579.0, 21.0, 12.5, 4.4, 22.0, 0.0, 50.0, 3.8),
(9, 'Yaourt grec nature', 'dairy', 59.0, 10.0, 0.0, 3.6, 3.6, 0.06, 0.4, 0.1),
(10, 'Tomate', 'vegetable', 18.0, 0.9, 1.2, 2.6, 3.9, 0.01, 0.2, 0.0),
(11, 'Épinards', 'vegetable', 23.0, 2.9, 2.2, 0.4, 3.6, 0.08, 0.4, 0.1),
(12, 'Pâtes complètes cuites', 'grain', 157.0, 5.8, 3.9, 0.6, 30.0, 0.0, 1.1, 0.2),
(13, 'Thon en conserve', 'fish', 132.0, 29.0, 0.0, 0.0, 0.0, 0.8, 1.0, 0.3),
(14, 'Lentilles cuites', 'legume', 116.0, 9.0, 7.9, 1.8, 20.0, 0.0, 0.4, 0.1),
(15, 'Patate douce', 'vegetable', 86.0, 1.6, 3.0, 4.2, 20.0, 0.0, 0.1, 0.0),
(16, 'Beurre de cacahuète', 'other', 588.0, 25.0, 6.0, 9.0, 20.0, 0.0, 50.0, 10.0),
(17, 'Cottage cheese', 'dairy', 98.0, 11.0, 0.0, 3.4, 3.4, 0.4, 4.3, 1.7),
(18, 'Huile d''olive', 'other', 884.0, 0.0, 0.0, 0.0, 0.0, 0.0, 100.0, 13.8),
(19, 'Pomme', 'fruit', 52.0, 0.3, 2.4, 10.4, 14.0, 0.0, 0.2, 0.0),
(20, 'Carotte', 'vegetable', 41.0, 0.9, 2.8, 4.7, 10.0, 0.07, 0.2, 0.0),
(21, 'Boeuf haché 5%', 'meat', 137.0, 21.0, 0.0, 0.0, 0.0, 0.07, 5.0, 2.0),
(22, 'Quinoa cuit', 'grain', 120.0, 4.4, 2.8, 0.9, 21.0, 0.01, 1.9, 0.2),
(23, 'Fromage blanc 0%', 'dairy', 45.0, 8.0, 0.0, 4.0, 4.0, 0.06, 0.2, 0.1),
(24, 'Poivron rouge', 'vegetable', 31.0, 1.0, 2.1, 4.2, 6.0, 0.04, 0.3, 0.0),
(25, 'Myrtille', 'fruit', 57.0, 0.7, 2.4, 10.0, 14.5, 0.0, 0.3, 0.0);

INSERT INTO ingredient_allergy (ingredient_id, allergy) VALUES
(5, 'eggs'),
(6, 'gluten'),
(8, 'nuts'),
(9, 'milk'),
(12, 'gluten'),
(13, 'fish'),
(16, 'peanuts'),
(17, 'milk'),
(23, 'milk'),
(4, 'fish');

INSERT INTO recipe (recipe_id, recipe_image, recipe_name, recipe_description, recipe_preparation, recipe_type) OVERRIDING SYSTEM VALUE VALUES
(1, 'img/bowl_poulet.jpg', 'Bowl Poulet Riz', 'Un repas équilibré riche en protéines pour la prise de masse.', 'Cuire le riz. Faire revenir le blanc de poulet avec l''huile d''olive. Ajouter le brocoli vapeur. Assembler dans un bol.', 'muscle_gain'),
(2, 'img/smoothie_banane.jpg', 'Smoothie Banane Avoine', 'Smoothie nourrissant idéal avant l''entraînement.', 'Mixer la banane, les flocons d''avoine, le yaourt grec et un peu d''eau.', 'breakfast'),
(3, 'img/omelette.jpg', 'Omelette aux épinards', 'Petit-déjeuner protéiné simple et rapide.', 'Battre les oeufs, ajouter les épinards, cuire à la poêle.', 'breakfast'),
(4, 'img/salade_thon.jpg', 'Salade Thon Tomate', 'Repas léger et protéiné idéal pour la perte de poids.', 'Mélanger le thon, les tomates, les poivrons. Assaisonner.', 'weight_loss'),
(5, 'img/pates_saumon.jpg', 'Pâtes au Saumon', 'Plat riche en oméga-3 et glucides complexes.', 'Cuire les pâtes complètes. Faire revenir le saumon. Mélanger avec les épinards.', 'dinner'),
(6, 'img/pancakes_avoine.jpg', 'Pancakes Avoine Banane', 'Pancakes healthy sans gluten ajouté.', 'Mixer avoine, banane, oeufs. Cuire à la poêle.', 'breakfast'),
(7, 'img/bowl_quinoa.jpg', 'Bowl Quinoa Légumes', 'Bowl végétarien complet et nutritif.', 'Cuire le quinoa. Rôtir les poivrons et carottes. Assembler.', 'lunch'),
(8, 'img/lentilles_curry.jpg', 'Dahl de Lentilles', 'Repas vegan riche en fibres et protéines végétales.', 'Cuire les lentilles avec les épices. Ajouter tomates et épinards.', 'dinner'),
(9, 'img/yaourt_fruits.jpg', 'Yaourt Grec Myrtilles', 'Collation légère et protéinée.', 'Mélanger le yaourt grec avec les myrtilles et un peu de beurre de cacahuète.', 'snack'),
(10, 'img/patate_boeuf.jpg', 'Patate Douce Boeuf', 'Repas de prise de masse avec glucides et protéines.', 'Rôtir la patate douce. Cuire le boeuf haché. Accompagner de brocoli.', 'muscle_gain'),
(11, 'img/porridge.jpg', 'Porridge Fruits Rouges', 'Petit-déjeuner chaud et rassasiant.', 'Cuire les flocons d''avoine dans l''eau. Ajouter myrtilles et banane.', 'breakfast'),
(12, 'img/cottage_pomme.jpg', 'Cottage Cheese Pomme', 'Collation protéinée et légère pour la perte de poids.', 'Mélanger cottage cheese avec pomme découpée et amandes.', 'weight_loss');

INSERT INTO recipe_ingredient (recipe_id, ingredient_id, ingredient_quantity) VALUES
(1, 1, 150.0), (1, 2, 200.0), (1, 3, 100.0), (1, 18, 10.0);

INSERT INTO recipe_ingredient (recipe_id, ingredient_id, ingredient_quantity) VALUES
(2, 7, 120.0), (2, 6, 50.0), (2, 9, 100.0);

INSERT INTO recipe_ingredient (recipe_id, ingredient_id, ingredient_quantity) VALUES
(3, 5, 150.0), (3, 11, 80.0), (3, 18, 5.0);

INSERT INTO recipe_ingredient (recipe_id, ingredient_id, ingredient_quantity) VALUES
(4, 13, 120.0), (4, 10, 150.0), (4, 24, 100.0), (4, 18, 10.0);

INSERT INTO recipe_ingredient (recipe_id, ingredient_id, ingredient_quantity) VALUES
(5, 12, 200.0), (5, 4, 150.0), (5, 11, 60.0), (5, 18, 10.0);

INSERT INTO recipe_ingredient (recipe_id, ingredient_id, ingredient_quantity) VALUES
(6, 6, 80.0), (6, 7, 100.0), (6, 5, 100.0);

INSERT INTO recipe_ingredient (recipe_id, ingredient_id, ingredient_quantity) VALUES
(7, 22, 150.0), (7, 24, 100.0), (7, 20, 80.0), (7, 11, 60.0), (7, 18, 10.0);

INSERT INTO recipe_ingredient (recipe_id, ingredient_id, ingredient_quantity) VALUES
(8, 14, 200.0), (8, 10, 100.0), (8, 11, 80.0), (8, 18, 10.0);

INSERT INTO recipe_ingredient (recipe_id, ingredient_id, ingredient_quantity) VALUES
(9, 9, 150.0), (9, 25, 80.0), (9, 16, 20.0);

INSERT INTO recipe_ingredient (recipe_id, ingredient_id, ingredient_quantity) VALUES
(10, 15, 250.0), (10, 21, 150.0), (10, 3, 100.0), (10, 18, 10.0);

INSERT INTO recipe_ingredient (recipe_id, ingredient_id, ingredient_quantity) VALUES
(11, 6, 80.0), (11, 25, 80.0), (11, 7, 100.0);

INSERT INTO recipe_ingredient (recipe_id, ingredient_id, ingredient_quantity) VALUES
(12, 17, 150.0), (12, 19, 120.0), (12, 8, 20.0);

INSERT INTO user_ (user_id, user_username, user_firstname, user_lastname, user_birth, user_role, user_gender, user_city, user_country, user_phone, user_size, user_weight, user_last_weight, user_email, user_hashpwd, user_inscription, sport_program_id, company_id) OVERRIDING SYSTEM VALUE VALUES
(1, 'jmartin', 'Jean', 'Martin', '1990-04-15', 'user', 'male', 'Paris', 'France', '+33612345678', 178, 82.0, 84.5, 'jean.martin@gmail.com', '$2b$12$hashedpwd1', '2023-01-10', 2, NULL),
(2, 'sdupont', 'Sophie', 'Dupont', '1995-08-22', 'user', 'female', 'Lyon', 'France', '+33623456789', 165, 60.0, 63.0, 'sophie.dupont@gmail.com', '$2b$12$hashedpwd2', '2023-02-14', 3, NULL),
(3, 'pmoreau', 'Pierre', 'Moreau', '1988-12-03', 'user', 'male', 'Marseille', 'France', '+33634567890', 182, 95.0, 98.0, 'pierre.moreau@gmail.com', '$2b$12$hashedpwd3', '2023-03-05', 1, NULL),
(4, 'aleblanc', 'Alice', 'Leblanc', '2000-06-18', 'user', 'female', 'Bordeaux', 'France', '+33645678901', 170, 55.0, 55.5, 'alice.leblanc@gmail.com', '$2b$12$hashedpwd4', '2023-04-20', 5, NULL),
(5, 'tgirard', 'Thomas', 'Girard', '1985-02-28', 'user', 'male', 'Toulouse', 'France', '+33656789012', 175, 78.0, 79.5, 'thomas.girard@gmail.com', '$2b$12$hashedpwd5', '2023-05-01', 8, NULL),
(6, 'cbernard', 'Claire', 'Bernard', '1992-09-10', 'user', 'female', 'Nantes', 'France', '+33667890123', 162, 58.0, 59.5, 'claire.bernard@gmail.com', '$2b$12$hashedpwd6', '2023-06-15', 4, NULL),
(7, 'rleroy', 'Romain', 'Leroy', '1998-11-25', 'user', 'male', 'Strasbourg', 'France', '+33678901234', 180, 75.0, 73.0, 'romain.leroy@gmail.com', '$2b$12$hashedpwd7', '2023-07-03', 7, NULL),
(8, 'esimon', 'Emma', 'Simon', '1997-03-07', 'user', 'female', 'Lille', 'France', '+33689012345', 168, 62.0, 64.0, 'emma.simon@gmail.com', '$2b$12$hashedpwd8', '2023-08-22', 6, NULL),
(9, 'nrichard', 'Nicolas', 'Richard', '1983-07-14', 'admin', 'male', 'Paris', 'France', '+33690123456', 176, 88.0, 90.0, 'nicolas.richard@admin.com', '$2b$12$hashedpwd9', '2022-12-01', NULL, NULL),
(10, 'mthomas', 'Marie', 'Thomas', '1993-05-30', 'user', 'female', 'Montpellier', 'France', '+33601234567', 163, 57.0, 58.0, 'marie.thomas@gmail.com', '$2b$12$hashedpwd10', '2023-09-10', 3, NULL),
(11, 'ldavid', 'Lucas', 'David', '2001-01-20', 'user', 'male', 'Rennes', 'France', '+33602345678', 172, 68.0, 66.0, 'lucas.david@gmail.com', '$2b$12$hashedpwd11', '2023-10-05', 1, NULL),
(12, 'jrobert', 'Julie', 'Robert', '1989-10-12', 'user', 'female', 'Grenoble', 'France', '+33603456789', 167, 64.0, 67.0, 'julie.robert@gmail.com', '$2b$12$hashedpwd12', '2023-11-18', 2, NULL),
(13, 'aperrin', 'Antoine', 'Perrin', '1996-07-08', 'user', 'male', 'Nice', 'France', '+33604567890', 183, 80.0, 78.5, 'antoine.perrin@gmail.com', '$2b$12$hashedpwd13', '2024-01-02', 8, NULL),
(14, 'egarnier', 'Elodie', 'Garnier', '1994-04-25', 'user', 'female', 'Toulon', 'France', '+33605678901', 160, 52.0, 53.0, 'elodie.garnier@gmail.com', '$2b$12$hashedpwd14', '2024-01-15', 6, NULL),
(15, 'fchevalier', 'François', 'Chevalier', '1980-08-19', 'user', 'male', 'Paris', 'France', '+33606789012', 177, 90.0, 93.0, 'francois.chevalier@gmail.com', '$2b$12$hashedpwd15', '2024-02-10', 4, NULL),
(16, 'jfitcorp1', 'Julien', 'Lambert', '1991-03-14', 'user', 'male', 'Paris', 'France', '+33607890123', 180, 83.0, 85.0, 'julien.lambert@fitcorp.com', '$2b$12$hashedpwd16', '2023-01-20', 2, 1),
(17, 'sfitcorp2', 'Sarah', 'Morel', '1996-06-22', 'user', 'female', 'Paris', 'France', '+33608901234', 166, 59.0, 61.0, 'sarah.morel@fitcorp.com', '$2b$12$hashedpwd17', '2023-01-20', 3, 1),
(18, 'mfitcorp3', 'Marc', 'Fontaine', '1987-11-05', 'company_admin', 'male', 'Paris', 'France', '+33609012345', 175, 78.0, 77.0, 'marc.fontaine@fitcorp.com', '$2b$12$hashedpwd18', '2023-01-20', NULL, 1),
(19, 'lhealthplus1', 'Laura', 'Rousseau', '1993-09-18', 'user', 'female', 'Lyon', 'France', '+33610123456', 164, 56.0, 57.5, 'laura.rousseau@healthplus.fr', '$2b$12$hashedpwd19', '2023-02-01', 1, 2),
(20, 'ahealthplus2', 'Alexis', 'Blanc', '1990-02-27', 'user', 'male', 'Lyon', 'France', '+33611234567', 181, 86.0, 88.0, 'alexis.blanc@healthplus.fr', '$2b$12$hashedpwd20', '2023-02-01', 7, 2),
(21, 'chealthplus3', 'Camille', 'Guerin', '1999-12-10', 'company_admin', 'female', 'Lyon', 'France', '+33612345670', 168, 61.0, 62.0, 'camille.guerin@healthplus.fr', '$2b$12$hashedpwd21', '2023-02-01', NULL, 2),
(22, 'bdurand', 'Baptiste', 'Durand', '1986-05-31', 'user', 'male', 'Bordeaux', 'France', '+33613456789', 179, 91.0, 94.0, 'baptiste.durand@gmail.com', '$2b$12$hashedpwd22', '2024-03-01', 3, NULL),
(23, 'cmartin2', 'Charlotte', 'Martin', '1998-08-14', 'user', 'female', 'Paris', 'France', '+33614567890', 171, 63.0, 65.0, 'charlotte.martin2@gmail.com', '$2b$12$hashedpwd23', '2024-03-15', 1, NULL),
(24, 'ypicard', 'Yann', 'Picard', '1975-01-07', 'user', 'male', 'Nantes', 'France', '+33615678901', 174, 85.0, 87.0, 'yann.picard@gmail.com', '$2b$12$hashedpwd24', '2024-04-01', 6, NULL),
(25, 'abonnet', 'Amandine', 'Bonnet', '2002-07-23', 'user', 'female', 'Toulouse', 'France', '+33616789012', 162, 51.0, 51.0, 'amandine.bonnet@gmail.com', '$2b$12$hashedpwd25', '2024-04-20', 5, NULL),
(26, 'jrousseau', 'Julien', 'Rousseau', '1992-10-16', 'user', 'male', 'Strasbourg', 'France', '+33617890123', 182, 77.0, 75.5, 'julien.rousseau@gmail.com', '$2b$12$hashedpwd26', '2024-05-05', 2, NULL),
(27, 'isport1', 'Igor', 'Valentin', '1988-04-03', 'user', 'male', 'Nice', 'France', '+33618901234', 176, 79.0, 78.0, 'igor.valentin@sportelite.io', '$2b$12$hashedpwd27', '2023-03-01', 8, 3),
(28, 'ksport2', 'Katia', 'Marchal', '1994-11-28', 'company_admin', 'female', 'Nice', 'France', '+33619012345', 165, 57.0, 56.5, 'katia.marchal@sportelite.io', '$2b$12$hashedpwd28', '2023-03-01', NULL, 3),
(29, 'owell1', 'Olivier', 'Petitjean', '1985-06-19', 'user', 'male', 'Montpellier', 'France', '+33620123456', 178, 80.0, 82.0, 'olivier.petitjean@wellnessgroup.com', '$2b$12$hashedpwd29', '2023-06-01', 6, 4),
(30, 'factive1', 'Fatima', 'El Amrani', '1997-02-14', 'user', 'female', 'Rennes', 'France', '+33621234567', 163, 60.0, 61.5, 'fatima.elamrani@activelife.fr', '$2b$12$hashedpwd30', '2023-09-15', 4, 5);

INSERT INTO user_health_profile (user_health_profile_objective, user_health_profile_activity, user_health_profile_food_diet, user_id) VALUES
('weight_loss', 'moderately_active', 'none', 1),
('muscle_gain', 'very_active', 'none', 2),
('weight_loss', 'lightly_active', 'none', 3),
('flexibility', 'lightly_active', 'vegetarian', 4),
('muscle_gain', 'very_active', 'none', 5),
('endurance', 'moderately_active', 'none', 6),
('weight_loss', 'moderately_active', 'none', 7),
('maintenance', 'lightly_active', 'vegetarian', 8),
('maintenance', 'moderately_active', 'none', 9),
('weight_loss', 'lightly_active', 'none', 10),
('muscle_gain', 'moderately_active', 'none', 11),
('muscle_gain', 'moderately_active', 'none', 12),
('muscle_gain', 'very_active', 'none', 13),
('weight_loss', 'sedentary', 'none', 14),
('weight_loss', 'lightly_active', 'none', 15),
('muscle_gain', 'very_active', 'none', 16),
('weight_loss', 'moderately_active', 'none', 17),
('maintenance', 'moderately_active', 'none', 18),
('weight_loss', 'lightly_active', 'vegetarian', 19),
('weight_loss', 'moderately_active', 'none', 20),
('maintenance', 'lightly_active', 'none', 21),
('weight_loss', 'sedentary', 'none', 22),
('muscle_gain', 'lightly_active', 'none', 23),
('maintenance', 'lightly_active', 'none', 24),
('flexibility', 'lightly_active', 'vegan', 25),
('muscle_gain', 'very_active', 'none', 26),
('muscle_gain', 'very_active', 'none', 27),
('maintenance', 'moderately_active', 'none', 28),
('maintenance', 'lightly_active', 'none', 29),
('endurance', 'very_active', 'none', 30);

INSERT INTO user_allergy (user_id, allergy) VALUES
(2, 'gluten'),
(4, 'milk'),
(7, 'peanuts'),
(10, 'eggs'),
(14, 'fish'),
(17, 'milk'),
(19, 'nuts'),
(22, 'gluten'),
(25, 'milk'),
(25, 'eggs');

INSERT INTO user_subscription (user_id, subscription_id, user_subscription_start, user_subscription_end, user_subscription_is_active) VALUES
(3, 1, '2023-03-05', NULL, TRUE),
(10, 1, '2023-09-10', NULL, TRUE),
(14, 1, '2024-01-15', NULL, TRUE),
(22, 1, '2024-03-01', NULL, TRUE),
(23, 1, '2024-03-15', NULL, TRUE),
(24, 1, '2024-04-01', NULL, TRUE),
(25, 1, '2024-04-20', NULL, TRUE);

INSERT INTO user_subscription (user_id, subscription_id, user_subscription_start, user_subscription_end, user_subscription_is_active) VALUES
(1, 2, '2023-01-10', NULL, TRUE),
(2, 2, '2023-02-14', NULL, TRUE),
(4, 2, '2023-04-20', NULL, TRUE),
(7, 2, '2023-07-03', NULL, TRUE),
(8, 2, '2023-08-22', NULL, TRUE),
(11, 2, '2023-10-05', NULL, TRUE),
(12, 2, '2023-11-18', NULL, TRUE),
(26, 2, '2024-05-05', NULL, TRUE);

INSERT INTO user_subscription (user_id, subscription_id, user_subscription_start, user_subscription_end, user_subscription_is_active) VALUES
(5, 3, '2023-05-01', NULL, TRUE),
(6, 3, '2023-06-15', NULL, TRUE),
(13, 3, '2024-01-02', NULL, TRUE),
(15, 3, '2024-02-10', NULL, TRUE);

INSERT INTO user_subscription (user_id, subscription_id, user_subscription_start, user_subscription_end, user_subscription_is_active) VALUES
(1, 1, '2022-06-01', '2023-01-09', FALSE),
(5, 2, '2023-01-15', '2023-04-30', FALSE),
(12, 1, '2023-08-01', '2023-11-17', FALSE);

INSERT INTO user_subscription (user_id, subscription_id, user_subscription_start, user_subscription_end, user_subscription_is_active) VALUES
(16, 4, '2023-01-20', NULL, TRUE),
(17, 4, '2023-01-20', NULL, TRUE),
(18, 4, '2023-01-20', NULL, TRUE),
(19, 5, '2023-02-01', NULL, TRUE),
(20, 5, '2023-02-01', NULL, TRUE),
(21, 5, '2023-02-01', NULL, TRUE),
(27, 6, '2023-03-01', NULL, TRUE),
(28, 6, '2023-03-01', NULL, TRUE),
(29, 7, '2023-06-01', NULL, TRUE),
(30, 8, '2023-09-15', NULL, TRUE);

DO $$
DECLARE
  v_user_id INT;
  v_date DATE;
  v_base_weight DECIMAL(4,1);
  v_steps INT;
  v_sleep INT;
  v_weight_var DECIMAL(4,1);
  user_ids INT[] := ARRAY[1, 2, 3, 5, 7, 11, 13, 16, 20, 26];
  base_weights DECIMAL[] := ARRAY[82.0, 60.0, 95.0, 78.0, 75.0, 68.0, 80.0, 83.0, 86.0, 77.0];
BEGIN
  FOR i IN 1..array_length(user_ids, 1) LOOP
    v_user_id := user_ids[i];
    v_base_weight := base_weights[i];
    FOR d IN 0..89 LOOP
      v_date := CURRENT_DATE - (90 - d);
      v_steps := 5000 + (random() * 10000)::INT;
      v_sleep := 360 + (random() * 180)::INT;
      v_weight_var := round((random() * 2 - 1)::NUMERIC, 1);
      INSERT INTO user_biometric (biometric_date, biometric_sleep, biometric_steps, biometric_weight, user_id)
      VALUES (v_date, v_sleep, v_steps, v_base_weight + v_weight_var, v_user_id);
    END LOOP;
  END LOOP;
END $$;

INSERT INTO session_progress (session_progress_start, session_progress_end, sport_session_id, user_id) VALUES
('2024-01-08', '2024-01-08', 7, 1),
('2024-01-10', '2024-01-10', 8, 1),
('2024-01-12', '2024-01-12', 9, 1),
('2024-01-15', '2024-01-15', 7, 1),
('2024-01-17', '2024-01-17', 8, 1),
('2024-01-19', '2024-01-19', 9, 1),
('2024-01-22', '2024-01-22', 7, 1),
('2024-01-24', '2024-01-24', 8, 1),
('2024-01-26', '2024-01-26', 9, 1),
('2024-01-29', '2024-01-29', 12, 1),
('2024-02-01', '2024-02-01', 8, 1),
('2024-02-05', '2024-02-05', 13, 1),
('2024-01-09', '2024-01-09', 5, 2),
('2024-01-11', '2024-01-11', 10, 2),
('2024-01-13', '2024-01-13', 6, 2),
('2024-01-16', '2024-01-16', 5, 2),
('2024-01-20', '2024-01-20', 10, 2),
('2024-01-25', '2024-01-25', 6, 2),
('2024-02-02', '2024-02-02', 5, 2),
('2024-02-08', '2024-02-08', 10, 2),
('2024-02-01', '2024-02-01', 1, 3),
('2024-02-06', '2024-02-06', 2, 3),
('2024-02-10', '2024-02-10', 1, 3),
('2024-01-05', '2024-01-05', 3, 5),
('2024-01-08', '2024-01-08', 4, 5),
('2024-01-12', '2024-01-12', 3, 5),
('2024-01-15', '2024-01-15', 4, 5),
('2024-01-19', '2024-01-19', 11, 5),
('2024-01-22', '2024-01-22', 3, 5),
('2024-01-26', '2024-01-26', 4, 5),
('2024-01-29', '2024-01-29', 11, 5),
('2024-02-02', '2024-02-02', 3, 5),
('2024-02-05', '2024-02-05', 4, 5),
('2024-01-10', '2024-01-10', 14, 7),
('2024-01-13', '2024-01-13', 5, 7),
('2024-01-17', '2024-01-17', 15, 7),
('2024-01-20', '2024-01-20', 14, 7),
('2024-01-24', '2024-01-24', 5, 7),
('2024-01-27', '2024-01-27', 6, 7),
('2024-02-03', '2024-02-03', 14, 7),
('2024-03-01', '2024-03-01', 1, 11),
('2024-03-04', '2024-03-04', 6, 11),
('2024-03-07', '2024-03-07', 2, 11),
('2024-03-11', '2024-03-11', 1, 11),
('2024-03-14', '2024-03-14', 6, 11),
('2024-04-15', NULL, 1, 23),
('2024-04-16', NULL, 5, 7),
('2024-01-03', '2024-01-03', 8, 13),
('2024-01-06', '2024-01-06', 9, 13),
('2024-01-10', '2024-01-10', 7, 13),
('2024-01-13', '2024-01-13', 8, 13),
('2024-01-17', '2024-01-17', 9, 13),
('2024-01-20', '2024-01-20', 12, 13),
('2024-01-24', '2024-01-24', 13, 13),
('2024-01-27', '2024-01-27', 7, 13),
('2024-01-15', '2024-01-15', 7, 16),
('2024-01-18', '2024-01-18', 8, 16),
('2024-01-22', '2024-01-22', 9, 16),
('2024-01-25', '2024-01-25', 7, 16),
('2024-01-29', '2024-01-29', 8, 16),
('2024-02-05', '2024-02-05', 14, 20),
('2024-02-08', '2024-02-08', 5, 20),
('2024-02-12', '2024-02-12', 15, 20),
('2024-02-15', '2024-02-15', 14, 20);

INSERT INTO consume (user_id, ingredient_id, ingredient_quantity, consume_date) VALUES
(1, 6, 80.0, '2024-01-08'), (1, 7, 100.0, '2024-01-08'), (1, 9, 150.0, '2024-01-08'),
(1, 1, 150.0, '2024-01-08'), (1, 2, 200.0, '2024-01-08'), (1, 3, 100.0, '2024-01-08'),
(1, 21, 150.0, '2024-01-08'), (1, 15, 200.0, '2024-01-08'),
(1, 6, 80.0, '2024-01-09'), (1, 5, 150.0, '2024-01-09'), (1, 11, 80.0, '2024-01-09'),
(1, 13, 120.0, '2024-01-09'), (1, 10, 150.0, '2024-01-09'), (1, 2, 200.0, '2024-01-09'),
(1, 1, 150.0, '2024-01-10'), (1, 2, 200.0, '2024-01-10'), (1, 3, 100.0, '2024-01-10'),
(1, 17, 150.0, '2024-01-10'), (1, 19, 120.0, '2024-01-10'), (1, 8, 20.0, '2024-01-10'),
(1, 4, 150.0, '2024-01-11'), (1, 12, 200.0, '2024-01-11'), (1, 11, 60.0, '2024-01-11'),
(1, 6, 80.0, '2024-01-12'), (1, 7, 100.0, '2024-01-12'), (1, 9, 150.0, '2024-01-12'),
(1, 21, 150.0, '2024-01-12'), (1, 15, 200.0, '2024-01-12'), (1, 3, 100.0, '2024-01-12'),
(1, 1, 180.0, '2024-01-15'), (1, 2, 250.0, '2024-01-15'), (1, 3, 120.0, '2024-01-15'),
(1, 8, 30.0, '2024-01-15'), (1, 9, 200.0, '2024-01-15'),
(2, 5, 150.0, '2024-01-09'), (2, 11, 80.0, '2024-01-09'), (2, 18, 5.0, '2024-01-09'),
(2, 13, 120.0, '2024-01-09'), (2, 10, 150.0, '2024-01-09'), (2, 24, 100.0, '2024-01-09'),
(2, 9, 150.0, '2024-01-09'), (2, 25, 80.0, '2024-01-09'),
(2, 6, 60.0, '2024-01-11'), (2, 7, 100.0, '2024-01-11'), (2, 9, 100.0, '2024-01-11'),
(2, 1, 120.0, '2024-01-11'), (2, 3, 100.0, '2024-01-11'),
(2, 17, 150.0, '2024-01-13'), (2, 19, 120.0, '2024-01-13'), (2, 8, 20.0, '2024-01-13'),
(2, 13, 120.0, '2024-01-16'), (2, 10, 200.0, '2024-01-16'), (2, 11, 80.0, '2024-01-16'),
(2, 5, 120.0, '2024-01-20'), (2, 11, 80.0, '2024-01-20'), (2, 10, 100.0, '2024-01-20'),
(5, 6, 100.0, '2024-01-05'), (5, 7, 150.0, '2024-01-05'), (5, 9, 200.0, '2024-01-05'), (5, 16, 30.0, '2024-01-05'),
(5, 1, 200.0, '2024-01-05'), (5, 2, 300.0, '2024-01-05'), (5, 3, 150.0, '2024-01-05'),
(5, 21, 200.0, '2024-01-05'), (5, 15, 300.0, '2024-01-05'),
(5, 4, 200.0, '2024-01-08'), (5, 12, 250.0, '2024-01-08'), (5, 11, 100.0, '2024-01-08'),
(5, 6, 100.0, '2024-01-08'), (5, 8, 30.0, '2024-01-08'), (5, 9, 200.0, '2024-01-08'),
(5, 1, 200.0, '2024-01-12'), (5, 2, 300.0, '2024-01-12'), (5, 3, 150.0, '2024-01-12'),
(5, 22, 200.0, '2024-01-12'), (5, 24, 150.0, '2024-01-12'),
(7, 6, 60.0, '2024-01-10'), (7, 7, 100.0, '2024-01-10'), (7, 9, 100.0, '2024-01-10'),
(7, 1, 120.0, '2024-01-10'), (7, 3, 100.0, '2024-01-10'), (7, 14, 150.0, '2024-01-10'),
(7, 17, 150.0, '2024-01-13'), (7, 25, 80.0, '2024-01-13'), (7, 9, 100.0, '2024-01-13'),
(7, 1, 120.0, '2024-01-17'), (7, 15, 200.0, '2024-01-17'), (7, 3, 100.0, '2024-01-17'),
(7, 14, 150.0, '2024-01-20'), (7, 10, 150.0, '2024-01-20'), (7, 11, 80.0, '2024-01-20'),
(13, 1, 180.0, '2024-01-03'), (13, 2, 250.0, '2024-01-03'), (13, 3, 150.0, '2024-01-03'),
(13, 6, 80.0, '2024-01-06'), (13, 7, 120.0, '2024-01-06'), (13, 5, 150.0, '2024-01-06'),
(13, 4, 180.0, '2024-01-10'), (13, 12, 250.0, '2024-01-10'), (13, 11, 80.0, '2024-01-10'),
(13, 21, 180.0, '2024-01-13'), (13, 15, 300.0, '2024-01-13'), (13, 3, 150.0, '2024-01-13'),
(13, 1, 180.0, '2024-01-17'), (13, 22, 200.0, '2024-01-17'), (13, 24, 120.0, '2024-01-17'),
(16, 1, 160.0, '2024-01-15'), (16, 2, 220.0, '2024-01-15'), (16, 3, 100.0, '2024-01-15'),
(16, 6, 80.0, '2024-01-18'), (16, 9, 150.0, '2024-01-18'), (16, 7, 100.0, '2024-01-18'),
(16, 13, 120.0, '2024-01-22'), (16, 10, 150.0, '2024-01-22'),
(20, 5, 120.0, '2024-02-05'), (20, 11, 80.0, '2024-02-05'), (20, 3, 100.0, '2024-02-05'),
(20, 17, 150.0, '2024-02-08'), (20, 19, 120.0, '2024-02-08'),
(20, 14, 200.0, '2024-02-12'), (20, 22, 150.0, '2024-02-12'), (20, 24, 100.0, '2024-02-12');