-- Bölüm D için örnek veri.
-- Sıra: schema.sql -> constraints.sql -> violations.sql -> seed.sql
-- Tabloları boşaltır, algebra.sql'in soruları için veriyi yeniden kurar.

TRUNCATE membership_plan, trainer, member, fitness_class, class_booking
  RESTART IDENTITY CASCADE;

INSERT INTO membership_plan (plan_name, monthly_price, duration_months) VALUES
  ('Basic',   300.00,  1),
  ('Premium', 500.00, 12),
  ('Student', 200.00,  6),
  ('Annual',  450.00, 12),
  ('Family',  700.00, 12);

INSERT INTO trainer (full_name, specialty) VALUES
  ('Ayşe Demir',    'yoga'),
  ('Mehmet Kaya',   'crossfit'),
  ('Zeynep Arslan', 'yoga'),
  ('Burak Şen',     'strength'),
  ('Selin Acar',    'pilates');

-- Üye 7 ve 8 hiç rezervasyon yapmadı (D4 için).
INSERT INTO member (plan_id, full_name, email, join_date) VALUES
  (1, 'Ali Veli',     'ali@example.com',    '2026-01-10'),
  (1, 'Ayşe Can',     'ayse@example.com',   '2026-02-01'),
  (2, 'Can Er',       'can@example.com',    '2026-03-01'),
  (2, 'Deniz Aksoy',  'deniz@example.com',  '2026-03-15'),
  (3, 'Elif Kara',    'elif@example.com',   '2026-04-01'),
  (3, 'Furkan Ay',    'furkan@example.com', '2026-04-05'),
  (1, 'Gül Tan',      'gul@example.com',    '2026-04-10'),
  (2, 'Hakan Işık',   'hakan@example.com',  '2026-04-12');

-- Yoga uzmanı antrenörlerin dersleri: 1, 2, 3 (antrenör 1 ve 3).
-- Kapasitesi 50'den büyük dersler: 6 ve 7.
INSERT INTO fitness_class (trainer_id, class_name, start_time, capacity, end_time) VALUES
  (1, 'Morning Yoga',       '2026-05-04 09:00', 20, '2026-05-04 10:00'),
  (3, 'Evening Yoga',       '2026-05-04 18:00', 15, '2026-05-04 19:00'),
  (1, 'Sunrise Yoga',       '2026-05-06 07:00', 12, '2026-05-06 08:00'),
  (2, 'CrossFit Basics',    '2026-05-05 18:00', 15, '2026-05-05 19:00'),
  (2, 'CrossFit Advanced',  '2026-05-07 18:00', 10, '2026-05-07 19:30'),
  (4, 'Strength Circuit',   '2026-05-06 19:00', 60, '2026-05-06 20:00'),
  (4, 'Open Gym Session',   '2026-05-08 12:00', 80, '2026-05-08 14:00');

-- D6 için:
--   Üye 1 ve 3: üç yoga dersinin hepsine kayıtlı (cevap bunlar).
--   Üye 2: yalnızca 1 ve 2 numaralı yoga derslerine kayıtlı (3'e eksik),
--          ama CrossFit'e de kayıtlı. Toplam rezervasyon sayısı 4 olduğu için
--          spor dışı kayıtları da sayan bir COUNT sorgusu onu yanlışlıkla seçer.
INSERT INTO class_booking (member_id, class_id, booking_date, attended) VALUES
  (1, 1, '2026-04-28', true),
  (1, 2, '2026-04-28', true),
  (1, 3, '2026-04-30', NULL),
  (2, 1, '2026-04-29', true),
  (2, 2, '2026-04-29', false),
  (2, 4, '2026-04-30', NULL),
  (2, 5, '2026-05-01', NULL),
  (3, 1, '2026-04-29', true),
  (3, 2, '2026-04-30', true),
  (3, 3, '2026-05-01', NULL),
  (4, 1, '2026-04-30', false),
  (4, 6, '2026-05-02', NULL),
  (5, 4, '2026-05-01', NULL),
  (6, 4, '2026-05-02', NULL);
